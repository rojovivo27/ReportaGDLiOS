//
//  ViewController.swift
//  ReportaGDL
//
//  Created by Tona on 12/10/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit
import GoogleMaps

class MainViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    
    var latitude = 0.0
    var longitude = 0.0
    
    var userLatitude = 0.0
    var userLongitude = 0.0
    
    let latGDL = 20.6770371//20.7419849 CUCEA
    let lonGDL = -103.3470154//-103.3801782 CUCEA
    
    let incidenceMarker = GMSMarker()
    
    var incidents  = [GMSMarker]()
    
    var marksSet = false
    
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    //Blur
    @IBOutlet weak var blurImage: UIImageView!
    
    
    //Buttons
    
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var lblMensaje: UILabel!
    
    
    //Maps
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btnCancel.isHidden = true
        btnAccept.isHidden = true
        lblMensaje.isHidden = true
        
        btnCancel.layer.cornerRadius = 5
        btnAccept.layer.cornerRadius = 5
        
        
        self.navigationController?.navigationBar.isTranslucent = true
        //0391FD
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 3/255, green: 145/255, blue: 253/255, alpha: 1)]

        
        mapView.delegate = self
        mapView.padding = UIEdgeInsetsMake(0, 0, 80, 0)
        mapView.setMinZoom(10, maxZoom: 20)
        
        //Maps Stuff
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        //marker
        incidenceMarker.appearAnimation = kGMSMarkerAnimationPop
        incidenceMarker.icon = UIImage(named: "iconPin")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Check if login exist
        let login = (UserDefaults.standard.value(forKey: "Login")) as! Bool
        if(!login){
            performSegue(withIdentifier: "WelcomePage", sender: self)
        } else {
            marksSet = false
        }
        
        
        
        UIApplication.shared.statusBarStyle = .default
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        }
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.tintColor = UIColor(red: 3/255, green: 145/255, blue: 253/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 3/255, green: 145/255, blue: 253/255, alpha: 1.0)]
        
        // Transparent navigation bar
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        // Add blur view NavCont
        let bounds = self.navigationController?.navigationBar.bounds as CGRect!
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds!
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        visualEffectView.tag = 182
        self.navigationController?.navigationBar.insertSubview(visualEffectView, at: 0)
        
        // Here you can add visual effects to any UIView control.
        // Replace custom view with navigation bar in above code to add effects to custom view.
        //Blur
        let barBounds = self.blurImage.bounds as CGRect!
        let barVisualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        barVisualEffectView.frame = barBounds!
        barVisualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurImage.addSubview(barVisualEffectView)
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        UIApplication.shared.statusBarStyle = .default
        
        //Remove Blur
        self.navigationController?.navigationBar.viewWithTag(182)?.removeFromSuperview()
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        let newIncidence = UserDefaults.standard.value(forKey: "newIncidence") as! Bool
        let login = (UserDefaults.standard.value(forKey: "Login")) as! Bool
        if(newIncidence && login && !marksSet){
            setMarks()
            marksSet = true
            UserDefaults.standard.set(false, forKey: "newIncidence")
        }
        
    }
    
    
    func generateButtons() -> [ALRadialMenuButton] {
        
        var buttons = [ALRadialMenuButton]()
        
        /*
        let buttonMain = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        buttonMain.setImage(UIImage(named: "Config"), for: UIControlState.normal)
        buttonMain.action = {
            print("Home")
            self.marker.opacity = 0
        };
        buttons.append(buttonMain)
        */
        
        let buttonNuevoReporte = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        buttonNuevoReporte.setImage(UIImage(named: "Report"), for: UIControlState.normal)
        buttonNuevoReporte.action = {
            print("Nuevo Reporte")
            //marker
            self.incidenceMarker.position = CLLocationCoordinate2DMake(self.mapView.camera.target.latitude, self.mapView.camera.target.longitude)
            self.incidenceMarker.map = self.mapView
            self.btnCancel.isHidden = false
            self.btnAccept.isHidden = false
            self.lblMensaje.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                // Put your code which should be executed with a delay here
                self.btnMenu.isHidden = true
            })
            
        };
        buttons.append(buttonNuevoReporte)
        
        let buttonReportes = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        buttonReportes.setImage(UIImage(named: "ReportesIcon"), for: UIControlState.normal)
        buttonReportes.action = {
            print("Reportes")
            
            self.performSegue(withIdentifier: "rate", sender: self)
        };
        buttons.append(buttonReportes)
        
        let buttonAbout = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        buttonAbout.setImage(UIImage(named: "AboutIcon"), for: UIControlState.normal)
        buttonAbout.action = {
            print("About")
            
            self.performSegue(withIdentifier: "about", sender: self)
        };
        buttons.append(buttonAbout)
        
        let buttonLogout = ALRadialMenuButton(frame: CGRect(x: 0, y: 0, width: 32, height: 32))
        buttonLogout.setImage(UIImage(named: "Exit"), for: UIControlState.normal)
        buttonLogout.action = {
            UserDefaults.standard.set(false, forKey: "Login")
            self.performSegue(withIdentifier: "WelcomePage", sender: self)
        };
        buttons.append(buttonLogout)
        
        return buttons
    }
    
    @IBAction func showMenu(_ sender: AnyObject) {
        let s = sender as! UIView
        _ = ALRadialMenu()
            .setButtons(buttons: generateButtons())
            .setDelay(delay: 0.05)
            .setAnimationOrigin(animationOrigin:  CGPoint(x: s.center.x, y: s.center.y + 20))
            .setRadius(radius: 45)
            .setCircumference(degrees: 180)
            .setStartAngle(degrees: 180)
            //.setOverlayViewAppeareance(color: UIColor(red: 0, green: 0, blue: 0, alpha: 0.7))
            .hideMenuButtonWhenShowingButtons(hide: true)
            .presentInView(view: view, senderButton: sender as! UIView)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 18, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            
            userLatitude = location.coordinate.latitude
            userLongitude = location.coordinate.longitude
            
            let login = (UserDefaults.standard.value(forKey: "Login")) as! Bool
            if(login && !marksSet){
                setMarks()
                marksSet = true
                print("MARKS")
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        //Address
        //reverseGeocodeCoordinate(coordinate: position.target)
        self.latitude = position.target.latitude
        self.longitude = position.target.longitude
        self.incidenceMarker.position = CLLocationCoordinate2DMake(self.latitude, self.longitude)
    }
    
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoView = Bundle.main.loadNibNamed("CustomInfo", owner: self, options: nil)?[0] as! InfoView
        infoView.title.text = marker.title
        infoView.desc.text = marker.snippet
        infoView.image.image = marker.userData as? UIImage
        return infoView
    }
    
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        btnCancel.isHidden = true
        btnAccept.isHidden = true
        lblMensaje.isHidden = true
        btnMenu.isHidden = false
        
        incidenceMarker.map = nil
    }
    
    @IBAction func acceptTapped(_ sender: AnyObject) {
        
        let locationCUCEA = CLLocation(latitude: latGDL, longitude: lonGDL)
        let locationReport = CLLocation(latitude: self.latitude, longitude: self.longitude)
        let distance = locationCUCEA.distance(from: locationReport)
        
        print(distance)
        
        if (distance < 12000) {
            btnCancel.isHidden = true
            btnAccept.isHidden = true
            lblMensaje.isHidden = true
            btnMenu.isHidden = false
            
            incidenceMarker.map = nil
            
            DispatchQueue.main.async(execute: {
                self.performSegue(withIdentifier: "formulario", sender: self)
            })
        } else {
            //1. Create the alert controller.
            let alert = UIAlertController(title: "Cuidado", message: "Tienes que seleccionar un área dentro de la zona metropolitana", preferredStyle: .alert)
            // 3. Grab the value from the text field, and print it when the user clicks OK.
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) {
                action in print("")
            }
            alert.addAction(action)
            // 4. Present the alert.
            self.present(alert, animated: true, completion: nil)
        }
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "formulario" {
            let form = segue.destination as! NewReport
            form.latitude = self.latitude
            form.longitude = self.longitude
        }
        
        let backItem = UIBarButtonItem()
        backItem.title = "Atras"
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
        
    }
    
    func setMarks() {
        
        loading.startAnimating()
        
        mapView.clear()
        
        //MARK: Getting Incidences
        //Coleccion de maximo 10 incidentes creados
        incidents = [GMSMarker]()
        
        let JSONObject: [String : AnyObject] = [
            "lat" : userLatitude as AnyObject,
            "lon" : userLongitude as AnyObject
        ]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: JSONObject, options: .prettyPrinted)
            
            // create post request
            let url = NSURL(string: "http://reportagdl.uperny.com/controller/get_incidences_by_coordinates.php")!
            
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
                    let result = try JSONSerialization.jsonObject(with: data!, options: [.allowFragments]) as? [String:AnyObject]
                    
                    if let parseJSON = result { //json.count > 0 {
                        let resultValue = parseJSON["estado"] as? Int
                        
                        if(resultValue == 1) {
                            
                            DispatchQueue.main.async(execute: {
                                self.loading.stopAnimating()
                                for incidence in (parseJSON["incidencias"] as? [[String: AnyObject]])!{
                                    let lat = Float(incidence["incidencia_lat"]! as! String)!
                                    let lon = Float(incidence["incidencia_lon"]! as! String)!
                                    let type = incidence["subcategoria_name"]! as! String
                                    let desc = incidence["incidencia_descripcion"]! as! String
                                    let foto = incidence["incidencia_foto"]! as! String
                                    
                                    var img: UIImage? = nil
                                    let imgUrl = "http://reportagdl.uperny.com/controller/fotosreportes/\(foto)"
                                    do {
                                        let imageD = try UIImage(data: Data(contentsOf: URL(string: imgUrl)!))
                                        img = imageD!
                                    } catch {
                                        print("Error -> \(error)")
                                    }
                                    
                                    
                                    //mark
                                    let mark = GMSMarker()
                                    mark.appearAnimation = kGMSMarkerAnimationPop
                                    mark.title = "\(type)"
                                    mark.snippet = "\(desc)"
                                    mark.position = CLLocationCoordinate2DMake(CLLocationDegrees(lat), CLLocationDegrees(lon))
                                    mark.userData = img
                                    mark.infoWindowAnchor = CGPoint(x: 0.5, y: 1.0)
                                    mark.map = self.mapView
                                    
                                    self.incidents.append(mark)
                                }
                            })
                            
                        } else {
                            DispatchQueue.main.async(execute: {
                                self.loading.stopAnimating()
                            })
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
    }
    
    func displayAlertMessage(_ title: String, userMessage : String, action : UIAlertAction){
        let myAlert = UIAlertController(title: title, message: userMessage, preferredStyle: UIAlertControllerStyle.alert)
        
        myAlert.addAction(action)
        
        self.present(myAlert, animated: true, completion: nil)
    }
    
    func buttonAction(sender: UIButton!) {
        print("Button tapped")
    }
    
    /*
    //Getting address
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
     
        let geocoder = GMSGeocoder()
     
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                
                let lines = address.lines as [String]!
                self.lblCoordinates.text = lines?.joined(separator: "\n")
                
                UIView.animate(withDuration: 0.25) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    */

}

class Incidencia {
    let lat: Float!
    let lon: Float!
    let desc: String!
    
    init(lat: Float, lon: Float, desc: String){
        self.lat = lat
        self.lon = lon
        self.desc = desc
    }
}
