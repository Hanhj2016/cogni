//
//  info_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-09.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class info_cell: UITableViewCell {

    @IBOutlet weak var profile_picture: UIImageView!
    
   
    @IBOutlet weak var info: UITextView!
    
    @IBOutlet weak var image_height: NSLayoutConstraint!
    
    @IBOutlet weak var info_height: NSLayoutConstraint!
    
    @IBOutlet weak var info_width: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            //print("done")
            textView.resignFirstResponder()
        }
        return true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
