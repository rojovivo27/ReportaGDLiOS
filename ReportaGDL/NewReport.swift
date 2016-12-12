//
//  NewReport.swift
//  ReportaGDL
//
//  Created by Tona on 05/11/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class NewReport: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {
    
    var categorias = [Category]()
    var subcategorias = [Category]()
    
    var latitude = 0.0
    var longitude = 0.0
    var category = -1
    var subcategory = -1
    
    @IBOutlet weak var txtDescription: UITextView!
    @IBOutlet weak var btnReport: UIButton!
    @IBOutlet weak var btnCategory: UIButton!
    @IBOutlet weak var btnSubcategory: UIButton!
    @IBOutlet weak var categoryTableView: UITableView!
    @IBOutlet weak var subcategoryTableView: UITableView!
    
    @IBOutlet weak var lblFoto: UILabel!
    @IBOutlet weak var btnFoto: UIButton!
    @IBOutlet weak var imgFoto: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        
        //MARK: Getting the available categories
        do {
            
            // create post request
            let url = NSURL(string: "http://reportagdl.uperny.com/controller/get_categorias.php")!
            
            let request = NSMutableURLRequest(url: url as URL)
            request.httpMethod = "GET"
            
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
                        
                        if(resultValue == 1) {
                            
                            for category in (parseJSON["categorias"] as? [[String: AnyObject]])!{
                                let id = Int(category["id_categoria"]! as! String)!
                                let name = category["categoria_name"]! as! String
                                let image = category["categoria_img"]! as! String
                                self.categorias.append(Category(id: id , name: name, image: image))
                            }
                            
                            DispatchQueue.main.async(execute: {
                                self.categoryTableView.reloadData()
                            });
                            
                        }
                        
                    }
                    
                } catch {
                    print("Error -> \(error)")
                }
            }
            
            task.resume()
            
        }
        
        imagePicker.delegate = self
        
        subcategoryTableView.allowsSelection = true
        
        txtDescription.delegate = self
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnReport.layer.cornerRadius = 5
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(RegisterPageViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        print(latitude)
        print(longitude)
        
        categoryTableView.isHidden = true
        subcategoryTableView.isHidden = true
        
        activityIndicator.hidesWhenStopped = true
        
        
        
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
            statusBar.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "Descripción:") {
           textView.text = ""
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
        if(categoryTableView.isFirstResponder){
            if(!categoryTableView.isHidden) {
                categoryTableView.isHidden = true
            }
            if(!subcategoryTableView.isHidden) {
                subcategoryTableView.isHidden = true
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == subcategoryTableView {
            return subcategorias.count
        } else {
            return categorias.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        if tableView == subcategoryTableView {
            cell = tableView.dequeueReusableCell(withIdentifier: "subcategoryCell")!
            cell.textLabel?.text = subcategorias[indexPath.row].name
            cell.imageView?.image = subcategorias[indexPath.row].img
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell")!
            cell.textLabel?.text = categorias[indexPath.row].name
            cell.imageView?.image = categorias[indexPath.row].img
        }
        //Blue
        //cell.textLabel?.textColor = UIColor(red: 3/255, green: 145/255, blue: 253/255, alpha: 1)
        cell.textLabel?.textColor = UIColor.white
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == subcategoryTableView {
            btnSubcategory.setTitle(subcategorias[indexPath.row].name, for: .normal)
            subcategoryTableView.isHidden = !subcategoryTableView.isHidden
            subcategory = subcategorias[indexPath.row].id
            
        } else {
            btnCategory.setTitle(categorias[indexPath.row].name, for: .normal)
            categoryTableView.isHidden = !categoryTableView.isHidden
            loadSubcategories(categorias[indexPath.row].id)
            category = categorias[indexPath.row].id
        }
    }
    
    
    @IBAction func categoryTapped(_ sender: AnyObject) {
        if(!subcategoryTableView.isHidden){
            subcategoryTableView.isHidden = true
        }
        categoryTableView.isHidden = !categoryTableView.isHidden
    }
    
    @IBAction func subcategoryTapped(_ sender: AnyObject) {
        subcategoryTableView.isHidden = !subcategoryTableView.isHidden
    }
    
    @IBAction func choosePhotoTapped(_ sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgFoto.contentMode = .scaleAspectFit
            imgFoto.image = pickedImage
            
            btnFoto.isHidden = true
            lblFoto.isHidden = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func loadSubcategories(_ id: Int){
        //MARK: Getting the available subcategories
        
        subcategorias = []
        subcategory = -1
        btnSubcategory.setTitle("Seleccione", for: .normal)
        
        let JSONObject: [String : AnyObject] = [
            "id" : id as AnyObject
        ]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string: "http://reportagdl.uperny.com/controller/get_subcategorias_by_id.php")!
            
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
                    let result = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as? [String:AnyObject]
                    
                    print("Result -> \(result!)")
                    
                    if let parseJSON = result { //json.count > 0 {
                        let resultValue = parseJSON["estado"] as? Int
                        
                        if(resultValue == 1) {
                            
                            for category in (parseJSON["subcategorias"] as? [[String: AnyObject]])!{
                                let id = Int(category["id_subcategoria"]! as! String)!
                                let name = category["subcategoria_name"]! as! String
                                let image = category["subcategoria_img"]! as! String
                                self.subcategorias.append(Category(id: id , name: name, image: image))
                            }
                            
                            DispatchQueue.main.async(execute: {
                                self.subcategoryTableView.reloadData()
                            });
                            
                        }
                        
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
    
    @IBAction func generateReport(_ sender: AnyObject) {
        
        var action:UIAlertAction
        action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
            action in print("")
        }
        
        if (category == -1) {
            self.displayAlertMessage("Cuidado", userMessage: "Seleccione una categoría", action: action)
        } else if (subcategory == -1) {
            self.displayAlertMessage("Cuidado", userMessage: "Seleccione una subcategoría", action: action)
        } else if (txtDescription.text == "" || txtDescription.text == "Descripción:") {
            self.displayAlertMessage("Cuidado", userMessage: "Introduzca una descripción", action: action)
        } else if (imgFoto.image == nil) {
            self.displayAlertMessage("Cuidado", userMessage: "Agrega una foto", action: action)
        } else {
            btnReport.isUserInteractionEnabled = false
            activityIndicator.startAnimating()
            uploadReport()
            print(UserDefaults.standard.integer(forKey: "UserID"))
        }
        
        
        
    }
    
    func displayAlertMessage(_ title: String, userMessage : String, action : UIAlertAction){
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addAction(action)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func uploadReport()
    {
        let url = NSURL(string: "http://reportagdl.uperny.com/controller/crear_reporte.php")
        
        let request = NSMutableURLRequest(url:url! as URL);
        request.httpMethod = "POST";
        
        let param = [
            "userID"        : UserDefaults.standard.string(forKey: "UserID")!,
            "subcategory"   : String(subcategory),
            "latitude"   : String(latitude),
            "longitude"   : String(longitude),
            "description"   : String(txtDescription.text!)!
        ]
        
        let boundary = generateBoundaryString()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        
        let imageData = UIImageJPEGRepresentation(imgFoto.image!, 0.1)
        
        if(imageData==nil)  { return; }
        
        
        request.httpBody = createBodyWithParameters(parameters: param, filePathKey: "file", imageDataKey: imageData! as NSData, boundary: boundary)

        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print("error=\(error)")
                return
            }
            
            // You can print out response object
            print("******* response = \(response)")
            
            // Print out reponse body
            //let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            //print("****** response data = \(responseString!)")
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:AnyObject]

                
                print(json ?? "No trae nada")
                
                let resultValue = json?["estado"] as? Int
                
                var title:String = ""
                var messageToDisplay:String = ""
                var action:UIAlertAction
                
                action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    action in print("")
                }
                
                // User registered
                if(resultValue == 1) {
                    title = "Exito"
                } else {
                    title = "Error"
                }
                
                messageToDisplay = json?["mensaje"] as! String
                action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                    action in
                    _ = self.navigationController?.popToRootViewController(animated: true)
                }
                
                DispatchQueue.main.async(execute: {
                    self.btnReport.isUserInteractionEnabled = true
                    UserDefaults.standard.set(true, forKey: "newIncidence")
                    self.activityIndicator.stopAnimating()
                    self.displayAlertMessage(title, userMessage: messageToDisplay, action: action)
                });
                
            } catch {
                self.btnReport.isUserInteractionEnabled = true
                print(error)
            }
            
        }
        
        task.resume()
    }
    
    
    func createBodyWithParameters(parameters: [String: String]?, filePathKey: String?, imageDataKey: NSData, boundary: String) -> Data {
        let body = NSMutableData();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }
        
        let filename = "user-profile.jpg"
        let mimetype = "image/jpg"
        
        body.appendString("--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"\(filePathKey!)\"; filename=\"\(filename)\"\r\n")
        body.appendString("Content-Type: \(mimetype)\r\n\r\n")
        body.append(imageDataKey as Data)
        body.appendString("\r\n")
        
        
        
        body.appendString("--\(boundary)--\r\n")
        
        return body as Data
    }
    
    
    
    func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
}

extension NSMutableData {
    
    func appendString(_ string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
}



class Category {
    let id: Int!
    let name: String!
    let image: String!
    var img: UIImage! = nil
    
    init(id: Int, name: String, image: String){
        self.id = id
        self.name = name
        self.image = image
        
        loadImage()
    }
    
    func loadImage(){
        //img for the cell
        let imgUrl = "http://reportagdl.uperny.com/controller/categories/\(self.image!)"
        do {
            let imageD = try UIImage(data: Data(contentsOf: URL(string: imgUrl)!))
            self.img = imageD
        } catch {
            print("Error -> \(error)")
        }
    }
}

