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
@objc(ChanceWithValue)
class ChanceWithValue: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _id: String?
    var _bonus: NSNumber?
    var _bonusType: String?
    var _commentIdList: [String]?
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


@objcMembers
@objc(CommentTable)
class CommentTable: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _commentId: String?
    var _chanceId: String?
    var _commentText: String?
    var _upTime: String?
    var _userId: String?
    var _userPic: String?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-commentTable"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_commentId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_commentId" : "commentId",
            "_chanceId" : "chanceId",
            "_commentText" : "commentText",
            "_upTime" : "upTime",
            "_userId" : "userId",
            "_userPic" : "userPic",
        ]
    }
}


@objcMembers
@objc(UserPool)
class UserPool: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _career: String?
    var _chanceId: String?
    var _chanceIdList: [String]?
    var _gender: String?
    var _name: String?
    var _nickName: String?
    var _resume: String?
    var _walletAddress: String?
    var _beiGuanZhu: [String]?
    var _candyCurrency: NSNumber?
    var _cryptoCurrency: NSNumber?
    var _gottenList: [String]?
    var _guanZhu: [String]?
    var _myEmail: String?
    var _numofChance: String?
    var _profilePic: String?
    var _shengWang: String?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-UserPool"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_career" : "Career",
            "_chanceId" : "ChanceId",
            "_chanceIdList" : "ChanceIdList",
            "_gender" : "Gender",
            "_name" : "Name",
            "_nickName" : "NickName",
            "_resume" : "Resume",
            "_walletAddress" : "WalletAddress",
            "_beiGuanZhu" : "beiGuanZhu",
            "_candyCurrency" : "candyCurrency",
            "_cryptoCurrency" : "cryptoCurrency",
            "_gottenList" : "gottenList",
            "_guanZhu" : "guanZhu",
            "_myEmail" : "myEmail",
            "_numofChance" : "numofChance",
            "_profilePic" : "profilePic",
            "_shengWang" : "shengWang",
        ]
    }
}

@objcMembers
@objc(ChattingList)
class ChattingList: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _user1: String?
    var _user2: String?
    var _chattingText: [String]?
    var _chattingTime: [String]?
    var _srList: [String]?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-chattingList"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_user1"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_user2"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_user1" : "user1",
            "_user2" : "user2",
            "_chattingText" : "chattingText",
            "_chattingTime" : "chattingTime",
            "_srList" : "srList",
        ]
    }
}

@objcMembers
@objc(UserChat)
class UserChat: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _chattingList: [String]?
    var _lastSentence: [String: String]?
    var _lastTime: [String: String]?
    var _totalUnread: NSNumber?
    var _unRead: [String: String]?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-userChat"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_userId" : "userId",
            "_chattingList" : "chattingList",
            "_lastSentence" : "lastSentence",
            "_lastTime" : "lastTime",
            "_totalUnread" : "totalUnread",
            "_unRead" : "unRead",
        ]
    }
    
    
}
