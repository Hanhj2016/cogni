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
//@objc(chat)
var chat_image_preset = "jake_is_super_niu_bi"
class chat: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate {

    var myTimer:Timer = Timer()
    var target = ""
    var user = ""
    var user_image:UIImage = UIImage()
    var target_image:UIImage = UIImage()
    var p:ChattingList = ChattingList()
    var user_index = 0
    var images:[UIImage] = []
    var photos:[UIImage] = []
    var image_dic:[Int:UIImage] = [:]
    var SelectedAssets = [PHAsset]()
    let imagePicker = UIImagePickerController()
    
    @IBOutlet weak var sending: UILabel!
    @IBOutlet weak var input_bar: UIView!
    @IBOutlet weak var input_bar_height: NSLayoutConstraint!
    var screen_height = UIScreen.main.bounds.height
    @IBOutlet weak var table_height: NSLayoutConstraint!
    @IBOutlet weak var input: UITextView!
    
    @IBOutlet weak var choose_image: UIButton!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func choose_image(_ sender: Any) {
        
        self.photos = []
        self.SelectedAssets = []
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 9
        vc.selectionCharacter = "✓"
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: { (asset: PHAsset) -> Void in}, deselect: { (asset: PHAsset) -> Void in}, cancel: { (assets: [PHAsset]) -> Void in}, finish: { (assets: [PHAsset]) -> Void in
                                                for i in 0..<assets.count
                                                {
                                                    self.SelectedAssets.append(assets[i])
                                                }
                                                
                                                self.convertAssetToImages()
        }, completion: nil)
        
        
    }

    
    func convertAssetToImages() -> Void {
        if SelectedAssets.count != 0{
            for i in 0..<SelectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                
                let newImage = UIImage(data: data!)
                var image_name = ""
                //self.photos.append(newImage! as UIImage)
                if user_index == 0 || user_index == 1
                {
                    image_name = "\(user)_\(target)_\(get_current_time())_\(i).png"
                }
                if user_index == 2
                {
                    image_name = "\(target)_\(user)_\(get_current_time())_\(i).png"
                }
                
                uploadImage(with: data!, bucket: pictures, key: image_name)
                set_image_cache(key: image_name, image: UIImage(data:data!)!)
                let delayInSeconds = 1.0
                
                DispatchQueue.main.async {
                    self.sending.isHidden = false
                }
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                    self.sending.isHidden = true
                    self.send_message(content: chat_image_preset + image_name)
                    
                }

                
            }
            
            
        }
    }
