//
//  TzeisNotificationTableViewCell.swift
//  Sefirah
//
//  Created by Josh Siegel on 5/2/16.
//  Copyright © 2016 Josh Siegel. All rights reserved.
//

import UIKit

class TzeisNotificationTableViewCell: UITableViewCell {

    var tzeisNotification: Tzeis?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let activeNotifications = UserDefaults.standard.array(forKey: "Tzeis") as! [Double]
        let rawValue = tzeisNotification!.rawValue
        if activeNotifications.contains(rawValue) {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
