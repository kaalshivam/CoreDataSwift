//
//  UserTVC.swift
//  CoreDataExampleds
//
//  Created by Shivam Sharma on 09/11/22.
//

import UIKit

class UserTVC: UITableViewCell {

    @IBOutlet weak var emailLBL: UILabel!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var numberLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
