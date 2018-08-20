//
//  chat_message_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-19.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class chat_message_cell: UITableViewCell {

    

    @IBOutlet weak var profile_picture: UIImageView!
  
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var last_sentence: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var notification: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
