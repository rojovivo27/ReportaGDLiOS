//
//  AboutViewController.swift
//  ReportaGDL
//
//  Created by Tona on 23/11/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    
    @IBAction func aldoTapped(_ sender: AnyObject) {
        tryURL(urls: [
            "fb://profile/aldo.hernandez.7165", // App
            "http://www.facebook.com/aldo.hernandez.7165" // Website if app fails
            ])
    }
    @IBAction func charlyTapped(_ sender: AnyObject) {
        tryURL(urls: [
            "fb://profile/carlos.serna.s", // App
            "http://www.facebook.com/carlos.serna.s" // Website if app fails
            ])
    }
    @IBAction func tonaTapped(_ sender: AnyObject) {
        tryURL(urls: [
            "fb://profile/tonaNav", // App
            "http://www.facebook.com/tonaNav" // Website if app fails
            ])
    }
    @IBAction func arturoTapped(_ sender: AnyObject) {
        tryURL(urls: [
            "fb://profile/arturo.g.resendiz", // App
            "http://www.facebook.com/arturo.g.resendiz" // Website if app fails
            ])
    }
    
    func tryURL(urls: [String]) {
        let application = UIApplication.shared
        for url in urls {
            if application.canOpenURL(NSURL(string: url)! as URL) {
                application.openURL(NSURL(string: url)! as URL)
                //application.open(NSURL(string: url)! as URL, options: [:], completionHandler: nil)
                return
            }
        }
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
