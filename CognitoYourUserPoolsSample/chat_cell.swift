//
//  chat_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-14.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class chat_cell: UITableViewCell {

    @IBOutlet weak var profile_picture: UIImageView!
    
    @IBOutlet weak var profile_picture_left: NSLayoutConstraint!
    
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var profile_picture_top: NSLayoutConstraint!
    
    @IBOutlet weak var chat_width: NSLayoutConstraint!
    @IBOutlet weak var chat_top: NSLayoutConstraint!
    
    @IBOutlet weak var chat: UITextView!
    @IBOutlet weak var chat_left_to_image_right: NSLayoutConstraint!
    @IBOutlet weak var chat_height: NSLayoutConstraint!
    
    @IBOutlet weak var picture: UIImageView!
    
    
    var show_time = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
