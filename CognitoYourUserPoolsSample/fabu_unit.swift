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
class Posts: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _postId: String?
    var _time: NSNumber?
    var _comments: NSNumber?
    var _liked: NSNumber?
    var _pictures: Set<String>?
    var _profilePicture: String?
    var _shared: NSNumber?
    var _tag: NSNumber?
    var _text: String?
    var _title: String?
    var _username: String?
    
    class func dynamoDBTableName() -> String {
        
        return "chance-mobilehub-653619147-posts"
    }
    
    class func hashKeyAttribute() -> String {
        
        return "_postId"
    }
    
    class func rangeKeyAttribute() -> String {
        
        return "_time"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
            "_postId" : "post_id",
            "_time" : "time",
            "_comments" : "comments",
            "_liked" : "liked",
            "_pictures" : "pictures",
            "_profilePicture" : "profile_picture",
            "_shared" : "shared",
            "_tag" : "tag",
            "_text" : "text",
            "_title" : "title",
            "_username" : "username",
        ]
    }
    
    
    
    func create() {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        
        // Create data object using data models you downloaded from Mobile Hub
        let newsItem: Posts = Posts()
        let username: String? = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        let un: String = username!
        print (un)
        newsItem._postId = "init"
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
    
    func update(type:String,content:Any) {
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let new = self
        // Create data object using data models you downloaded from Mobile Hub
        switch type {
        case "id":
            new._postId = content as? String
        case "time":
            new._time = content as? NSNumber
        case "comments":
            new._comments = content as? NSNumber
        case "like":
            new._liked = content as? NSNumber
        case "pictures":
            new._pictures = content as? Set<String>
        case "profile_picture":
            new._profilePicture = content as? String
        case "shared":
            new._shared = content as? NSNumber
        case "tag":
            new._tag = content as? NSNumber
        case "title":
            new._title = content as? String
        case "username":
            new._username = content as? String
        case "text":
            new._text = content as? String
        default:
            print("heihei something is wrong with the type input")
        }
        
        dynamoDbObjectMapper.save(new, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was updated.")
        })
    }
    
    func read (id:String, time:NSNumber) -> Posts? {
        var temp:Posts = Posts()
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.load(Posts.self, hashKey: id, rangeKey: time).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Amazon DynamoDB Read Error: \(error)")
            }else if let resultBook = task.result as? Posts {
                //print()
                temp = resultBook
            }
            return nil
        })
        print(temp._text)
        return temp
    }
    
    
    func read_string(id:String, time:NSNumber, type:String) -> String{
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        //let dynamoDBObjectMapper:AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper(forKey: "USEast1DynamoDBObjectMapper")
        //let username: String? = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        var temp = ""
        dynamoDbObjectMapper.load(Posts.self, hashKey: "Potaty", rangeKey: 5).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
            if let error = task.error as NSError? {
                print("Amazon DynamoDB Read Error: \(error)")
                return "error" as AnyObject
            }else if let resultBook = task.result as? Posts{
            print("An item was read.")
            
            switch type {
            case "id":
                temp = (resultBook._postId)!
            case "profile_picture":
                temp = (resultBook._profilePicture)!
            case "title":
                temp = (resultBook._title)!
            case "username":
                temp = (resultBook._username)!
            case "text":
                temp = (resultBook._text)!//print(resultBook._text)
            default:
                print("heihei something is wrong with the type input")
            }
            };return nil
        })
        //print("temp" + ("\(temp)"))
        return temp
    }

    func read_number(type:String) -> Int{
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        //let username: String? = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        var temp = 0
        dynamoDbObjectMapper.load(Posts.self, hashKey: self._postId, rangeKey: "", completionHandler: { (objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            print("An item was read.")
            //time comments liked shared tag
            switch type {
            case "time":
                temp = (objectModel?.dictionaryValue["_time"] as? Int)!
            case "comments":
                temp = (objectModel?.dictionaryValue["_comments"] as? Int)!
            case "liked":
                temp = (objectModel?.dictionaryValue["_liked"] as? Int)!
            case "shared":
                temp = (objectModel?.dictionaryValue["_shared"] as? Int)!
            case "tag":
                temp = (objectModel?.dictionaryValue["_tag"] as? Int)!
            default:
                print("heihei something is wrong with the type input")
            }
            
        })
        return temp
    }

    func read_string_set(type:String) -> Set<String>{
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        //let username: String? = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        var temp:Set<String> = []
        dynamoDbObjectMapper.load(Posts.self, hashKey: self._postId, rangeKey: "", completionHandler: { (objectModel: AWSDynamoDBObjectModel?, error: Error?) -> Void in
            if let error = error {
                print("Amazon DynamoDB Read Error: \(error)")
                return
            }
            print("An item was read.")
            //time comments liked shared tag
            temp = (objectModel?.dictionaryValue["_pictures"] as? Set<String>)!
            
        })
        return temp
    }
    
    func query (id:String) -> Posts {
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "#postId = :postId"
        //print("232")
        queryExpression.expressionAttributeNames = [
            "#postId": "postId",
        ]
        queryExpression.expressionAttributeValues = [
            ":postId": id,
        ]
       // print("239")
        // 2) Make the query
        //let dynamoDBObjectMapper:AWSDynamoDBObjectMapper = AWSDynamoDBObjectMapper(forKey: "USEast1DynamoDBObjectMapper")
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var temp:Posts = Posts()
      //  print("244")
        dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
       //     print("250")
            if error != nil {
                print("The request failed. Error: \(String(describing: error))")
            }
       //     print("248")
            if output != nil {
                for news in output!.items {
                    temp = news as! Posts
                }
            }
        }
        return temp
        
    }
    
    
    
}


func query_ (id:Int) -> Posts{
    let queryExpression = AWSDynamoDBQueryExpression()
    queryExpression.keyConditionExpression = "#post_id = :post_id"
    //print("232")
    queryExpression.expressionAttributeNames = [
        "#post_id": "post_id",
    ]
    queryExpression.expressionAttributeValues = [
        ":post_id": String(id)
    ]
    //print("239")
    // 2) Make the query
    
    let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var temp:Posts = Posts()
    //print("244")
    dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
        if error != nil {
            print("The request failed. Error: \(String(describing: error))")
        }
       // print("248")
        if output != nil {
            for news in output!.items {
                temp = news as! Posts
            }
        }
    }
    return temp
    
}





