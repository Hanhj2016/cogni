//
//  chat.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-14.
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

class chat: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    var target = ""
    var user = ""
    var user_image:UIImage = UIImage()
    var target_image:UIImage = UIImage()
    var p:ChattingList = ChattingList()
    var user_index = 0
    @IBOutlet weak var input_bar: UIView!
    @IBOutlet weak var input_bar_height: NSLayoutConstraint!
    var screen_height = UIScreen.main.bounds.height
    @IBOutlet weak var table_height: NSLayoutConstraint!
    @IBOutlet weak var input: UITextView!
    
    @IBOutlet weak var choose_image: UIButton!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func choose_image(_ sender: Any) {
    }
    
    func remove(from:[String],target:String) -> [String]{
        var temp:[String] = []
        for a in from
        {
            if a != target
            {temp.append(a)}
        }
        return temp
    }
    @IBAction func send(_ sender: Any) {
        //1.check if the chattinglist exist
        //2. if it does, save the new line
        let text = self.input.text!
        var target1 = "heiheihei"
        var user1 = "hahaha"
        let last_time = get_current_time()
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        /////// 1///////
        if text != nil && text != ""{
        if user_index == 0   // means doesnt exist
        {
            var temp:ChattingList = ChattingList()
            temp._user1 = user
            temp._user2 = target
            temp._srList = ["user1"]
            temp._chattingTime = [last_time]
            temp._chattingText = [text]
            target1 = target
            user1 = user
            var target_userchat = load_UserChat(key: target1) //target
            if target_userchat._userId == nil
            {// creating userchat for target
                var temp1:UserChat = UserChat()
                temp1._userId = target1
                temp1._chattingList = [user1]
                temp1._unRead = [user1:"1"]
                temp1._totalUnread = 1
                temp1._lastTime = [user1:last_time]
                temp1._lastSentence = [user1:text]
                dynamoDbObjectMapper.save(temp1, completionHandler: nil)
                
                var user_userchat = load_UserChat(key: user1)
                if user_userchat._userId == nil
                {
                    var temp1:UserChat = UserChat()
                    temp1._userId = user1
                    temp1._chattingList = [target1]
                    temp1._unRead = [target1:"0"]
                    temp1._totalUnread = 0
                    temp1._lastTime = [target1:last_time]
                    temp1._lastSentence = [target1:text]
                    dynamoDbObjectMapper.save(temp1, completionHandler:nil)
                    
                }
                else
                {
                    user_userchat._chattingList = remove(from: user_userchat._chattingList!, target: target1)
                    user_userchat._chattingList!.append(target1)
                    user_userchat._unRead![target1] = "0"
                    user_userchat._lastTime![target1] = last_time
                    user_userchat._lastSentence![target1] = text
                    dynamoDbObjectMapper.save(user_userchat, completionHandler: nil)
                }
                
            }
            else
            {
                // target has a userchat
                // 1. update target_userchat
                // 2.  check if use has one
                    // if not, initialize
                    // else, update
                // 1
                var temp1:UserChat = target_userchat
                //temp1._userId = targ
                temp1._chattingList = remove(from: temp1._chattingList!, target: user)
                temp1._chattingList!.append(user)
                if temp1._unRead![user] != nil
                {var unread = Int(temp1._unRead![user]!)
                    unread = unread! + 1
                    temp1._unRead![user] = String(unread!)
                }
                else
                {
                    temp1._unRead![user] = "1"
                }
                temp1._totalUnread = Int(temp1._totalUnread!) + 1 as NSNumber
                temp1._lastTime![user] = last_time
                temp1._lastSentence![user] = text
                dynamoDbObjectMapper.save(temp1, completionHandler: nil)
                
                
                // 2
                
                var user_userchat = load_UserChat(key: user1)
                if user_userchat._userId == nil
                {
                    var temp1:UserChat = UserChat()
                    temp1._userId = user
                    temp1._chattingList = [target]
                    temp1._unRead = [target:"0"]
                    temp1._totalUnread = 0
                    temp1._lastTime = [target:last_time]
                    temp1._lastSentence = [target:text]
                    dynamoDbObjectMapper.save(temp1, completionHandler:nil)
                    
                }
                else
                {
                    user_userchat._chattingList = remove(from: user_userchat._chattingList!, target: target)
                    user_userchat._chattingList!.append(target)
                    user_userchat._unRead![target] = "0"
                    user_userchat._lastTime![target] = last_time
                    user_userchat._lastSentence![target] = text
                    dynamoDbObjectMapper.save(user_userchat, completionHandler: nil)
                }
                
            }
        
            
            
        }
        else
        {
            
          p._chattingText!.append(text)
            
            if user_index == 1
            {
                p._srList!.append("user1")
                p._chattingTime!.append(last_time)
            }
            if user_index == 2
            {
                p._srList!.append("user2")
                p._chattingTime!.append(last_time)
            }
            dynamoDbObjectMapper.save(p, completionHandler: nil)
            
            // both are sure to be in userchat
            // load target
            //update
            var target_userchat = load_UserChat(key: target)
            target_userchat._chattingList = remove(from: target_userchat._chattingList!, target: user)
            target_userchat._chattingList!.append(user)
            target_userchat._lastSentence![user] = text
            target_userchat._lastTime![user] = get_current_time()
            var unread = Int(target_userchat._unRead![user]!)
            unread = unread! + 1
            target_userchat._unRead![user] = String(unread!)
            target_userchat._totalUnread = Int(target_userchat._totalUnread!) + 1 as NSNumber
            
           
            var user_userchat = load_UserChat(key: user)
            user_userchat._chattingList = remove(from:user_userchat._chattingList!, target:target)
            user_userchat._chattingList?.append(target)
            
            dynamoDbObjectMapper.save(user_userchat, completionHandler: nil)
            dynamoDbObjectMapper.save(target_userchat, completionHandler: nil)
        }
        
        
            
            
            self.refresh()
            //self.input.resignFirstResponder()
            self.input.text = ""
            self.scrollToBottom()
    
        }
        
            
    
        
    }
    
    func scrollToBottom(){
       
        tableView.reloadData()
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
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
    
    
    
    
    
    
    
    func get_current_time() -> String{
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
        let temp_time = (temp_time1 + temp_time2)
        return String(temp_time)
    }
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        let refreshImage = UIImageView()
        refreshImage.image = UIImage(named: "jake")
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.addSubview(refreshImage)
        refreshImage.frame = refreshControl.bounds.offsetBy(dx: self.view.frame.size.width / 2 - 20, dy: 20)
        refreshImage.frame.size.width = 40 // Whatever width you want
        refreshImage.frame.size.height = 40
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
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
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath) as! chat_cell
        
      
        let row = indexPath.row
        if p._srList != nil
        {
            var index = ""
            if user_index == 1
            {index = "user1"}
            else
            {index = "user2"}
            cell.backgroundColor = background_grey
            let text = p._chattingText![row]
            var width = text.width(withConstrainedHeight: 30, font: cell.chat.font!)
            if width > 250
            {width = 250}
            let height = text.height(withConstrainedWidth: width, font: cell.chat.font!)
            cell.chat.backgroundColor = colour
            cell.chat.layer.cornerRadius = 5.0
            cell.chat_width.constant = width + 15
            cell.chat_height.constant = height + 15
            cell.chat.isScrollEnabled = false
            cell.chat.isEditable = false
           // var show_time = 0
            cell.chat.text = p._chattingText![row]
            if row == 0
            {
                cell.show_time = 1
            }
            else
            {
               var current_time = Int(p._chattingTime![row])
                var last_time = Int(p._chattingTime![row - 1])
                //print("difference: \(current_time! - last_time!)")
                if current_time! - last_time! > 400
               {cell.show_time = 1}
                else
               {cell.show_time = 0}
            }
            if cell.show_time == 1{
                cell.time_label.isHidden = false
                //print("row: \(row)")
                cell.time_label.text = get_time(input: p._chattingTime![row])
                cell.time_label.textColor = text_grey
                cell.time_label.font = cell.time_label.font.withSize(10)
                cell.chat_top.constant = 30
                cell.profile_picture_top.constant = 30
            }
            else
            {
                cell.time_label.isHidden = true
                cell.chat_top.constant = 0
                cell.profile_picture_top.constant = 0
            }
            
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = UIColor.white.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            
            //print("width: \(width)")
             if p._srList![row] == index //right
             {
                cell.chat.backgroundColor = blue
                cell.chat.textColor = text_light
                 cell.profile_picture_left.constant = self.view.frame.width - 50
                cell.chat_left_to_image_right.constant = (0 - cell.chat_width.constant - 15 - 40)
                cell.profile_picture.image = user_image
               
            }
            else // left
             {
                cell.chat.backgroundColor = text_light
                cell.chat.textColor = sign_in_colour
                cell.chat_left_to_image_right.constant = 15
                cell.profile_picture.image = target_image
                cell.profile_picture_left.constant = 10
            }

        }
        return cell
        //cell.title = table_titles[indexPath.row]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if p._srList != nil
        {return (p._srList?.count)!}
        else
        {return 0}
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("will appear")
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.tableView.setContentOffset(CGPoint(x:0,y:0), animated: true)
            self.input_bar_height.constant = 45
            //self.scrollToBottom()
            
       
    }
    @objc func keyboardWillAppear(notification: NSNotification) {
        
        let userInfo = notification.userInfo
        let keyboardframe = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        self.tableView.setContentOffset(CGPoint(x:0,y:self.screen_height - self.input_bar_height.constant - 65), animated: true)
        self.input_bar_height.constant = 45 + keyboardframe!.height
        tableView.reloadData()
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
        
    }
    
    
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        //self.tableView.setContentOffset(CGPoint(x:0,y:self.screen_height - self.input_bar_height.constant - 65), animated: true)
        //self.tableView.reloadData()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
       /// self.scrollToBottom()
        //self.tableView.reloadData()
    }
    
    
    @objc override func dismissKeyboard() {
        self.input.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
          self.refresh()
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        //self.tableView.hideKeyboardWhenTappedAround()
        while(user_index != 0 && (p._user1 == nil || p._user1 == ""))
        {print("doing while in chat man")}
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
tableView.delegate = self
        tableView.dataSource = self
        self.title = target
        self.tableView!.estimatedRowHeight = 200
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = background_grey
        self.input_bar.backgroundColor = input_background_grey
        self.send.setTitleColor(input_background_grey, for: .normal)
        self.send.backgroundColor = image_grey
        self.send.layer.cornerRadius = 5.0
        self.send.titleLabel?.font = self.send.titleLabel?.font.withSize(10)
//        DispatchQueue.main.async(execute: {
//            self.tableView.setContentOffset(CGPoint(x:0,y:self.screen_height - 110), animated: true)
//            //self.table_height.constant = self.screen_height - 110
//        })
        self.view.backgroundColor = background_grey
        
        if p._chattingTime != nil{
            //self.tableView.layoutIfNeeded()
        
            //let indexPath = IndexPath(row: 76, section: 0)
            //print("row: \(indexPath.row)")
            //print("number: \(self.tableView.numberOfRows(inSection: 0))")
            tableView.reloadData()
            DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
        var myTimer = Timer(timeInterval: 1.0, target: self, selector: "refresh", userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoopMode.defaultRunLoopMode)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        
        var pull_down = 0
        //*********************** ALL***********************

            var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            var queryExpression = AWSDynamoDBScanExpression()
            
            var temp_list:[ChanceWithValue] = []
        
                var task = dynamoDbObjectMapper.load(ChattingList.self, hashKey: user, rangeKey:target)
                    task.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let resultBook = task.result as? ChattingList {
                        if self.p._chattingText != nil{
                            if (self.p._chattingText?.count)! < (resultBook._chattingText?.count)!
                            {pull_down = 1}}
                        self.p = resultBook
                        self.user_index = 1
                        DispatchQueue.main.async(execute: {
                            self.tableView.reloadData()
                            self.refresher.endRefreshing()
                        })
                    }
                    return nil
                })
        task.waitUntilFinished()
            
        task = dynamoDbObjectMapper.load(ChattingList.self, hashKey: target, rangeKey:user)
            task.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChattingList {
                if self.p._chattingText != nil{
                if (self.p._chattingText?.count)! < (resultBook._chattingText?.count)!
                {pull_down = 1}}
                self.user_index = 2
                self.p = resultBook
                 DispatchQueue.main.async(execute: {
                self.tableView.reloadData()
                self.refresher.endRefreshing()
                })
            }
            return nil
        })
        task.waitUntilFinished()
        if p._chattingTime != nil{
            tableView.reloadData()
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
        var temp_chat = load_UserChat(key: user)
        if (temp_chat._userId != nil)
        {
            if (temp_chat._chattingList?.contains(target))!
            {
                let unread = Int(temp_chat._unRead![target]!)
                temp_chat._unRead![target] = "0"
                temp_chat._totalUnread = Int(temp_chat._totalUnread!) - unread! as NSNumber
            }
        }
     
        
        
        
        
    }
    

}