//    @objc func myPerformeCode() {
//        print("103")
//        // here code to perform
//    }
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
        send_message(content: text)
        
            
    
        
    }
    
    func send_message(content: String){
        let text = content
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
                dynamoDbObjectMapper.save(temp,completionHandler:nil)
                target1 = target
                user1 = user
                var target_userchat = load_UserChat(key: target1) //target
                if target_userchat._userId == nil
                {// creating userchat for target
                    var temp1:UserChat = UserChat()
                    temp1._userId = target1
                    temp1._chattingList = [user1]
                    temp1._unRead = [user1:"1"]
                    if user != target
                    {
                        temp1._totalUnread = 1}
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
                    if target != user{
                        temp1._totalUnread = Int(temp1._totalUnread!) + 1 as NSNumber}
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
                if user != target{
                    target_userchat._totalUnread = Int(target_userchat._totalUnread!) + 1 as NSNumber}
                
                
                var user_userchat = load_UserChat(key: user)
                user_userchat._chattingList = remove(from:user_userchat._chattingList!, target:target)
                user_userchat._chattingList?.append(target)
                user_userchat._lastSentence![target] = text
                user_userchat._lastTime![target] = get_current_time()
                dynamoDbObjectMapper.save(user_userchat, completionHandler: nil)
                dynamoDbObjectMapper.save(target_userchat, completionHandler: nil)
            }
            
            
            
            
            self.refresh()
            //self.input.resignFirstResponder()
            DispatchQueue.main.async {
            self.input.text = ""
            if self.tableView.numberOfRows(inSection: 0) > 0{
                self.scrollToBottom()}
            }
        }
    }
    
    func scrollToBottom(){
       
       
        DispatchQueue.main.async {
            self.tableView.reloadData()
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
        let year:Int64  = Int64(calendar.component(.year, from: date)) // 0
        let month:Int64 = Int64(calendar.component(.month, from: date)) // 1
        let day:Int64 = Int64(calendar.component(.day, from: date)) //2
        let hour:Int64 = Int64(calendar.component(.hour, from: date)) // 3
        let minute:Int64 = Int64(calendar.component(.minute, from: date)) // 4
        let second:Int64 = Int64(calendar.component(.second, from: date)) // 5
        let temp_time1 = (year * 10000000000 + month * 100000000 + day * 1000000)
        let temp_time2 = (hour * 10000 + minute * 100 + second)
        let temp_time = (temp_time1 + temp_time2)
        return String(temp_time)
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
                    {output = "刚刚"}//output = "\(time_[5]-second) 秒前"}
                    else if time_[4] - Minute == 1
                    {
                        if (time_[5]+60-second <= 60)
                        {output = "刚刚"}//output = "\(time_[5]+60-second) 秒前"}
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
    
    
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        
        //print("448")
        var index = 0
          var tag = recognizer.view!.tag
        images = []
        var counter = 0
        for a in 0...(self.p._chattingText?.count)! - 1
        {
            if let j = image_dic[a]
            {
               // print("row: \(self.tableView.indexPathForSelectedRow?.row)")
               // print("a: \(a)")
                images.append(j)
                
                if tag == a
                {
                    //print("index: \(counter)")
                    index = counter
                }
                 counter += 1
            }
        }
        
        
        
        let previewVC = ImagePreviewVC(images: images, index: index)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_cell", for: indexPath) as! chat_cell
        let row = indexPath.row
        //print("row: \(row)")
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
            cell.chat_height.constant = height + 18
            cell.chat.isScrollEnabled = false
            cell.chat.isEditable = false
            cell.chat.text = p._chattingText![row]
           
            
            
            if cell.chat.text.hasPrefix(chat_image_preset)
            {
                cell.chat.text = ""
                let message = p._chattingText![row].deletingPrefix(chat_image_preset)
                let link = s3_prefix + message
                cell.chat_height.constant = 200
                cell.chat_width.constant = 200
                
                cell.picture.backgroundColor = self.view.backgroundColor
                cell.picture.contentMode = .scaleAspectFit
                cell.picture.isHidden = false
                cell.picture.image = UIImage(named:"chat_loading")
                
              //  let message = p._chattingText![row].deletingPrefix(chat_image_preset)
//                if let cachedVersion = imageCache.object(forKey: message as NSString) {
//                    cell.picture.image = cachedVersion
//                    cell.chat_height.constant = get_image_size(image: cell.picture.image!).0
//                    cell.chat_width.constant = get_image_size(image: cell.picture.image!).1
//                }
//                else{
//                    downloadImage(key_: message, destination: cell.picture)
//                }
//
                

                if let value = cache.secondaryCache?.load(key: message) {
                    cell.picture.image = UIImage(data:value)!
                    cell.chat_height.constant = get_image_size(image: cell.picture.image!).0
                    cell.chat_width.constant = get_image_size(image: cell.picture.image!).1
                }else
                {
                    // print("out")
                    downloadImage(key_: message, destination: cell.picture)
                }
                self.image_dic[row] = cell.picture.image
                
                
                
            }
            else
            {cell.picture.isHidden = true}

            
            
            
            
            
            
            
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
            
            
            
            
            cell.picture.tag = indexPath.row
            cell.picture.isUserInteractionEnabled = true
            let tapSingle = UITapGestureRecognizer(target:self,
                                                 action:#selector(imageViewTap(_:)))
            tapSingle.numberOfTapsRequired = 1
            tapSingle.numberOfTouchesRequired = 1
            
            cell.picture.addGestureRecognizer(tapSingle)
            

        }
        return cell
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
        if self.tableView.numberOfRows(inSection: 0) > 0{
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }}
        
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
        self.sending.isHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.tableView.addGestureRecognizer(tap)
        
    
        while(user_index != 0 && (p._user1 == nil || p._user1 == ""))
        {print("doing while in chat man")}
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        tableView.delegate = self
        tableView.dataSource = self
        self.title = target
        self.tableView!.estimatedRowHeight = 200
        self.tableView!.rowHeight = UITableViewAutomaticDimension

        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.backgroundColor = background_grey
        self.input_bar.backgroundColor = input_background_grey
        self.send.setTitleColor(input_background_grey, for: .normal)
        self.send.backgroundColor = image_grey
        self.send.layer.cornerRadius = 5.0
        self.send.titleLabel?.font = self.send.titleLabel?.font.withSize(10)

        self.view.backgroundColor = background_grey
        
        if p._chattingTime != nil{
            tableView.reloadData()
            DispatchQueue.main.async {
            let indexPath = IndexPath(row: (self.tableView.numberOfRows(inSection: 0)) - 1 , section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
        myTimer = Timer(timeInterval: 1.0, target: self, selector: "refresh", userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoopMode.defaultRunLoopMode)

        // Do any additional setup after loading the view.
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        myTimer.invalidate()
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func refresh() {
        
        var pull_down = 0
        //*********************** ALL***********************

        if self.p._chattingText == nil{
            self.p._chattingText = []
        }
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
                    if pull_down != 0 {
                        self.tableView.reloadData()}
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
                    if pull_down != 0 {
                        self.tableView.reloadData()}
                })
            }
            return nil
        })
        task.waitUntilFinished()
        
        
        if p._chattingTime != nil && pull_down == 1{
            print("weird")
            //tableView.reloadData()
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
                if target != user{
                    temp_chat._totalUnread = Int(temp_chat._totalUnread!) - unread! as NSNumber}
                
                
                dynamoDbObjectMapper.save(temp_chat,completionHandler:nil)
                
                
            }
        }
     
        
        
        
        
    }
    

}
