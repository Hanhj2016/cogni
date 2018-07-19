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
