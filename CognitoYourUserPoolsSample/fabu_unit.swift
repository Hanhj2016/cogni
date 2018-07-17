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
class fabu_unit{
    var title: String
    var profile_picture: String // url from s3
    var username: String
    var tag: Int
    var time: String
    var text: String
    var pictures: [String]
    var shared: Int
    var comments: Int
    var liked: Int
    var id: String
    init(title_:String,profile_picture_:String,username_:String,tag_:Int,time_:String,text_:String,pictures_:[String],shared_:Int,comments_:Int,liked_:Int,id_:String){
        title = title_
        profile_picture = profile_picture_
        username = username_
        tag = tag_
        time = time_
        text = text_
        pictures = pictures_
        shared = shared_
        comments = comments_
        liked = liked_
        id = id_
    }
}

@objcMembers
@objc(Posts)
class ChanceWithValue: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _bonus: NSNumber?
    var _bonusType: String?
    var _comments: NSNumber?
    var _liked: NSNumber?
    var _pictures: Set<String>?
    var _profilePicture: String?
    var _reward: NSNumber?
    var _rewardType: String?
    var _shared: NSNumber?
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
            "_comments" : "comments",
            "_liked" : "liked",
            "_pictures" : "pictures",
            "_profilePicture" : "profile_picture",
            "_reward" : "reward",
            "_rewardType" : "reward_type",
            "_shared" : "shared",
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
