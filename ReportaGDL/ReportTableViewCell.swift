//
//  ReportTableViewCell.swift
//  ReportaGDL
//
//  Created by Tona on 15/11/16.
//  Copyright © 2016 ARHR. All rights reserved.
//

import UIKit

class ReportTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgReport: UIImageView!
    @IBOutlet weak var lblReportNumber: UILabel!
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var imgSubcategory: UIImageView!
    @IBOutlet weak var lblReportDate: UILabel!
    @IBOutlet weak var lblReportSolvedDate: UILabel!
    @IBOutlet weak var reportDescription: UITextView!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var btnRate: UIButton!
    
    var rate = 0
    var id_incidencia = -1
    var incidencia_status = -1
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        btnRate.layer.cornerRadius = 5
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        rating.didFinishTouchingCosmos = { rating in
            self.rate = Int(rating)
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func rateTapped(_ sender: AnyObject) {
        print("\(rate)")
        
    }
    

}
