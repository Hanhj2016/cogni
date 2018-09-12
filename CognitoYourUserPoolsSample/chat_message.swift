//
//  chat_message.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-19.
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


class chat_message: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if p._chattingList?.count == nil || p._chattingList?.count ==
            0
        {return 0}
        else
        {return (p._chattingList?.count)!}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_message_cell", for: indexPath) as! chat_message_cell
        let row = indexPath.row
        
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = text_mid.cgColor
        let name = p._chattingList![row]
        //print(name)
        let profile_picture = name + ".png"
        
        //downloadImage(key_: profile_picture, destination: cell.profile_picture)

            if let cachedVersion = imageCache.object(forKey: profile_picture as NSString) {
                cell.profile_picture.image = cachedVersion
            }
            else{
                downloadImage(key_: profile_picture, destination: cell.profile_picture)
            }
        
        
        cell.profile_picture.layer.borderWidth = 1.0
        cell.profile_picture.layer.masksToBounds = false
        cell.profile_picture.layer.borderColor = UIColor.white.cgColor
        cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
        cell.profile_picture.clipsToBounds = true
        
        let unread = p._unRead?[name]
        cell.notification.text = unread
        if unread == nil || unread == "0"
        {
            cell.notification.isHidden = true
        }
        else
        {
            cell.notification.isHidden = false
            cell.notification.backgroundColor = UIColor.red
            cell.notification.layer.cornerRadius = cell.notification.frame.height/2
            cell.notification.layer.borderWidth = 1.0
            cell.notification.layer.masksToBounds = false
            cell.notification.layer.borderColor = UIColor.red.cgColor
            cell.notification.clipsToBounds = true
            cell.notification.textColor = text_light
        }
        cell.name.textColor = sign_in_colour
        cell.name.text = name
        cell.name.font = cell.name.font.withSize(16)
        if !(p._lastSentence?[name]?.hasPrefix(chat_image_preset))!{
            cell.last_sentence.text = p._lastSentence?[name]}
        else
        {cell.last_sentence.text = "[图片]"}
        cell.last_sentence.textColor = text_grey
        cell.last_sentence.font = cell.last_sentence.font.withSize(14)
        
        cell.time.textColor = text_grey
        cell.time.font = cell.time.font.withSize(12)
        cell.time.text = get_time(input: (p._lastTime?[name])!)
        
        return cell
    }
    
    func get_time(input:String) -> String{
        
        var _time = Int(input)
        // print(input)
        let date = Date()
        let calendar = Calendar.current
        var time_:[Int] = []
        var year  = calendar.component(.year, from: date) // 0
        var month = calendar.component(.month, from: date) // 1
        var day = calendar.component(.day, from: date) //2
        var hour = calendar.component(.hour, from: date) // 3
        var minute = calendar.component(.minute, from: date) // 4
        var second = calendar.component(.second, from: date) // 5
        time_.append(year)
        time_.append(month)
        time_.append(day)
        time_.append(hour)
        time_.append(minute)
        time_.append(second)
        
        var output = ""
        // let _time = temp._time as! Int
        second = _time! % 100
        var Rem = _time! / 100
        var Minute = Rem % 100
        Rem = Rem / 100
        hour = Rem % 100
        Rem = Rem / 100
        day = Rem % 100
        Rem = Rem / 100
        month = Rem % 100
        Rem = Rem / 100
        year = (Rem % 100)%100
        var a = time_[0] % 100
        if year == a
        {
            if day == time_[2]
            {
                if hour == time_[3]
                {
                    if Minute == time_[4]
                    {output = "\(time_[5]-second) 秒前"}
                    else if time_[4] - Minute == 1
                    {
                        if (time_[5]+60-second <= 60)
                        {output = "\(time_[5]+60-second) 秒前"}
                        else
                        {output = "1分钟前"}
                        
                    }
                    else
                    {output = "\(time_[4]-Minute) 分钟前"}
                }
                else if time_[3] - hour == 1
                {
                    if time_[4]+60-Minute <= 60
                    {output = "\(time_[4]+60-Minute) 分钟前"}
                    else
                    {output = "\(hour):\(Minute)"}
                }
                else
                {
                    output = "\(hour):\(Minute)"
                }
            }
            else if time_[2] == (day + 1)
            {
                output = "昨天\(hour):\(Minute)"
            }
            else if time_[2] == day + 2
            {
                output = "前天\(hour):\(Minute)"
            }
            else
            {
                output = "\(month)月\(day)日"
            }
        }
        else
        {output = "\(year)/\(month)/\(day)"}
        //print(output)
        return output
    }
    
    
    
    @IBOutlet weak var tableView: UITableView!
    var user = ""
    var p:UserChat = UserChat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.rowHeight = 80
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        p = self.load_UserChat(key: user)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let target = p._chattingList![row]
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var new_chat = storyboard.instantiateViewController(withIdentifier: "chat") as! chat
        
        
        var profile_picture = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + target + ".png"
     
            
            if let cachedVersion = imageCache.object(forKey: profile_picture as NSString) {
                new_chat.target_image = cachedVersion
            }
        
    
        profile_picture = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + user + ".png"
        if let cachedVersion = imageCache.object(forKey: profile_picture as NSString) {
            new_chat.user_image  = cachedVersion
        }
        
//
//        let new_chat = chat(user: user, target: target, user_image: user_image!, target_image: target_image!)
       
        
        new_chat.user = user
        new_chat.target = target
       
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    func load_UserChat(key:String) -> UserChat{
        var temp:UserChat = UserChat()
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var aiya = dynamoDbObjectMapper.load(UserChat.self, hashKey: key, rangeKey:nil)
        aiya.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? UserChat {
                temp = resultBook
                
               let temp_list = temp._chattingList
                var empty:[String] = []
                for a in 0...(temp_list?.count)! - 1
                {
                    empty.append(temp_list![(temp_list?.count)! - 1 - a])
                }
                temp._chattingList = empty
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

}
