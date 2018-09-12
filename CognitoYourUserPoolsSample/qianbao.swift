//
//  qianbao.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-30.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class qianbao: UIViewController {

    @IBOutlet weak var qianbao1: UIImageView!
    
    @IBOutlet weak var title1: UILabel!
    @IBOutlet weak var number1: UILabel!
    
    @IBOutlet weak var avail_label: UILabel!
    
    @IBOutlet weak var frozen_label: UILabel!
    var number = 0.0
    var frozen = 0.0
    var avail = 0.0
    override func viewDidLoad() {
        super.viewDidLoad()
self.view.backgroundColor = mid
        qianbao1.layer.cornerRadius = 5.0
        self.title1.textColor = qianbao_colour
        self.title1.text = "糖果币 CC"
        self.title1.font = self.title1.font.withSize(17)
        
        self.number1.font = self.number1.font.withSize(30)
        self.number1.text = String(number)
        self.number1.textColor = qianbao_colour
        
        self.frozen_label.font = self.frozen_label.font.withSize(17)
        self.frozen_label.text = "冻结：  " + String(frozen)
        self.frozen_label.textColor = qianbao_colour
        
        self.avail_label.font = self.avail_label.font.withSize(17)
        self.avail_label.text = "可用：  " + String(avail)
        self.avail_label.textColor = qianbao_colour
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
