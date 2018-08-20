//
//  message_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-19.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class message_cell: UITableViewCell {

    
    @IBOutlet weak var message: UILabel!
    
    @IBOutlet weak var icon: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
