//
//  fabu_unit.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-04.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
import Foundation
import AWSDynamoDB
import AWSAuthUI
import AWSAuthCore
import AWSMobileClient
import AWSUserPoolsSignIn
import AWSS3
import Foundation
import UIKit
import AWSDynamoDB


@objcMembers
@objc(Posts)
class ChanceWithValue: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _bonus: NSNumber?
    var _bonusType: String?
    var _commentIdList: [String]?
    var _commentNumber: NSNumber?
    var _getList: [String]?
    var _liked: [String]?
    var _pictures: [String]?
    var _profilePicture: String?
    var _reward: NSNumber?
    var _rewardType: String?
    var _shared: NSNumber?
    var _sharedFrom: [String]?
    var _tag: NSNumber?
    var _text: String?
    var _time: NSNumber?
    var _title: String?
    var _username: String?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-ChanceWithValue"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_id"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_id" : "Id",
            "_bonus" : "bonus",
            "_bonusType" : "bonus_type",
            "_commentIdList" : "commentIdList",
            "_commentNumber" : "commentNumber",
            "_getList" : "getList",
            "_liked" : "liked",
            "_pictures" : "pictures",
            "_profilePicture" : "profile_picture",
            "_reward" : "reward",
            "_rewardType" : "reward_type",
            "_shared" : "shared",
            "_sharedFrom" : "sharedFrom",
            "_tag" : "tag",
            "_text" : "text",
            "_time" : "time",
            "_title" : "title",
            "_username" : "username",
        ]
    }


    
    func create() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let newsItem: ChanceWithValue = ChanceWithValue()
        let username: String? = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        let un: String = username!
        print (un)
        newsItem._id = "init"
        newsItem._time = 0
        newsItem._username = un
        //newsItem._comments = 0
        //Save a new item
        dynamoDbObjectMapper.save(newsItem, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
    }
    
}
