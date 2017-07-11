//
//  RegisterPageViewController.swift
//  ReportaGDL
//
//  Created by Tona on 14/10/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterPageViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        registerForKeyboardNotifications()
        txtName.delegate = self
        txtEmail.delegate = self
        txtPassword.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = UIColor(red: 3/255, green: 145/255, blue: 253/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
        deregisterFromKeyboardNotifications()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @IBAction func registerTap(_ sender: AnyObject) {
        if ((txtName.text?.isEmpty)! || (txtEmail.text?.isEmpty)! || (txtPassword.text?.isEmpty)!){
            // create the alert
            let alert = UIAlertController(title: "Error", message: "Todos los campos son obligatorios", preferredStyle: UIAlertControllerStyle.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        } else {
            
            let JSONObject: [String : AnyObject] = [
                "nombre" : txtName.text! as AnyObject,
                "email" : txtEmail.text! as AnyObject,
                "contra": txtPassword.text! as AnyObject
            ]
            
            do {
                
                let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
                
                // create post request
                let url = NSURL(string: "http://reportagdl.uperny.com/controller/insertar_usuario.php")!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                
                // insert json data to the request
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
                request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
                request.httpBody = jsonData
                
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data, response, error in
                    if error != nil{
                        print("Error -> \(error)")
                        DispatchQueue.main.async(execute: {
                            self.displayAlertMessage("Error", userMessage: "Parece que no tienes una conexión estable a internet. Intenta más tarde", action: UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                action in
                                print("")
                            })
                        });
                        return
                    }
                    
                    do {
                        let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]
                        
                        print("Result -> \(result!)")
                        
                        if let parseJSON = result { //json.count > 0 {
                            let resultValue = parseJSON["estado"] as? Int
                            
                            var title:String = ""
                            var messageToDisplay:String = ""
                            var isUserRegistered:Bool = false
                            var action:UIAlertAction
                            
                            action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                action in print("")
                            }
                            
                            // User registered
                            if(resultValue == 1) {
                                isUserRegistered = true
                                title = "Bienvenido"
                                messageToDisplay = "Ingresa a tu correo para confirmar tu cuenta, es probable que tengas que checar en Spam"
                                action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                                    action in
                                        _ = self.navigationController?.popViewController(animated: true)
                                }
                            }
                            
                            // User not registered
                            if(!isUserRegistered){
                                title = "Error"
                                messageToDisplay = parseJSON["mensaje"] as! String!
                            }
                            
                            DispatchQueue.main.async(execute: {
                                self.displayAlertMessage(title, userMessage: messageToDisplay, action: action)
                            });
                        }
                        
                    } catch {
                        print("Error -> \(error)")
                    }
                }
                
                task.resume()
                
            } catch {
                print(error)
            }
            
        }
    }
    
    func displayAlertMessage(_ title: String, userMessage : String, action : UIAlertAction){
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addAction(action)
        
        self.present(myAlert, animated: true, completion: nil)
    }

    //SCROLL VIEW STUFF
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    private func findActiveTextField (subviews : [UIView], textField : inout UITextField?) { for view in subviews { if let tf = view as? UITextField, view.isFirstResponder { textField = tf; break } else if !view.subviews.isEmpty { findActiveTextField (subviews: view.subviews, textField: &textField) } } }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        findActiveTextField(subviews:view.subviews, textField: &activeField)
        if let activeField = self.activeField {
            if (!aRect.contains(activeField.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardSize!.height, 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        self.view.endEditing(true)
        self.scrollView.isScrollEnabled = false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
        activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
        activeField = nil
    }

}
