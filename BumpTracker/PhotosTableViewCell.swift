//
//  PhotosTableViewCell.swift
//  BumpTracker
//
//  Created by Garrett Cox on 4/10/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit

class PhotosTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
