//
//  guanzhu_cell.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-13.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class guanzhu_cell: UITableViewCell {

    
    
    @IBOutlet weak var profile_picture: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var guanzhu: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
