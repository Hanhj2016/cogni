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

class ConfirmForgotPasswordViewController: UIViewController {
    
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var confirmationCode: UITextField!
    @IBOutlet weak var proposedPassword: UITextField!
    
    @IBOutlet weak var confirm: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.confirmationCode.textColor = colour
        self.confirmationCode.attributedPlaceholder = NSAttributedString(string: "验证码",
                                                                 attributes: [NSForegroundColorAttributeName:colour])
        self.confirmationCode.setBottomBorder()
        self.proposedPassword.isSecureTextEntry = true
        self.proposedPassword.textColor = colour
        self.proposedPassword.attributedPlaceholder = NSAttributedString(string: "新密码",
                                                                         attributes: [NSForegroundColorAttributeName:colour])
        self.proposedPassword.setBottomBorder()
        
        self.confirm.backgroundColor = colour
        self.confirm.setTitleColor(sign_in_colour, for:.normal)
        
        
        self.navigationController?.navigationBar.tintColor = colour
        self.navigationController?.navigationBar.barTintColor = sign_in_colour
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:colour]
        
        // self.navigationController?.navigationItem.title = ""
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    // MARK: - IBActions
    
    @IBAction func updatePassword(_ sender: AnyObject) {
        guard let confirmationCodeValue = self.confirmationCode.text, !confirmationCodeValue.isEmpty else {
            let alertController = UIAlertController(title: "Password Field Empty",
                                                    message: "Please enter a password of your choice.",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        //confirm forgot password with input from ui.
        self.user?.confirmForgotPassword(confirmationCodeValue, password: self.proposedPassword.text!).continueWith {[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else { return nil }
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                            message: error.userInfo["message"] as? String,
                                                            preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    let _ = strongSelf.navigationController?.popToRootViewController(animated: true)
                }
            })
            return nil
        }
    }
    
}
