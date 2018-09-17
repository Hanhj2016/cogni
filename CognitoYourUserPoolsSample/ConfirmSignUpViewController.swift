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

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB
import AWSMobileClient
import AWSCore
import AWSPinpoint
import Foundation
import AWSUserPoolsSignIn
import AWSS3
import Photos
import BSImagePicker
import Foundation

class ConfirmSignUpViewController : UIViewController,UITextFieldDelegate {
    
    var sentTo: String?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var sentToLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var code: UITextField!
    
    @IBOutlet weak var resend: UIButton!
    @IBOutlet weak var confirm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.username.text = self.user!.username;
        //self.sentToLabel.text = "Code sent to: \(self.sentTo!)"
        self.view.addBackground()
        self.code.delegate = self
        self.username.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.username.add_placeholder(text: "用户名".toLocal(), color: colour)
        self.code.add_placeholder(text: "验证码".toLocal(), color: colour)
        
        
        self.username.textColor = colour
        self.code.textColor = colour
        self.sentToLabel.textColor = colour
        self.resend.tintColor = colour
        
        self.username.setBottomBorder()
        self.code.setBottomBorder()
        
        self.confirm.backgroundColor = colour
        self.confirm.setTitleColor(sign_in_colour, for:.normal)
        
       
        self.navigationController?.navigationBar.isHidden = false
    }
    // MARK: IBActions
    
    // handle confirm sign up
    @IBAction func confirm(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.code.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "嘿嘿嘿".toLocal(),
                                                    message: "验证码不对啊".toLocal(),
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        self.user?.confirmSignUp(self.code.text!, forceAliasCreation: true).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    strongSelf.present(alertController, animated: true, completion:  nil)
                } else {
                    let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                    var p:UserPool = UserPool()
                    p._userId = self?.user?.username
                    p._myEmail = user_email
                    let dude = p._userId! + ".png"
                    p._profilePic = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + dude
                   
                    
                    p._shengWang = 0
                    p._candyCurrency = 0
                    p._cryptoCurrency = 0
                    p._availableWallet = 0
                    p._frozenwallet = 0
                    let date = Date()
                    let calendar = Calendar.current
                    let rand = (calendar.component(.second, from:date)) % 2
                    var pic_name = ""
                    if rand == 1
                    {
                        pic_name = "boy"
                    }
                    else
                    {
                        pic_name = "girl"
                    }
                    uploadImage(with: UIImagePNGRepresentation(UIImage(named: pic_name)!)!, bucket: pictures, key: dude)
                    dynamoDbObjectMapper.save(p,completionHandler:nil)
                    
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        }
    }
    
    // handle code resend action
    @IBAction func resend(_ sender: AnyObject) {
        self.user?.resendConfirmationCode().continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let _ = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result {
                    let alertController = UIAlertController(title: "验证码已发送".toLocal(),
                                                            message: "已发送至".toLocal() + " \(result.codeDeliveryDetails?.destination! ?? " no message")",
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    self?.present(alertController, animated: true, completion: nil)
                }
            })
            return nil
        }
    }
    
}
