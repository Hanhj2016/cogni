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
import UIKit
import AWSAuthUI
import AWSAuthCore
import AWSMobileClient
import AWSUserPoolsSignIn
import AWSS3




class SignInViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    var usernameText: String?

    var show_pass: Bool!
    
    @IBOutlet weak var forget_password: UIButton!
    @IBOutlet weak var sign_up: UIButton!
    
    @IBOutlet weak var facebook: UIButton!
    @IBOutlet weak var wechat: UIButton!
    @IBOutlet weak var weibo: UIButton!
    @IBOutlet weak var sign_in: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        show_pass = true
        self.view.addBackground()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.username.text = "用户名"
        self.username.attributedPlaceholder = NSAttributedString(string: "用户名",
                                                               attributes: [NSForegroundColorAttributeName:colour])
        self.password.attributedPlaceholder = NSAttributedString(string: "密码",
                                                                 attributes: [NSForegroundColorAttributeName:colour])
        self.username.textColor = colour
        self.password.textColor = colour
        self.weibo.setImage(UIImage(named: "weibo"), for: .normal)
        self.wechat.setImage(UIImage(named: "weixin"), for: .normal)
        self.facebook.setImage(UIImage(named: "facebook"), for: .normal)
        self.forget_password.tintColor = colour
        self.sign_up.tintColor = colour
        self.sign_in.backgroundColor = colour
        self.sign_in.setTitleColor(sign_in_colour, for:.normal)
        self.username.setBottomBorder()
        self.password.setBottomBorder()
        //self.navigationController?.navigationItem.title = ""
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    

    @IBAction func show_password(_ sender: UIButton) {
        if(show_pass == true) {
            self.password.isSecureTextEntry = false
            show_pass = false
        } else {
            self.password.isSecureTextEntry = true
            show_pass = true
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem // This will show in the next view controller being pushed
    }
    
    
    @IBAction func signInPressed(_ sender: AnyObject) {
    
        if (self.username.text != nil && self.password.text != nil) {
            //print(self.username.text)
            let authDetails = AWSCognitoIdentityPasswordAuthenticationDetails(username: self.username.text!, password: self.password.text! )
            self.passwordAuthenticationCompletion?.set(result: authDetails)
           // print("38")
        } else {
            let alertController = UIAlertController(title: "Missing information",
                                                    message: "Please enter a valid user name and password",
                                                    preferredStyle: .alert)
            let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
            alertController.addAction(retryAction)
        }
    }
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    public func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
        DispatchQueue.main.async {
            if (self.usernameText == nil) {
                self.usernameText = authenticationInput.lastKnownUsername
            }
        }
    }
    
    public func didCompleteStepWithError(_ error: Error?) {
        DispatchQueue.main.async {
            if let error = error as NSError? {
                let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                        message: error.userInfo["message"] as? String,
                                                        preferredStyle: .alert)
                let retryAction = UIAlertAction(title: "Retry", style: .default, handler: nil)
                alertController.addAction(retryAction)
                
                self.present(alertController, animated: true, completion:  nil)
            } else {
                self.username.text = nil
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}





