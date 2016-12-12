//
//  PageContentViewController.swift
//  ReportaGDL
//
//  Created by Tona on 13/10/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class ContentViewController: UIViewController {

    @IBOutlet weak var lblDescription: UILabel!
    
    var pageIndex: Int!
    var descText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.lblDescription.text = self.descText
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
