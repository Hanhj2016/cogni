//
//  comment_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-31.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class comment_cell: UITableViewCell {

    @IBOutlet weak var profile_picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var content: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
