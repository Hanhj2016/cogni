//
//  share.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-05.
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

class share: UIViewController {

    
    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var content_view: UIView!
 
    @IBOutlet weak var profile_picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var top_bar: UIView!
    
    @IBOutlet weak var back: UIButton!
    @IBOutlet weak var share: UIButton!
    
    var profile_picture_link = ""
    var username_ = ""
    var title_ = ""
    var id = ""
    var tag = 0
    var share_from = ""
    @IBAction func share(_ sender: Any) {
        
        if share_from != ""
        {
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: share_from, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? ChanceWithValue {
                    if (resultBook._shared != nil)
                    {
                        resultBook._shared = (resultBook._shared as! Int + 1) as! NSNumber
                    }
                    else
                    {
                        resultBook._shared = 1
                    }
                    dynamoDbObjectMapper.save(resultBook,completionHandler: nil)
                }
                return nil
            })
        }
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
               if (resultBook._shared != nil)
               {
                resultBook._shared = (resultBook._shared as! Int + 1) as! NSNumber
                }
                else
               {
                resultBook._shared = 1
                }
                dynamoDbObjectMapper.save(resultBook,completionHandler: nil)
            }
            return nil
        })
        
        var counter = 0
        
        var temp:ChanceWithValue = ChanceWithValue()
        let date = Date()
        let calendar = Calendar.current
        let year  = calendar.component(.year, from: date) // 0
        let month = calendar.component(.month, from: date) // 1
        let day = calendar.component(.day, from: date) //2
        let hour = calendar.component(.hour, from: date) // 3
        let minute = calendar.component(.minute, from: date) // 4
        let second = calendar.component(.second, from: date) // 5
        let temp_time1 = Int(year * 10000000000 + month * 100000000 + day * 1000000)
        let temp_time2 = Int(hour * 10000 + minute * 100 + second)
        temp._time = (temp_time1 + temp_time2) as NSNumber
        temp._title = self.input.text
        temp._username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        
        
        
        var queryExpression = AWSDynamoDBScanExpression()
        dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    
                    //   print(paginatedOutput.items.count)
                    let counter = paginatedOutput.items.count + 1
                    // print("counter: \(counter)")
                    temp._id = String(counter)
                    
                    dynamoDbObjectMapper.load(UserPool.self, hashKey: temp._username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                        if let error = task.error as? NSError {
                            print("The request failed. Error: \(error)")
                        } else if let resultBook = task.result as? UserPool {
                            if resultBook._chanceIdList != nil{
                                resultBook._chanceIdList?.append(temp._id!)}
                            else
                            {resultBook._chanceIdList = [temp._id] as! [String]}
                            dynamoDbObjectMapper.save(resultBook,completionHandler:nil)
                        }
                        return nil
                    })
                    
                    temp._sharedFrom = ["\(self.id)","\(self.username_)","\(self.title_)","\(self.profile_picture_link)"]
                    dynamoDbObjectMapper.save(temp, completionHandler: nil)
                    
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    
                }
            })
        })
        
        
        
        
        
        
        
    }
    
    @IBOutlet weak var tt: UILabel!
    @IBAction func back(_ sender: Any) {
        self.navigationController?.navigationBar.isHidden = false
        //_ = self.navigationController?.popToRootViewController(animated: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.back.tintColor = colour
        self.share.backgroundColor = colour
        self.share.tintColor = sign_in_colour
        self.share.layer.cornerRadius = 15
        let url = URL(string:profile_picture_link)!
        self.profile_picture.image = UIImage(data:try! Data(contentsOf: url))
        self.username.text = username_
        self.title_label.text = self.title_
        self.view.backgroundColor = mid
        self.content_view.backgroundColor = sign_in_colour
        self.username.textColor = text_light
    
        self.title_label.text = title_
        self.title_label.font = self.title_label.font.withSize(14)
        self.title_label.textColor = text_mid
        self.title_label.numberOfLines = 0
        self.title_label.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.title_label.sizeToFit()
        
        self.input.textColor = text_mid
        self.input.backgroundColor = mid
        self.input.placeholder = "说说分享心得..."
        self.tt.textColor = colour
        //self.navigationController?.navigationBar.tintColor = colour
        //UINavigationBar.appearance().tintColor = colour
      self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }

   
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




