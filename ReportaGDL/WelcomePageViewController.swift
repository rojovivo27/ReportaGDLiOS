//
//  WelcomePageViewController.swift
//  ReportaGDL
//
//  Created by Tona on 13/10/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class WelcomePageViewController: UIViewController, UIPageViewControllerDataSource {
    
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    var pageViewController: UIPageViewController!
    var pageDescriptions: NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        loginBtn.layer.cornerRadius = 5
        
        registerBtn.layer.cornerRadius = 5
        
        self.pageDescriptions = NSArray(objects:
            "Reporta GDL es una plataforma de colaboración donde ayudarás a tener una mejor calidad de vida."
            ,"Aquí podrás reportar de manera fácil y rápida cualquier incidente"
            ,"Además podrás calificar la solución al problema dando tu punto de vista de la solución implementada."
            ,"Ayúdanos a mejorar el entorno, Reporta GDL")
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as! UIPageViewController
        self.pageViewController.dataSource = self
        let startVC = self.viewControllerAtIndex(index: 0) as ContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        
        
        self.addChildViewController(self.pageViewController)
        self.view.addSubview(self.pageViewController.view)
        self.pageViewController.didMove(toParentViewController: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.pageViewController.view.frame = CGRect(x: 0, y: registerBtn.frame.origin.y - 120, width: self.view.frame.width, height: 120)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.pageViewController.view.frame = CGRect(x: 0, y: registerBtn.frame.origin.y - 120, width: self.view.frame.width, height: 120)
        
        self.navigationController?.isNavigationBarHidden = true
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
    
    func viewControllerAtIndex(index: Int) -> ContentViewController {
        if((self.pageDescriptions.count == 0) || (index >= self.pageDescriptions.count)){
            return ContentViewController()
        }
        
        let vc: ContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as! ContentViewController
        
        vc.descText = self.pageDescriptions[index] as! String
        vc.pageIndex = index
        return vc
        
    }
    

    /*
    // MARK: - Page View Controller Data Source

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if ((index == 0) || (index == NSNotFound)){
            return nil
        }
        index -= 1
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let vc = viewController as! ContentViewController
        var index = vc.pageIndex as Int
        
        if (index == NSNotFound){
            return nil
        }
        index += 1
        if (index == self.pageDescriptions.count){
            return nil
        }
        
        return self.viewControllerAtIndex(index: index)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return self.pageDescriptions.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    

}
