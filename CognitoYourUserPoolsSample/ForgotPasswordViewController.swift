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

class ForgotPasswordViewController: UIViewController,UITextFieldDelegate {
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    
    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var forgotpassword: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addBackground()
        self.username.delegate = self
        self.hideKeyboardWhenTappedAround()
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    override func viewWillAppear(_ animated: Bool) {
        self.username.textColor = colour
       self.username.add_placeholder(text: "用户名", color: colour)
        self.username.setBottomBorder()
        
        
        self.forgotpassword.backgroundColor = colour
        self.forgotpassword.setTitleColor(sign_in_colour, for:.normal)
        
        
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let newPasswordViewController = segue.destination as? ConfirmForgotPasswordViewController {
            newPasswordViewController.user = self.user
        }
    }
    
    // MARK :- IBActions
    
    // handle forgot password
    @IBAction func forgotPassword(_ sender: AnyObject) {
        guard let username = self.username.text, !username.isEmpty else {

            let alertController = UIAlertController(title: "用户名错误",
                                                    message: "用户名不存在",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        self.user = self.pool?.getUser(self.username.text!)
        self.user?.forgotPassword().continueWith{[weak self] (task: AWSTask) -> AnyObject? in
            guard let strongSelf = self else {return nil}
            DispatchQueue.main.async(execute: {
                if let error = task.error as NSError? {
                    let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                        message: error.userInfo["message"] as? String,
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    alertController.addAction(okAction)
                    
                    self?.present(alertController, animated: true, completion:  nil)
                } else {
                    strongSelf.performSegue(withIdentifier: "confirmForgotPasswordSegue", sender: sender)
                }
            })
            return nil
            } 
    }
}
