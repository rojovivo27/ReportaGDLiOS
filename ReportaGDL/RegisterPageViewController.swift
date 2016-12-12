//
//  RegisterPageViewController.swift
//  ReportaGDL
//
//  Created by Tona on 14/10/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class RegisterPageViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var btnRegister: UIButton!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnRegister.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterPageViewController.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        
        
        
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


}
