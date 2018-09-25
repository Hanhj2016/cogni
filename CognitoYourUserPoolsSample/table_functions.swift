//
//  table_functions.swift
//  chain
//
//  Created by xuechuan mi on 2018-09-20.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
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

func load_UserChat(key:String) -> UserChat{
    var temp:UserChat = UserChat()
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var aiya = dynamoDbObjectMapper.load(UserChat.self, hashKey: key, rangeKey:nil)
    aiya.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
        if let error = task.error as? NSError {
            print("The request failed. Error: \(error)")
        } else if let resultBook = task.result as? UserChat {
            temp = resultBook
        }
        return nil
    })
    aiya.waitUntilFinished()
    if aiya.isCancelled
    {print("cancelled")}
    if aiya.isCompleted
    {print("completed")}
    if aiya.isFaulted
    {print("faulted")}
    //print(aiya.result)
    return temp
}
