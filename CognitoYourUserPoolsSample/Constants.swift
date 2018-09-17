//
// Copyright 2014-2018 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//
import AWSS3
import Foundation
import AWSCognitoIdentityProvider

let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1_OyEPKqrHG"
let CognitoIdentityUserPoolAppClientId = "1topa7t6d5nspmikm8tpbdp7bt"
let CognitoIdentityUserPoolAppClientSecret = "18ijf5nnejosukdfgu2u0208ko63opah0c804ef88thq89pusq58"
let pictures = "chance-userfiles-mobilehub-653619147"



let AWSCognitoUserPoolsSignInProviderKey = "UserPool"
let colour: UIColor = UIColor(red: CGFloat((0xffd978 & 0xFF0000) >> 16) / 255.0,
                              green: CGFloat((0xffd978 & 0x00FF00) >> 8) / 255.0,
                              blue: CGFloat(0xffd978 & 0x0000FF) / 255.0,
                              alpha: CGFloat(1.0))

let qianbao_colour: UIColor = UIColor(red: CGFloat((0x483b1b & 0xFF0000) >> 16) / 255.0,
                              green: CGFloat((0x483b1b & 0x00FF00) >> 8) / 255.0,
                              blue: CGFloat(0x483b1b & 0x0000FF) / 255.0,
                              alpha: CGFloat(1.0))

let sign_in_colour: UIColor = UIColor(red: CGFloat((0x191d26 & 0xFF0000) >> 16) / 255.0,// heavy
                                     green: CGFloat((0x191d26 & 0x00FF00) >> 8) / 255.0,
                                     blue: CGFloat(0x191d26 & 0x0000FF) / 255.0,
                                     alpha: CGFloat(1.0))

let mid: UIColor = UIColor(red: CGFloat((0x282d3c & 0xFF0000) >> 16) / 255.0,
                                      green: CGFloat((0x282d3c & 0x00FF00) >> 8) / 255.0,
                                      blue: CGFloat(0x282d3c & 0x0000FF) / 255.0,
                                      alpha: CGFloat(1.0))

let light: UIColor = UIColor(red: CGFloat((0x323848 & 0xFF0000) >> 16) / 255.0,
                                      green: CGFloat((0x323848 & 0x00FF00) >> 8) / 255.0,
                                      blue: CGFloat(0x323848 & 0x0000FF) / 255.0,
                                      alpha: CGFloat(1.0))

let text_light: UIColor = UIColor(red: CGFloat((0xffffff & 0xFF0000) >> 16) / 255.0,
                             green: CGFloat((0xffffff & 0x00FF00) >> 8) / 255.0,
                             blue: CGFloat(0xffffff & 0x0000FF) / 255.0,
                             alpha: CGFloat(1.0))

let text_mid: UIColor = UIColor(red: CGFloat((0x92a2b6 & 0xFF0000) >> 16) / 255.0,
                                  green: CGFloat((0x92a2b6 & 0x00FF00) >> 8) / 255.0,
                                  blue: CGFloat(0x92a2b6 & 0x0000FF) / 255.0,
                                  alpha: CGFloat(1.0))

let text_grey: UIColor = UIColor(red: CGFloat((0x898989 & 0xFF0000) >> 16) / 255.0,
                                green: CGFloat((0x898989 & 0x00FF00) >> 8) / 255.0,
                                blue: CGFloat(0x898989 & 0x0000FF) / 255.0,
                                alpha: CGFloat(1.0))

let blue: UIColor = UIColor(red: CGFloat((0x40a3ff & 0xFF0000) >> 16) / 255.0,
                                 green: CGFloat((0x40a3ff & 0x00FF00) >> 8) / 255.0,
                                 blue: CGFloat(0x40a3ff & 0x0000FF) / 255.0,
                                 alpha: CGFloat(1.0))
let background_grey: UIColor = UIColor(red: CGFloat((0xececec & 0xFF0000) >> 16) / 255.0,
                            green: CGFloat((0xececec & 0x00FF00) >> 8) / 255.0,
                            blue: CGFloat(0xececec & 0x0000FF) / 255.0,
                            alpha: CGFloat(1.0))

let input_background_grey: UIColor = UIColor(red: CGFloat((0xf9f9f9 & 0xFF0000) >> 16) / 255.0,
                                       green: CGFloat((0xf9f9f9 & 0x00FF00) >> 8) / 255.0,
                                       blue: CGFloat(0xf9f9f9 & 0x0000FF) / 255.0,
                                       alpha: CGFloat(1.0))
