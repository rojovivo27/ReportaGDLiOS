//
//  Reportes.swift
//  ReportaGDL
//
//  Created by Tona on 14/11/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class Reportes: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableViewIncidences: UITableView!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    var reportes = [Reporte]()
    var imageCache = [String:UIImage]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loading.startAnimating()
        
        let JSONObject: [String : AnyObject] = [
            "id" : UserDefaults.standard.string(forKey: "UserID")! as AnyObject
        ]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string: "http://reportagdl.uperny.com/controller/get_incidences_by_userid.php")!
            
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
                    
                    if let parseJSON = result { //json.count > 0 {
                        let resultValue = parseJSON["estado"] as? Int
                        
                        if(resultValue == 1) {
                            
                            for incidence in (parseJSON["incidencias"] as? [[String: AnyObject]])!{
                                var calificacion = -1
                                var incidencia_fecha_res = ""
                                let id_incidencia = Int(incidence["id_incidencia"]! as! String)!
                                let id_status = Int(incidence["id_status"]! as! String)!
                                let incidencia_descripcion = incidence["incidencia_descripcion"]! as! String
                                let categoria_img = incidence["categoria_img"]! as! String
                                let subcategoria_img = incidence["subcategoria_img"]! as! String
                                let incidencia_foto = incidence["incidencia_foto"]! as! String
                                let incidencia_fecha = incidence["incidencia_fecha"]! as! String
                                if let resolution = incidence["incidencia_fecha_res"]! as? String {
                                    incidencia_fecha_res = resolution
                                }
                                if let rate = incidence["calificacion"]! as? String {
                                    calificacion = Int(rate)!
                                }
                                self.reportes.append(Reporte(id_incidencia: id_incidencia, id_status: id_status, incidencia_descripcion: incidencia_descripcion, categoria_img: categoria_img, subcategoria_img: subcategoria_img, incidencia_foto: incidencia_foto, incidencia_fecha: incidencia_fecha, incidencia_fecha_res: incidencia_fecha_res, calificacion: calificacion))
                            }
                            DispatchQueue.main.async(execute: {
                                self.tableViewIncidences.reloadData()
                                self.loading.stopAnimating()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "report") as! ReportTableViewCell
        cell.id_incidencia = reportes [indexPath.row].id_incidencia
        cell.lblReportNumber.text = "Reporte #\(reportes [indexPath.row].id_incidencia!)"
        cell.incidencia_status = reportes [indexPath.row].id_status
        cell.reportDescription.text = reportes [indexPath.row].incidencia_descripcion
        cell.reportDescription.textColor = UIColor.white
        //CATEGORY
        // If this image is already cached, don't re-download
        let urlStringCat = "http://reportagdl.uperny.com/controller/categories/\(reportes [indexPath.row].categoria_img!)"
        if let imgCat = imageCache[urlStringCat] {
            cell.imgCategory.image = imgCat
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            do {
                let imageD = try UIImage(data: Data(contentsOf: URL(string: urlStringCat)!))
                self.imageCache[urlStringCat] = imageD
                // Update the cell
                DispatchQueue.main.async(execute: {
                    if let cellToUpdate = tableView.cellForRow(at: indexPath) as? ReportTableViewCell {
                        cellToUpdate.imgCategory.image = imageD
                    }
                })
            } catch {
                print("Error -> \(error)")
            }
        }
        //SUBCATEGORY
        // If this image is already cached, don't re-download
        let urlStringSub = "http://reportagdl.uperny.com/controller/categories/\(reportes [indexPath.row].subcategoria_img!)"
        if let imgSub = imageCache[urlStringSub] {
            cell.imgSubcategory.image = imgSub
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            do {
                let imageD = try UIImage(data: Data(contentsOf: URL(string: urlStringSub)!))
                self.imageCache[urlStringSub] = imageD
                // Update the cell
                DispatchQueue.main.async(execute: {
                    if let cellToUpdate = tableView.cellForRow(at: indexPath) as? ReportTableViewCell {
                        cellToUpdate.imgSubcategory.image = imageD
                    }
                })
            } catch {
                print("Error -> \(error)")
            }
        }
        //PHOTO
        // If this image is already cached, don't re-download
        let urlStringPhoto = "http://reportagdl.uperny.com/controller/fotosreportes/\(reportes [indexPath.row].incidencia_foto!)"
        if let imgPhoto = imageCache[urlStringPhoto] {
            cell.imgReport.image = imgPhoto
        }
        else {
            // The image isn't cached, download the img data
            // We should perform this in a background thread
            do {
                let imageD = try UIImage(data: Data(contentsOf: URL(string: urlStringPhoto)!))
                self.imageCache[urlStringPhoto] = imageD
                // Update the cell
                DispatchQueue.main.async(execute: {
                    if let cellToUpdate = tableView.cellForRow(at: indexPath) as? ReportTableViewCell {
                        cellToUpdate.imgReport.image = imageD
                    }
                })
            } catch {
                print("Error -> \(error)")
            }
        }
        
        cell.lblReportDate.text = reportes [indexPath.row].incidencia_fecha
        cell.lblReportSolvedDate.text = reportes [indexPath.row].incidencia_fecha_res
        if(reportes [indexPath.row].id_status != 6){
            cell.btnRate.isHidden = true
            cell.rating.settings.updateOnTouch = false
        } else {
            cell.btnRate.isHidden = false
            cell.rating.settings.updateOnTouch = true
        }
        
        cell.rating.rating = Double(reportes [indexPath.row].calificacion)
        
        cell.btnRate.addTarget(self, action: #selector(Reportes.calificar), for: .touchUpInside)
        return cell
    }
    
    func calificar(sender: UIButton){
        
        let cell = sender.superview?.superview as! ReportTableViewCell
        
        if (cell.rate <= 0){
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Cuidado", message: "Selecciona la cantidad de estrellas que le quieres asignar a la solucion", preferredStyle: .alert)
            
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                action in print("")
            }
            alert.addAction(action)
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        } else {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Calificar", message: "Comenta qué te pareció la solución", preferredStyle: .alert)
            
            //2. Add the text field. You can configure it however you need.
            alert.addTextField { (textField) in
                textField.text = ""
                textField.keyboardType = UIKeyboardType.default
                textField.spellCheckingType = UITextSpellCheckingType.default
            }
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                
                self.loading.startAnimating()
                
                let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
                let comment = textField?.text!
                let id = cell.id_incidencia
                let rate = cell.rate
                let user = UserDefaults.standard.string(forKey: "UserID")!
                
                let JSONObject: [String : AnyObject] = [
                    "id" : id as AnyObject,
                    "comment" : comment! as AnyObject,
                    "rate" : rate as AnyObject,
                    "userid" : user as AnyObject
                ]
                
                do {
                    
                    let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
                    
                    // create post request
                    let url = NSURL(string: "http://reportagdl.uperny.com/controller/rate_incidence.php")!
                    
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
                            
                            if let parseJSON = result { //json.count > 0 {
                                let resultValue = parseJSON["estado"] as? Int
                                
                                if(resultValue == 1) {
                                    
                                    DispatchQueue.main.async(execute: {
                                        
                                        self.loading.stopAnimating()
                                        
                                        cell.rating.settings.updateOnTouch = false
                                        cell.btnRate.isHidden = true
                                        
                                        self.reportes[(self.tableViewIncidences.indexPath(for: cell)?.row)!].calificacion = rate
                                        self.reportes[(self.tableViewIncidences.indexPath(for: cell)?.row)!].id_status = 7 //Evaluated
                                        
                                        let alert = UIAlertController(title: "Éxito", message: "El comentario y la calificación se agregaron correctamente", preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    });
                                    
                                } else {
                                    DispatchQueue.main.async(execute: {
                                        
                                        self.loading.stopAnimating()
                                        
                                        let mensaje = parseJSON["mensaje"] as? String
                                        let alert = UIAlertController(title: "Error", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                        self.present(alert, animated: true, completion: nil)
                                    });
                                }
                                
                            }
                            
                        } catch {
                            print("Error -> \(error)")
                            self.loading.stopAnimating()
                        }
                    }
                    
                    task.resume()
                } catch {
                    print(error)
                    self.loading.stopAnimating()
                }
                
            }))
            
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
    }
}

class Reporte {
    let id_incidencia: Int!
    var id_status: Int!
    let incidencia_descripcion: String!
    let categoria_img: String!
    let subcategoria_img: String!
    let incidencia_foto: String!
    let incidencia_fecha: String!
    let incidencia_fecha_res: String!
    var calificacion: Int!
    
    init(id_incidencia: Int, id_status: Int, incidencia_descripcion: String, categoria_img: String, subcategoria_img: String, incidencia_foto: String, incidencia_fecha: String, incidencia_fecha_res: String, calificacion: Int){
        self.id_incidencia = id_incidencia
        self.id_status = id_status
        self.incidencia_descripcion = incidencia_descripcion
        self.categoria_img = categoria_img
        self.subcategoria_img = subcategoria_img
        self.incidencia_foto = incidencia_foto
        self.incidencia_fecha = incidencia_fecha
        self.incidencia_fecha_res = incidencia_fecha_res
        self.calificacion = calificacion
    }
}
