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

import Foundation
import AWSCognitoIdentityProvider

class SignUpViewController: UIViewController {
    
    var pool: AWSCognitoIdentityUserPool?
    var sentTo: String?
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var email: UITextField!
    
    
    @IBOutlet weak var signUp: UIButton!
   @IBOutlet weak var confirm: UITextField!
    
    @IBOutlet weak var head_label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
         self.view.addBackground()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        // text box colour
        // label
        // text format
        self.username.attributedPlaceholder = NSAttributedString(string: "用户名",
                                                                 attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:colour])
        self.password.attributedPlaceholder = NSAttributedString(string: "密码",
                                                                 attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:colour])
        self.phone.attributedPlaceholder = NSAttributedString(string: "手机号",
                                                              attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:colour])
        self.email.attributedPlaceholder = NSAttributedString(string: "邮箱",
                                                              attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:colour])
        self.confirm.attributedPlaceholder = NSAttributedString(string: "再次输入",
                                                                attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:colour])
        
         self.username.textColor = colour
        self.password.textColor = colour
        self.phone.textColor = colour
        self.email.textColor = colour
    self.confirm.textColor = colour
      self.head_label.textColor = colour
        self.confirm.isSecureTextEntry = true
        self.confirm.setBottomBorder()
        self.username.setBottomBorder()
        self.password.setBottomBorder()
        self.phone.setBottomBorder()
        self.email.setBottomBorder()
        
        self.signUp.backgroundColor = colour
        self.signUp.setTitleColor(sign_in_colour, for:.normal)
        
        
        //nagigation bar
        self.navigationController?.navigationBar.tintColor = colour
        self.navigationController?.navigationBar.barTintColor = sign_in_colour
        self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName:colour] as [NSAttributedStringKey : Any]
        
       // self.navigationController?.navigationItem.title = ""
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        if let signUpConfirmationViewController = segue.destination as? ConfirmSignUpViewController {
            signUpConfirmationViewController.sentTo = self.sentTo
            signUpConfirmationViewController.user = self.pool?.getUser(self.username.text!)
        }
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        
        guard let userNameValue = self.username.text, !userNameValue.isEmpty,
            let passwordValue = self.password.text, !passwordValue.isEmpty else {
                let alertController = UIAlertController(title: "Missing Required Fields",
                                                        message: "Username / Password are required for registration.",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
        }
        
        guard let confirm_value = self.confirm.text, !confirm_value.isEmpty,
            let password_value = self.password.text, confirm_value == password_value else {
                let alertController = UIAlertController(title: "嘿嘿嘿",
                                                        message: "两次密码输入不相同",
                                                        preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion:  nil)
                return
        }
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        
        if let phoneValue = self.phone.text, !phoneValue.isEmpty {
            let phone = AWSCognitoIdentityUserAttributeType()
            phone?.name = "phone_number"
            phone?.value = phoneValue
            attributes.append(phone!)
        }
        
        if let emailValue = self.email.text, !emailValue.isEmpty {
            let email = AWSCognitoIdentityUserAttributeType()
            email?.name = "email"
            email?.value = emailValue
            attributes.append(email!)
        }
        
        
        
        //sign up the user
        self.pool?.signUp(userNameValue, password: passwordValue, userAttributes: attributes, validationData: nil).continueWith {[weak self] (task) -> Any? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                    alertController.addAction(retryAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else if let result = task.result  {
                    // handle the case where user has to confirm his identity via email / SMS
                    if (result.user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed) {
                        strongSelf.sentTo = result.codeDeliveryDetails?.destination
                        strongSelf.performSegue(withIdentifier: "confirmSignUpSegue", sender:sender)
                    } else {
                        let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                    }
                }
                
            })
            return nil
        }
    }
}