let image_grey: UIColor = UIColor(red: CGFloat((0x7a7a7a & 0xFF0000) >> 16) / 255.0,
                                             green: CGFloat((0x7a7a7a & 0x00FF00) >> 8) / 255.0,
                                             blue: CGFloat(0x7a7a7a & 0x0000FF) / 255.0,
                                             alpha: CGFloat(1.0))



func uploadImage(with data: Data,bucket:String,key:String) {
    var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
    let expression = AWSS3TransferUtilityUploadExpression()
    let transferUtility = AWSS3TransferUtility.default()
    transferUtility.uploadData(
        data,
        bucket: bucket,
        key:key,
        contentType: "image/png",
        expression: expression,
        completionHandler: completionHandler).continueWith { (task) -> AnyObject! in
            if let error = task.error {
                print("Error: \(error.localizedDescription)")
            }
            return nil;
    }
}


func downloadImage(key_:String, destination:UIImageView){
    let transferUtility = AWSS3TransferUtility.default()
    let expression = AWSS3TransferUtilityDownloadExpression()
    var completionHandler: AWSS3TransferUtilityDownloadCompletionHandlerBlock?
    var end:UIImage = UIImage()
    completionHandler = { (task, url, data, error) -> Void in
        DispatchQueue.main.async(execute: {
            if let error = error {
                NSLog("Failed with error: \(error)")
                print("failed: 169: \(error)")
            }
            else{
                
                end = UIImage(data: data!)!
                set_image_cache(key: key_, image: end)
                destination.image = end
                //print("118: \(end)")
            }
        })
        
    }
    let heihei = transferUtility.downloadData(
        fromBucket: "chance-userfiles-mobilehub-653619147",
        key: key_,
        expression: expression,
        completionHandler: completionHandler)
        heihei.continueWith { (task) -> AnyObject! in
            //print("193")
            if let error = task.error {
                NSLog("Error: %@",error.localizedDescription);
                // self.statusLabel.text = "Failed"
                print("failed 191")
            }
            return nil;
    }
    heihei.waitUntilFinished()
    
   // return end
}





protocol dropDownProtocol {
    func dropDownPressed(string : String)
}

class dropDownBtn: UIButton, dropDownProtocol {
    
    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }
    
    var up = 0
    var dropView = dropDownView()
    
    var height = NSLayoutConstraint()
    
    override func removeFromSuperview() {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.darkGray
        
        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
        dropView.backgroundColor = colour
    }
    override func didMoveToSuperview() {
       // print("in superview")
        self.superview?.addSubview(dropView)
        
       // print("superview.subviews: \(superview?.subviews.count)")
        //print("superview: \(type(of:superview?.subviews))")
        
        self.superview?.bringSubview(toFront: dropView)
       // print("up: \(up)")
//        if var topController = UIApplication.shared.keyWindow?.rootViewController {
//            while let presentedViewController = topController.presentedViewController {
//                topController = presentedViewController
//            }
//
//            print(topController)
//        }
        if (superview?.subviews.count)! < 16
        {up = 1}
        if up == 0
        {dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true}
        else{
            dropView.bottomAnchor.constraint(equalTo: self.topAnchor).isActive = true}
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            
            isOpen = true
            
            NSLayoutConstraint.deactivate([self.height])
            
            if self.dropView.tableView.contentSize.height > 150 {
                self.height.constant = 150
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
            
            
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                
                if self.up == 0{
                    self.dropView.center.y += self.dropView.frame.height / 2}
                else
                {
                    self.dropView.center.y -= self.dropView.frame.height / 2}
                
            }, completion: nil)
            
        } else {
            isOpen = false
            
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                if self.up == 0{
                    self.dropView.center.y -= self.dropView.frame.height / 2}
                else
                {
                    self.dropView.center.y += self.dropView.frame.height / 2}
                self.dropView.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            if self.up == 0{
                self.dropView.center.y -= self.dropView.frame.height / 2}
            else
            {
                self.dropView.center.y += self.dropView.frame.height / 2}
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkGray
        
        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
        dropView.backgroundColor = colour
    }
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    
    var dropDownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : dropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = colour
        self.backgroundColor = colour
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = colour
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
     //   print("288")
        cell.textLabel?.text = dropDownOptions[indexPath.row]
       cell.textLabel?.font = cell.textLabel?.font.withSize(14)
        cell.textLabel?.textColor = sign_in_colour
        cell.backgroundColor = colour
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      //   print("290")
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




