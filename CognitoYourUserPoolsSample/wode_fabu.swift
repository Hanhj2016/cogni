//
//  wode_fabu.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-26.
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


class wode_fabu: UIViewController,UITableViewDelegate,UITableViewDataSource {
var xiala_dick2:[Int:Int] = [:]
    var xiala_dick3:[Int:Int] = [:]
    @IBAction func xiala2(_ sender: Any) {
        let row = (sender as! UIButton).tag
        let temp = posts2[row]
        let indexPath = IndexPath(item: row, section: 0)
        xiala_dick2[row] = 1
        self.tableView2.reloadRows(at: [indexPath], with: .fade)

    }
    @IBAction func xiala3(_ sender: Any) {
        let row = (sender as! UIButton).tag
        let temp = posts3[row]
        let indexPath = IndexPath(item: row, section: 0)
        xiala_dick3[row] = 1
        self.tableView3.reloadRows(at: [indexPath], with: .fade)

    }
    
    @objc func share_tap(sender : MyTapGesture){
        //图片索引
        
        //进入图片全屏展示
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: sender.username, rangeKey:nil)
        heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                new_chat.p = resultBook
                
            }
            return nil
        })
        heihei.waitUntilFinished()
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    @IBOutlet weak var top_bar: UIView!
    @IBOutlet weak var button1: UIButton!
    @IBAction func button1(_ sender: Any) {
        self.tableView1.isHidden = false
        self.tableView2.isHidden = true
        self.tableView3.isHidden = true
        self.highlight2.isHidden = true
        self.highlight3.isHidden = true
        self.highlight1.isHidden = false
    }
    @IBOutlet weak var highlight1: UIView!
    
    @IBOutlet weak var button2: UIButton!
    @IBAction func button2(_ sender: Any) {
        self.tableView1.isHidden = true
        self.tableView2.isHidden = false
        self.tableView3.isHidden = true
        self.highlight2.isHidden = false
        self.highlight3.isHidden = true
        self.highlight1.isHidden = true
    }
    @IBOutlet weak var highlight2: UIView!
    
    
    @IBOutlet weak var button3: UIButton!
    @IBAction func button3(_ sender: Any) {
        self.tableView2.isHidden = true
        self.tableView1.isHidden = true
        self.tableView3.isHidden = false
        self.highlight2.isHidden = true
        self.highlight3.isHidden = false
        self.highlight1.isHidden = true
        
    }
    @IBOutlet weak var highlight3: UIView!
    
    @IBOutlet weak var tableView1: UITableView!
    @IBOutlet weak var tableView2: UITableView!
    @IBOutlet weak var tableView3: UITableView!
    

    var xiala_dick:[Int:Int] = [:]
    @IBAction func xiala(_ sender: Any) {
        let row = (sender as! UIButton).tag
        let temp = posts[row]
        let indexPath = IndexPath(item: row, section: 0)
        xiala_dick[row] = 1
        self.tableView1.reloadRows(at: [indexPath], with: .fade)
        
        
    }
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var queryExpression = AWSDynamoDBScanExpression()
    var pics:[UIImage] = []
    var comment_click = false
    var share_click = false
    var posts:[ChanceWithValue] = []
    var post_key_list:[String] = []
    var posts2:[ChanceWithValue] = []
    var posts3:[ChanceWithValue] = []
    var p:UserPool = UserPool()
    
    
    func remove(from:[String],target:String) -> [String]{
        var temp:[String] = []
        for a in from
        {
            if a != target
            {temp.append(a)}
        }
        return temp
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = light
        self.button3.layer.cornerRadius = 3.0
        self.button2.layer.cornerRadius = 3.0
        self.button1.layer.cornerRadius = 3.0
        
        self.top_bar.backgroundColor = mid
        
        self.button1.setTitle(NSLocalizedString("未进行", comment: ""), for: .normal)
        //print("jaysus \("未进行".toLocal()).")
        self.button2.setTitle("进行中".toLocal(), for: .normal)
        self.button3.setTitle("已完成".toLocal(), for: .normal)
        
        self.button1.backgroundColor = sign_in_colour
         self.button2.backgroundColor = sign_in_colour
         self.button3.backgroundColor = sign_in_colour
        
        self.button1.setTitleColor(colour, for: .normal)
         self.button2.setTitleColor(colour, for: .normal)
         self.button3.setTitleColor(colour, for: .normal)
        
        self.highlight1.backgroundColor = colour
        self.highlight2.backgroundColor = colour
        self.highlight3.backgroundColor = colour
        
        self.highlight2.isHidden = true
        self.highlight3.isHidden = true
        self.tableView2.isHidden = true
        self.tableView3.isHidden = true
        
        self.tableView1.backgroundColor = mid
        self.tableView1!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView1!.delegate = self
        self.tableView1!.dataSource = self
        self.tableView1!.estimatedRowHeight = 150
        self.tableView1!.rowHeight = UITableViewAutomaticDimension
        
        
        self.tableView2.backgroundColor = mid
        self.tableView2!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView2!.delegate = self
        self.tableView2!.dataSource = self
        self.tableView2!.estimatedRowHeight = 150
        self.tableView2!.rowHeight = UITableViewAutomaticDimension
        
        self.tableView3.backgroundColor = mid
        self.tableView3!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView3!.delegate = self
        self.tableView3!.dataSource = self
        self.tableView3!.estimatedRowHeight = 150
        self.tableView3!.rowHeight = UITableViewAutomaticDimension
        
        self.refresh()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.toolbar.barTintColor = sign_in_colour
//        if(posts.count == 0)
//        {refresh()}
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 3
//    }
//
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.tableView1{
            return posts.count}
        if tableView == self.tableView2{
            return posts2.count}
        if tableView == self.tableView3{
            return posts3.count}
        return 0
    }
    
    @IBAction func share_detail(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var upcoming = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        let temp = posts[s.tag]
        let id = temp._sharedFrom![0]
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil)
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                upcoming.p = resultBook
                
            }
            return nil
        })
        heihei.waitUntilFinished()
        
        self.navigationController?.pushViewController(upcoming, animated: true)
    }
    
    
   
    
    @IBAction func like(_ sender: UIButton) {
        let temp:ChanceWithValue = posts[sender.tag]
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        if temp._liked != nil{
            if (temp._liked?.contains(user!))!
            {
                var temp_list:[String] = []
                for a in temp._liked!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._liked = temp_list}
                else
                {temp._liked = nil}
            }
            else
            {
                temp._liked?.append(user!)
            }}
        else
        {
            temp._liked = [user] as? [String]
        }
        posts[sender.tag] = temp
        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.tableView1.reloadRows(at: [indexPath], with: .fade)
        })
        dynamoDbObjectMapper.save(temp, completionHandler: nil)
        
    }
    
    @IBAction func comments(_ sender: Any) {
        // small = 1
        self.comment_click = true
        //self.performSegue(withIdentifier: "comment_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        new_chat.p = posts[s.tag]
        new_chat.share_click = self.share_click
        new_chat.comment_click = self.comment_click
        self.navigationController?.pushViewController(new_chat, animated: true)
        
    }
    @IBAction func share(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "pyq_share_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "share") as! share
        let s = sender as! UIButton
        let temp = posts[s.tag]
        if temp._sharedFrom == nil{
            new_chat.profile_picture_link = temp._profilePicture!
            new_chat.username_ = "@" + temp._username!
            new_chat.title_ = temp._title!
            new_chat.id = temp._id!
            new_chat.tag = Int(temp._tag!)}
        else
        {
            new_chat.profile_picture_link = temp._sharedFrom![3]
            new_chat.username_ =  temp._sharedFrom![1]
            new_chat.title_ = temp._sharedFrom![2]
            new_chat.id = temp._sharedFrom![0]
            new_chat.tag = Int(temp._tag!)
            new_chat.share_from = temp._id!
        }
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    
    
    @IBAction func share_detail2(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var upcoming = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        let temp = posts2[s.tag]
        let id = temp._sharedFrom![0]
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil)
        heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                upcoming.p = resultBook
                
            }
            return nil
        })
        heihei.waitUntilFinished()
        
        self.navigationController?.pushViewController(upcoming, animated: true)
    }
    
    
    
    
    @IBAction func like2(_ sender: UIButton) {
        let temp:ChanceWithValue = posts2[sender.tag]
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        if temp._liked != nil{
            if (temp._liked?.contains(user!))!
            {
                var temp_list:[String] = []
                for a in temp._liked!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._liked = temp_list}
                else
                {temp._liked = nil}
            }
            else
            {
                temp._liked?.append(user!)
            }}
        else
        {
            temp._liked = [user] as? [String]
        }
        posts2[sender.tag] = temp
        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.tableView2.reloadRows(at: [indexPath], with: .fade)
        })
        dynamoDbObjectMapper.save(temp, completionHandler: nil)
        
    }
    
    @IBAction func comments2(_ sender: Any) {
        // small = 1
        self.comment_click = true
        //self.performSegue(withIdentifier: "comment_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        new_chat.p = posts2[s.tag]
        new_chat.share_click = self.share_click
        new_chat.comment_click = self.comment_click
        self.navigationController?.pushViewController(new_chat, animated: true)
        
    }
    @IBAction func share2(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "pyq_share_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "share") as! share
        let s = sender as! UIButton
        let temp = posts2[s.tag]
        if temp._sharedFrom == nil{
            new_chat.profile_picture_link = temp._profilePicture!
            new_chat.username_ = "@" + temp._username!
            new_chat.title_ = temp._title!
            new_chat.id = temp._id!
            new_chat.tag = Int(temp._tag!)}
        else
        {
            new_chat.profile_picture_link = temp._sharedFrom![3]
            new_chat.username_ =  temp._sharedFrom![1]
            new_chat.title_ = temp._sharedFrom![2]
            new_chat.id = temp._sharedFrom![0]
            new_chat.tag = Int(temp._tag!)
            new_chat.share_from = temp._id!
        }
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    
    

    @IBAction func share_detail3(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var upcoming = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        let temp = posts3[s.tag]
        let id = temp._sharedFrom![0]
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil)
        heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                upcoming.p = resultBook
                
            }
            return nil
        })
        heihei.waitUntilFinished()
        
        self.navigationController?.pushViewController(upcoming, animated: true)
    }
    
    
    
    
    @IBAction func like3(_ sender: UIButton) {
        let temp:ChanceWithValue = posts3[sender.tag]
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        if temp._liked != nil{
            if (temp._liked?.contains(user!))!
            {
                var temp_list:[String] = []
                for a in temp._liked!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._liked = temp_list}
                else
                {temp._liked = nil}
            }
            else
            {
                temp._liked?.append(user!)
            }}
        else
        {
            temp._liked = [user] as? [String]
        }
        posts3[sender.tag] = temp
        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.tableView3.reloadRows(at: [indexPath], with: .fade)
        })
        dynamoDbObjectMapper.save(temp, completionHandler: nil)
        
    }
    
    @IBAction func comments3(_ sender: Any) {
        // small = 1
        self.comment_click = true
        //self.performSegue(withIdentifier: "comment_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let s = sender as! UIButton
        new_chat.p = posts3[s.tag]
        new_chat.share_click = self.share_click
        new_chat.comment_click = self.comment_click
        self.navigationController?.pushViewController(new_chat, animated: true)
        
    }
    @IBAction func share3(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "pyq_share_zhuye", sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "share") as! share
        let s = sender as! UIButton
        let temp = posts3[s.tag]
        if temp._sharedFrom == nil{
            new_chat.profile_picture_link = temp._profilePicture!
            new_chat.username_ = "@" + temp._username!
            new_chat.title_ = temp._title!
            new_chat.id = temp._id!
            new_chat.tag = Int(temp._tag!)}
        else
        {
            new_chat.profile_picture_link = temp._sharedFrom![3]
            new_chat.username_ =  temp._sharedFrom![1]
            new_chat.title_ = temp._sharedFrom![2]
            new_chat.id = temp._sharedFrom![0]
            new_chat.tag = Int(temp._tag!)
            new_chat.share_from = temp._id!
        }
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        let s = sender as! UIButton
        let row = s.tag
        let indexPath = IndexPath(item: s.tag, section: 0)
        let cell = self.tableView2.cellForRow(at: indexPath) as! tableView2
        let name = cell.dropdown.title(for: .normal)
        if name == "选择拒绝".toLocal()
        {
            return
        }
        else
        {
            if posts2[row]._getList!.contains(name!)
            {
                var temp = posts2[row]
                if temp._getList == nil
                {
                    return
                }
                else
                {
                    temp._getList = remove(from: temp._getList!, target: name!)
                    if temp._getList! == []
                    {
                        temp._getList = nil
                    }
                    if temp._unConfirmList != nil
                    {
                        temp._unConfirmList?.append(name!)
                    }
                    else
                    {
                        temp._unConfirmList = [name!]
                    }
                    
                }
                let heihei = dynamoDbObjectMapper.save(temp,completionHandler: nil)
                
            }
        }
        self.refresh()
    }
    
    @IBAction func cancel2(_ sender: Any) {
        let s = sender as! UIButton
        let row = s.tag
        let indexPath = IndexPath(item: s.tag, section: 0)
        let cell = self.tableView3.cellForRow(at: indexPath) as! tableView2
        let name = cell.dropdown.title(for: .normal)
        if name == "确认或拒绝".toLocal()
        {
            return
        }
        else
        {
            if posts3[row]._confirmList!.contains(name!)
            {
                var temp = posts3[row]
                if temp._confirmList == nil
                {
                    return
                }
                else
                {
                    temp._confirmList = remove(from: temp._confirmList!, target: name!)
                    if temp._confirmList! == []
                    {temp._confirmList = nil}
                    if temp._unConfirmList != nil
                    {
                        temp._unConfirmList?.append(name!)
                    }
                    else
                    {
                        temp._unConfirmList = [name!]
                    }
                    
                }
                dynamoDbObjectMapper.save(temp,completionHandler: nil)
            }
        }
        self.refresh()
    }
    
    @IBAction func confirm(_ sender: Any) {// for tableview3
        let s = sender as! UIButton
        let row = s.tag
        var temp = posts3[row]
        let indexPath = IndexPath(item: s.tag, section: 0)
        let cell = self.tableView3.cellForRow(at: indexPath) as! tableView2
        let name = cell.dropdown.title(for: .normal)
        if temp._confirmList != nil{
            temp._confirmList = [name!]
        }
        else
        {
            temp._confirmList?.append(name!)
        }
       
        var type = "shoufei"
        var number = 0.0//initializing it to be free
        if temp._shouFei != nil && temp._shouFei != 0{
            type = "shoufei"
        }else if temp._fuFei != nil && temp._fuFei != 0{
            type = "fufei"
        }
        
        if type == "fufei"{
            number = Double(temp._fuFei!)
            
            if p._frozenwallet != nil
            {
                p._frozenwallet = Double(p._frozenwallet!) - number as NSNumber
            }
            if p._candyCurrency != nil
            {
                p._candyCurrency = Double(p._candyCurrency!) - number as NSNumber
            }
            
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            let heihei = dynamoDbObjectMapper.load(UserPool.self, hashKey: name, rangeKey:nil)
            var p1:UserPool = UserPool()
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    p1 = resultBook
                }
                return nil
            })
            heihei.waitUntilFinished()
            if p1._availableWallet != nil
            {
                p1._availableWallet = Double(p1._availableWallet!) + number as NSNumber
            }
            if p1._candyCurrency != nil
            {
                p1._candyCurrency = Double(p1._candyCurrency!) + number as NSNumber
            }
            dynamoDbObjectMapper.save(temp,completionHandler:nil)
            dynamoDbObjectMapper.save(p,completionHandler:nil)
            dynamoDbObjectMapper.save(p1,completionHandler:nil)
        }else
        {
            number = Double(temp._fuFei!)
            
            if p._candyCurrency != nil
            {
                p._candyCurrency = Double(p._candyCurrency!) + number as NSNumber
            }
            if p._availableWallet != nil
            {
                p._availableWallet = Double(p._availableWallet!) + number as NSNumber
            }
            
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            let heihei = dynamoDbObjectMapper.load(UserPool.self, hashKey: name, rangeKey:nil)
            var p1:UserPool = UserPool()
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    p1 = resultBook
                }
                return nil
            })
            heihei.waitUntilFinished()
            if p1._frozenwallet != nil
            {
                p1._frozenwallet = Double(p1._frozenwallet!) - number as NSNumber
            }
            if p1._candyCurrency != nil
            {
                p1._candyCurrency = Double(p1._candyCurrency!) - number as NSNumber
            }
            
            dynamoDbObjectMapper.save(temp,completionHandler:nil)
            dynamoDbObjectMapper.save(p,completionHandler:nil)
            dynamoDbObjectMapper.save(p1,completionHandler:nil)
        }
        
        
        
        
        self.refresh()
        
        
        
        
        
    }
    
    
    @IBAction func check(_ sender: Any) {
        let s = sender as! UIButton
        let row = s.tag
        let indexPath = IndexPath(item: s.tag, section: 0)
        let cell = self.tableView2.cellForRow(at: indexPath) as! tableView2
        let name = cell.dropdown.title(for: .normal)
        if name == "确认或拒绝".toLocal()
        {
            return
        }
        else
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var new_chat = storyboard.instantiateViewController(withIdentifier: "other_zhuye") as! other_zhuye
            
            var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            var queryExpression = AWSDynamoDBScanExpression()
            //print("name")
            let heihei = dynamoDbObjectMapper.load(UserPool.self, hashKey: name, rangeKey:nil)
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    new_chat.p = resultBook
                }
                return nil
            }
            )
            heihei.waitUntilFinished()
            self.navigationController?.pushViewController(new_chat, animated: true)
            
        }
        
    }
    
    
    
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        if tableView == self.tableView1{
            new_chat.p = posts[indexPath.row]}
        if tableView == self.tableView2{
            new_chat.p = posts2[indexPath.row]}
        if tableView == self.tableView3{
            new_chat.p = posts3[indexPath.row]}
        
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var temp:ChanceWithValue = ChanceWithValue()
        if tableView == tableView1{
            var cell = tableView.dequeueReusableCell(withIdentifier: "tableView1", for: indexPath) as! MyTableViewCell
            temp = posts[indexPath.row]
            let temp_time:[Int] = time
            
            let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            let tap2: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            tap.username = temp._username!
            tap.cancelsTouchesInView = true
            tap2.username = temp._username!
            
            
            
            tap2.cancelsTouchesInView = true
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = mid.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            
            cell.profile_picture.isUserInteractionEnabled = true
            cell.profile_picture.addGestureRecognizer(tap)
            
            cell.username.isUserInteractionEnabled = true
            cell.username.addGestureRecognizer(tap2)
            
            
            
            
            cell.frame = tableView.bounds
            cell.layoutIfNeeded()
            let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
            //print(user)
            cell.like.tag = indexPath.row
            cell.comments.tag = indexPath.row
            cell.share.tag = indexPath.row
            //cell.share_detail.tag = indexPath.row
            cell.xiala.tag = indexPath.row
            
            cell.image_collection.backgroundColor = mid
            let origImage = UIImage(named: "dianzan")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.like.setImage(tintedImage, for: .normal)
            if temp._liked != nil{
                let like_number = (temp._liked?.count)!
                let clicked = (temp._liked?.contains(user!))
                if (clicked)!
                {cell.like.setTitleColor(colour, for: .normal)
                    cell.like.tintColor = colour
                }
                else
                {
                    cell.like.tintColor = text_mid
                    cell.like.setTitleColor(text_mid, for: .normal)
                    
                }
                if like_number != 0
                {cell.like.setTitle("\(like_number)", for: .normal)}
                else
                {cell.like.setTitle("", for: .normal)}
            }
            else
            {
                cell.like.tintColor = text_mid
                cell.like.setTitle("", for: .normal)
            }
            
            
            if (temp._commentIdList) != nil && (temp._commentIdList?.count)! > 0
            {
                cell.comments.setTitle("\((temp._commentIdList?.count)!)", for: .normal)
            }
            else
            {
                cell.comments.setTitle("", for: .normal)
            }
            
            if (temp._shared) != nil
            {
                cell.share.setTitle("\((temp._shared)!)", for: .normal)
            }
            else
            {
                cell.share.setTitle("", for: .normal)
            }
            
            
            
            if ((temp._username) != nil)
            {cell.username.text = temp._username
                cell.username.textColor = text_light
                cell.username.font = cell.username.font.withSize(17)
            }
            if ((temp._title) != nil)
            {cell.title.text = temp._title
                cell.title.font = cell.title.font.withSize(17)
                cell.title.textColor = text_light
                cell.title.numberOfLines = 0
                cell.title.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.title.sizeToFit()
                
            }
            
            if ((temp._text) != nil)
            {   cell.content.isHidden = false
                //cell.unlocked = 1
                if self.xiala_dick[indexPath.row] == nil{
                    if temp._text!.height(withConstrainedWidth: self.view.frame.width - 30, font: cell.content.font!) < 50 {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content.numberOfLines = 0
                        cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.content.sizeToFit()
                        cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                        cell.xiala.isHidden = true
                    }else
                    {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content_height.constant = 50
                        let origImage = UIImage(named: "xiala")
                        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                        cell.xiala.setImage(tintedImage, for: .normal)
                        cell.xiala.tintColor = text_light
                        cell.xiala.backgroundColor = light
                        cell.xiala.layer.cornerRadius = 3.0
                        cell.xiala.isHidden = false
                    }}
                else
                {
                    cell.content.text = temp._text
                    cell.content.font = cell.content.font.withSize(14)
                    cell.content.textColor = text_light
                    cell.content.numberOfLines = 0
                    cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.content.sizeToFit()
                    cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                    cell.xiala.isHidden = true
                }
            }
            else{
                //cell.content.isHidden = true
                cell.content_height.constant = 0
                cell.xiala.isHidden = true
            }
            
            
            
            cell.images = []
            cell.image_links = []
            if (temp._pictures != nil)&&(temp._pictures?.count != 0)
            {
                for i in 0...(temp._pictures?.count)!-1
                {
                    
                    cell.image_links.append(temp._pictures![i])
                }
            }
            cell.image_collection.reloadData()
            
            
            
            if (temp._profilePicture != nil){
                
                if let cachedVersion = imageCache.object(forKey: "\(temp._username!).png" as NSString) {
                    cell.profile_picture.image = cachedVersion
                }
                else{
                    downloadImage(key_: "\(temp._username!).png", destination: cell.profile_picture)
                }
            }
            else
            {cell.profile_picture.image = UIImage(named: "girl")}
            
            
            
            
            
            
            
            if ((temp._time) != nil)
            {
                var output = ""
                let _time = temp._time as! Int
                let second = _time % 100
                var Rem = _time / 100
                let Minute = Rem % 100
                Rem = Rem / 100
                let hour = Rem % 100
                Rem = Rem / 100
                let day = Rem % 100
                Rem = Rem / 100
                let month = Rem % 100
                Rem = Rem / 100
                let year = (Rem % 100)%100
                var a = time[0] % 100
                if year == a
                {
                    if day == time[2]
                    {
                        if hour == time[3]
                        {
                            if Minute == time[4]
                            {output = "\(time[5]-second) " + "秒前".toLocal()}
                            else if time[4] - Minute == 1
                            {
                                if (time[5]+60-second < 60)
                                {output = "\(time[5]+60-second) " + "秒前".toLocal()}
                                else
                                {output = "1" + "分钟前".toLocal()}
                                
                            }
                            else
                            {output = "\(time[4]-Minute) " + "分钟前".toLocal()}
                        }
                        else if time[3] - hour == 1
                        {
                            if time[4]+60-Minute < 60
                            {output = "\(time[4]+60-Minute) " + "分钟前".toLocal()}
                            else
                            {
                                if Minute < 10{
                                    output = " \(hour):0\(Minute)"
                                }else{
                                    output = " \(hour):\(Minute)"}}
                        }
                        else
                        {
                            if Minute < 10{
                                output = " \(hour):0\(Minute)"
                            }else{
                                output = " \(hour):\(Minute)"}
                        }
                    }
                    else if time[2] == (day + 1)
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else if time[2] == day + 2
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else
                    {
                        output = "\(month)月".toLocal() + " " + "\(day)日".toLocal()
                    }
                }
                else
                {output = "\(year)/\(month)/\(day)"}
                
                cell.time_label.font = cell.time_label.font.withSize(13)
                cell.time_label.text = output
                cell.time_label.textColor = text_mid
            }
            
            cell.tagg.isHidden = true
            //cell.tag_label.isHidden = true
            cell.tag_label.backgroundColor = tag_colour
            cell.tag_label.layer.cornerRadius = 8.0
            cell.tag_label.layer.masksToBounds = false
            cell.tag_label.clipsToBounds = true
            cell.tag_label.font = cell.tag_label.font.withSize(9)
            if ((temp._tag) != nil)
            {
                let t = temp._tag
                if t == 1
                {//cell.tagg.image = UIImage(named: "huodong")
                    cell.tag_label.text = "活动".toLocal()
                }
                else if t == 2
                {//cell.tagg.image = UIImage(named: "renwu")
                    cell.tag_label.text = "任务".toLocal()
                }
                else if t == 0
                {//cell.tagg.image = UIImage(named: "yuema")
                    cell.tag_label.text = "约嘛".toLocal()
                }
                else if t == 3
                {//cell.tagg.image = UIImage(named: "qita")
                    cell.tag_label.text = "其他".toLocal()
                }
            }
            
            
            
            
            
            
            
            
            cell.image_collection.backgroundColor = mid
            
            let contentSize = cell.image_collection.collectionViewLayout.collectionViewContentSize
            cell.image_collection.collectionViewLayout.invalidateLayout()
            cell.collectionViewHeight.constant = contentSize.height
            if temp._sharedFrom == nil //no share
            {
                cell.share_view.isHidden = true
                cell.share_profile_picture.isHidden = true
                cell.content.isHidden = false
            }
            else
            {
                cell.content.isHidden = true
                cell.share_view.isHidden = false
                cell.share_profile_picture.isHidden = false
                //print("height: \(cell.share_view.frame.height)")
                cell.collectionViewHeight.constant = 130
                cell.share_profile_picture.backgroundColor = sign_in_colour
                cell.share_profile_picture.contentMode = .scaleAspectFit
                cell.share_profile_picture.image = UIImage(named:"morenzhuanfa")
                var link = temp._sharedFrom![3].deletingPrefix("https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/")
                
                if let cachedVersion = imageCache.object(forKey: link as NSString) {
                    cell.share_profile_picture.image = cachedVersion
                }
                else{
                    downloadImage(key_: link, destination: cell.share_profile_picture)
                }
                if temp._sharedFrom!.count > 4{
                    cell.share_content.text = temp._sharedFrom![4]
                    cell.share_content.isHidden = false
                }else
                {
                    cell.share_content.isHidden = true
                }
                cell.share_content.textColor = text_light
                cell.share_title.text = temp._sharedFrom![2]
                cell.share_username.text = temp._sharedFrom![1]
                cell.share_view.backgroundColor = sign_in_colour
                cell.share_username.textColor = text_light
                cell.share_title.textColor = text_light
                cell.share_title.font = cell.share_title.font.withSize(14)
                //                cell.share_title.numberOfLines = 2
                cell.share_title.lineBreakMode = NSLineBreakMode.byWordWrapping
                //                cell.share_title.sizeToFit()
                //let tap = UITapGestureRecognizer(target:self,action:#selector(bigButtonTapped(_:)))
                //cell.share_view.addGestureRecognizer(tap)
                
            }
            
            
            
            cell.tool_bar.backgroundColor = mid
            cell.tool_bar.layer.borderColor = light.cgColor
            cell.tool_bar.layer.borderWidth = 1
            cell.bot_bar.backgroundColor = light
            cell.zhanwaifenxiang.isHidden = true
            cell.image_collection.tag = indexPath.row
            let tap3:MyTapGesture = MyTapGesture(target: self, action: #selector(share_tap))
            
            if temp._sharedFrom != nil{
                tap3.username = temp._sharedFrom![0]
                cell.image_collection.isUserInteractionEnabled = true
                cell.image_collection.addGestureRecognizer(tap3)
            }
            cell.backgroundColor = mid
            return cell
        }
        if tableView == tableView2{
            var cell = tableView.dequeueReusableCell(withIdentifier: "tableView2", for: indexPath) as! tableView2
            temp = posts2[indexPath.row]
            cell.cancel.tag = indexPath.row
            cell.xiala.tag = indexPath.row
            let temp_time:[Int] = time
            cell.frame = tableView.bounds
            cell.layoutIfNeeded()
            //cell.zhanwaifenxiang.isHidden = true
            cell.finish_bar.backgroundColor = light
            cell.finish_label.isHidden = true
            cell.confirm.isHidden = true
            cell.cancel.backgroundColor = sign_in_colour
            cell.cancel.setTitle("取消".toLocal(), for: .normal)
            cell.cancel.setTitleColor(text_light, for: .normal)
            cell.cancel.layer.cornerRadius = 5.0
            cell.dropdown.backgroundColor = colour
            cell.dropdown.layer.cornerRadius = 5.0
            cell.dropdown.tintColor = sign_in_colour
           // cell.dropdown.setTitleColor(sign_in_colour, for: .normal)
            cell.dropdown.setTitle("选择拒绝".toLocal(), for: .normal)
           cell.dropdown.dropView.dropDownOptions = temp._getList!
            cell.finish_label.isHidden = true
            cell.confirm.isHidden = false
            cell.confirm.backgroundColor = sign_in_colour
            cell.confirm.setTitle("查看信息".toLocal(), for: .normal)
            cell.confirm.setTitleColor(text_light, for: .normal)
            cell.confirm.layer.cornerRadius = 5.0
            cell.confirm.tag = indexPath.row
            
            
            
            let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            let tap2: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            tap.username = temp._username!
            tap.cancelsTouchesInView = true
            tap2.username = temp._username!
            tap2.cancelsTouchesInView = true
            cell.profile_picture.isUserInteractionEnabled = true
            cell.profile_picture.addGestureRecognizer(tap)

            cell.username.isUserInteractionEnabled = true
            cell.username.addGestureRecognizer(tap2)

            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = mid.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            
            
            let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
            cell.like.tag = indexPath.row
            cell.comments.tag = indexPath.row
            cell.share.tag = indexPath.row
       
            let origImage = UIImage(named: "dianzan")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.like.setImage(tintedImage, for: .normal)
            if temp._liked != nil{
                let like_number = (temp._liked?.count)!
                let clicked = (temp._liked?.contains(user!))
                if (clicked)!
                {cell.like.setTitleColor(colour, for: .normal)
                    cell.like.tintColor = colour
                }
                else
                {
                    cell.like.tintColor = text_mid
                    cell.like.setTitleColor(text_mid, for: .normal)
                    
                }
                if like_number != 0
                {cell.like.setTitle("\(like_number)", for: .normal)}
                else
                {cell.like.setTitle("", for: .normal)}
            }
            else
            {
                cell.like.tintColor = text_mid
                cell.like.setTitle("", for: .normal)
            }
            
            
            if (temp._commentIdList) != nil && (temp._commentIdList?.count)! > 0
            {
                cell.comments.setTitle("\((temp._commentIdList?.count)!)", for: .normal)
            }
            else
            {
                cell.comments.setTitle("", for: .normal)
            }
            
            if (temp._shared) != nil
            {
                cell.share.setTitle("\((temp._shared)!)", for: .normal)
            }
            else
            {
                cell.share.setTitle("", for: .normal)
            }
            
            
            
            if ((temp._username) != nil)
            {cell.username.text = temp._username
                cell.username.textColor = text_light
                cell.username.font = cell.username.font.withSize(17)
            }
            if ((temp._title) != nil)
            {cell.title.text = temp._title
                cell.title.font = cell.title.font.withSize(17)
                cell.title.textColor = text_light
                cell.title.numberOfLines = 0
                cell.title.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.title.sizeToFit()
                
            }
            
            if ((temp._text) != nil)
            {   cell.content.isHidden = false
                //cell.unlocked = 1
                if self.xiala_dick2[indexPath.row] == nil{
                    if temp._text!.height(withConstrainedWidth: self.view.frame.width - 30, font: cell.content.font!) < 50 {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content.numberOfLines = 0
                        cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.content.sizeToFit()
                        cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                        cell.xiala.isHidden = true
                    }else
                    {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content_height.constant = 50
                        let origImage = UIImage(named: "xiala")
                        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                        cell.xiala.setImage(tintedImage, for: .normal)
                        cell.xiala.tintColor = text_light
                        cell.xiala.backgroundColor = light
                        cell.xiala.layer.cornerRadius = 3.0
                        cell.xiala.isHidden = false
                    }}
                else
                {
                    cell.content.text = temp._text
                    cell.content.font = cell.content.font.withSize(14)
                    cell.content.textColor = text_light
                    cell.content.numberOfLines = 0
                    cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.content.sizeToFit()
                    cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                    cell.xiala.isHidden = true
                }
            }
            else{
                //cell.content.isHidden = true
                cell.content_height.constant = 0
                cell.xiala.isHidden = true
            }
        
            cell.images = []
            cell.image_links = []
            if (temp._pictures != nil)&&(temp._pictures?.count != 0)
            {
                for i in 0...(temp._pictures?.count)!-1
                {
                    
                    cell.image_links.append(temp._pictures![i])
                }
            }
            cell.image_collection.reloadData()
            
            
            if (temp._profilePicture != nil){
                
                if let cachedVersion = imageCache.object(forKey: "\(temp._username!).png" as NSString) {
                    cell.profile_picture.image = cachedVersion
                }
                else{
                    downloadImage(key_: "\(temp._username!).png", destination: cell.profile_picture)
                }
            }
            else
            {cell.profile_picture.image = UIImage(named: "girl")}
            
            
            
            if ((temp._time) != nil)
            {
                var output = ""
                let _time = temp._time as! Int
                let second = _time % 100
                var Rem = _time / 100
                let Minute = Rem % 100
                Rem = Rem / 100
                let hour = Rem % 100
                Rem = Rem / 100
                let day = Rem % 100
                Rem = Rem / 100
                let month = Rem % 100
                Rem = Rem / 100
                let year = (Rem % 100)%100
                var a = time[0] % 100
                if year == a
                {
                    if day == time[2]
                    {
                        if hour == time[3]
                        {
                            if Minute == time[4]
                            {output = "\(time[5]-second) " + "秒前".toLocal()}
                            else if time[4] - Minute == 1
                            {
                                if (time[5]+60-second < 60)
                                {output = "\(time[5]+60-second) " + "秒前".toLocal()}
                                else
                                {output = "1" + "分钟前".toLocal()}
                                
                            }
                            else
                            {output = "\(time[4]-Minute) " + "分钟前".toLocal()}
                        }
                        else if time[3] - hour == 1
                        {
                            if time[4]+60-Minute < 60
                            {output = "\(time[4]+60-Minute) " + "分钟前".toLocal()}
                            else
                            {
                                if Minute < 10{
                                    output = " \(hour):0\(Minute)"
                                }else{
                                    output = " \(hour):\(Minute)"}}
                        }
                        else
                        {
                            if Minute < 10{
                                output = " \(hour):0\(Minute)"
                            }else{
                                output = " \(hour):\(Minute)"}
                        }
                    }
                    else if time[2] == (day + 1)
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else if time[2] == day + 2
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else
                    {
                        output = "\(month)月".toLocal() + " " + "\(day)日".toLocal()
                    }
                }
                else
                {output = "\(year)/\(month)/\(day)"}
                
                cell.time_label.font = cell.time_label.font.withSize(13)
                cell.time_label.text = output
                cell.time_label.textColor = text_mid
            }
            
            
            cell.tagg.isHidden = true
            //cell.tag_label.isHidden = true
            cell.tag_label.backgroundColor = tag_colour
            cell.tag_label.layer.cornerRadius = 8.0
            cell.tag_label.layer.masksToBounds = false
            cell.tag_label.clipsToBounds = true
            cell.tag_label.font = cell.tag_label.font.withSize(9)
            if ((temp._tag) != nil)
            {
                let t = temp._tag
                if t == 1
                {//cell.tagg.image = UIImage(named: "huodong")
                    cell.tag_label.text = "活动".toLocal()
                }
                else if t == 2
                {//cell.tagg.image = UIImage(named: "renwu")
                    cell.tag_label.text = "任务".toLocal()
                }
                else if t == 0
                {//cell.tagg.image = UIImage(named: "yuema")
                    cell.tag_label.text = "约嘛".toLocal()
                }
                else if t == 3
                {//cell.tagg.image = UIImage(named: "qita")
                    cell.tag_label.text = "其他".toLocal()
                }
            }
            
            
            
            
            cell.image_collection.backgroundColor = mid
           // cell.image_collection.reloadData()
            let contentSize = cell.image_collection.collectionViewLayout.collectionViewContentSize
            cell.image_collection.collectionViewLayout.invalidateLayout()
            cell.collectionViewHeight.constant = contentSize.height
         
            
            
            
            cell.tool_bar.backgroundColor = mid
            cell.tool_bar.layer.borderColor = light.cgColor
            cell.tool_bar.layer.borderWidth = 1
            cell.bot_bar.backgroundColor = light
            
            
            
            cell.backgroundColor = mid
            return cell
        }
        if tableView == tableView3{
            var cell = tableView.dequeueReusableCell(withIdentifier: "tableView3", for: indexPath) as! tableView2
            cell.cancel.tag = indexPath.row
            cell.confirm.tag = indexPath.row
            
            temp = posts3[indexPath.row]
            let temp_time:[Int] = time
            cell.frame = tableView.bounds
            cell.layoutIfNeeded()
            //cell.zhanwaifenxiang.isHidden = true
            cell.finish_bar.backgroundColor = light
            cell.finish_label.isHidden = true
            cell.confirm.isHidden = false
            cell.cancel.backgroundColor = sign_in_colour
            cell.cancel.setTitle("取消".toLocal(), for: .normal)
            cell.cancel.setTitleColor(text_light, for: .normal)
            cell.cancel.layer.cornerRadius = 5.0
            
            
            cell.confirm.isHidden = false
            cell.confirm.backgroundColor = sign_in_colour
            cell.confirm.setTitle("确认".toLocal(), for: .normal)
            cell.confirm.setTitleColor(text_light, for: .normal)
            cell.confirm.layer.cornerRadius = 5.0
            cell.confirm.tag = indexPath.row
            
            cell.dropdown.backgroundColor = colour
            cell.dropdown.layer.cornerRadius = 5.0
            cell.dropdown.tintColor = sign_in_colour
            // cell.dropdown.setTitleColor(sign_in_colour, for: .normal)
            cell.dropdown.setTitle("确认或拒绝".toLocal(), for: .normal)
            
            var arrayA = temp._completeList!
            var arrayB = [String]()
            if temp._confirmList == nil
            {arrayB = []}
            else
            {arrayB = temp._confirmList!}
            
            var temp_array:[String] = []
            for word in arrayA {
                if !(arrayB.contains(word))
                {
                    temp_array.append(word)
                }
                
            }
            cell.dropdown.dropView.dropDownOptions = temp_array
            cell.dropdown.up = 1
            cell.finish_label.isHidden = true
            cell.confirm.isHidden = false
            
            var con_count = 0
            var uncon_count = 0
            if temp._confirmList != nil
            {con_count = (temp._confirmList?.count)!}
            if temp._unConfirmList != nil
            {uncon_count = (temp._unConfirmList?.count)!}
            
            if con_count + uncon_count == Int(temp._renShu!)
            {
                cell.confirm.isHidden = true
                cell.cancel.isHidden = true
                cell.dropdown.isHidden = true
                cell.finish_label.isHidden = false
                cell.finish_label.text = "全部完成".toLocal()
            }
         
            
            
            cell.dropdown.up = 1
            let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            let tap2: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
            tap.username = temp._username!
            tap.cancelsTouchesInView = true
            tap2.username = temp._username!
            tap2.cancelsTouchesInView = true
            cell.profile_picture.isUserInteractionEnabled = true
            cell.profile_picture.addGestureRecognizer(tap)
            
            cell.username.isUserInteractionEnabled = true
            cell.username.addGestureRecognizer(tap2)
            
            
            cell.images = []
            cell.image_links = []
            if (temp._pictures != nil)&&(temp._pictures?.count != 0)
            {
                for i in 0...(temp._pictures?.count)!-1
                {
                    
                    cell.image_links.append(temp._pictures![i])
                }
            }
            cell.image_collection.reloadData()
            
            
            
            if (temp._profilePicture != nil){
                
                if let cachedVersion = imageCache.object(forKey: "\(temp._username!).png" as NSString) {
                    cell.profile_picture.image = cachedVersion
                }
                else{
                    downloadImage(key_: "\(temp._username!).png", destination: cell.profile_picture)
                }
            }
            else
            {cell.profile_picture.image = UIImage(named: "girl")}
            
            

            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = mid.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            
            
            let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
            cell.like.tag = indexPath.row
            cell.comments.tag = indexPath.row
            cell.share.tag = indexPath.row
            cell.xiala.tag = indexPath.row
            let origImage = UIImage(named: "dianzan")
            let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
            cell.like.setImage(tintedImage, for: .normal)
            if temp._liked != nil{
                let like_number = (temp._liked?.count)!
                let clicked = (temp._liked?.contains(user!))
                if (clicked)!
                {cell.like.setTitleColor(colour, for: .normal)
                    cell.like.tintColor = colour
                }
                else
                {
                    cell.like.tintColor = text_mid
                    cell.like.setTitleColor(text_mid, for: .normal)
                    
                }
                if like_number != 0
                {cell.like.setTitle("\(like_number)", for: .normal)}
                else
                {cell.like.setTitle("", for: .normal)}
            }
            else
            {
                cell.like.tintColor = text_mid
                cell.like.setTitle("", for: .normal)
            }
            
            
            if (temp._commentIdList) != nil && (temp._commentIdList?.count)! > 0
            {
                cell.comments.setTitle("\((temp._commentIdList?.count)!)", for: .normal)
            }
            else
            {
                cell.comments.setTitle("", for: .normal)
            }
            
            if (temp._shared) != nil
            {
                cell.share.setTitle("\((temp._shared)!)", for: .normal)
            }
            else
            {
                cell.share.setTitle("", for: .normal)
            }
            
            
            
            if ((temp._username) != nil)
            {cell.username.text = temp._username
                cell.username.textColor = text_light
                cell.username.font = cell.username.font.withSize(17)
            }
            if ((temp._title) != nil)
            {cell.title.text = temp._title
                cell.title.font = cell.title.font.withSize(17)
                cell.title.textColor = text_light
                cell.title.numberOfLines = 0
                cell.title.lineBreakMode = NSLineBreakMode.byWordWrapping
                cell.title.sizeToFit()
            }
            
           
            if ((temp._text) != nil)
            {   cell.content.isHidden = false
                //cell.unlocked = 1
                if self.xiala_dick3[indexPath.row] == nil{
                    if temp._text!.height(withConstrainedWidth: self.view.frame.width - 30, font: cell.content.font!) < 50 {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content.numberOfLines = 0
                        cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                        cell.content.sizeToFit()
                        cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                        cell.xiala.isHidden = true
                    }else
                    {
                        cell.content.text = temp._text
                        cell.content.font = cell.content.font.withSize(14)
                        cell.content.textColor = text_light
                        cell.content_height.constant = 50
                        let origImage = UIImage(named: "xiala")
                        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
                        cell.xiala.setImage(tintedImage, for: .normal)
                        cell.xiala.tintColor = text_light
                        cell.xiala.backgroundColor = light
                        cell.xiala.layer.cornerRadius = 3.0
                        cell.xiala.isHidden = false
                    }}
                else
                {
                    cell.content.text = temp._text
                    cell.content.font = cell.content.font.withSize(14)
                    cell.content.textColor = text_light
                    cell.content.numberOfLines = 0
                    cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
                    cell.content.sizeToFit()
                    cell.content_height.constant = cell.content.text!.height(withConstrainedWidth: cell.content.frame.width, font: cell.content.font)
                    cell.xiala.isHidden = true
                }
            }
            else{
                //cell.content.isHidden = true
                cell.content_height.constant = 0
                cell.xiala.isHidden = true
            }
            
            
            
            
            
            if ((temp._time) != nil)
            {
                var output = ""
                let _time = temp._time as! Int
                let second = _time % 100
                var Rem = _time / 100
                let Minute = Rem % 100
                Rem = Rem / 100
                let hour = Rem % 100
                Rem = Rem / 100
                let day = Rem % 100
                Rem = Rem / 100
                let month = Rem % 100
                Rem = Rem / 100
                let year = (Rem % 100)%100
                var a = time[0] % 100
                if year == a
                {
                    if day == time[2]
                    {
                        if hour == time[3]
                        {
                            if Minute == time[4]
                            {output = "\(time[5]-second) " + "秒前".toLocal()}
                            else if time[4] - Minute == 1
                            {
                                if (time[5]+60-second < 60)
                                {output = "\(time[5]+60-second) " + "秒前".toLocal()}
                                else
                                {output = "1" + "分钟前".toLocal()}
                                
                            }
                            else
                            {output = "\(time[4]-Minute) " + "分钟前".toLocal()}
                        }
                        else if time[3] - hour == 1
                        {
                            if time[4]+60-Minute < 60
                            {output = "\(time[4]+60-Minute) " + "分钟前".toLocal()}
                            else
                            {
                                if Minute < 10{
                                    output = " \(hour):0\(Minute)"
                                }else{
                                    output = " \(hour):\(Minute)"}}
                        }
                        else
                        {
                            if Minute < 10{
                                output = " \(hour):0\(Minute)"
                            }else{
                                output = " \(hour):\(Minute)"}
                        }
                    }
                    else if time[2] == (day + 1)
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else if time[2] == day + 2
                    {
                        if Minute < 10{
                            output = " \(hour):0\(Minute)"
                        }else{
                            output = " \(hour):\(Minute)"}
                        output = "昨天".toLocal() + output
                    }
                    else
                    {
                        output = "\(month)月".toLocal() + " " + "\(day)日".toLocal()
                    }
                }
                else
                {output = "\(year)/\(month)/\(day)"}
                
                cell.time_label.font = cell.time_label.font.withSize(13)
                cell.time_label.text = output
                cell.time_label.textColor = text_mid
            }

            cell.tagg.isHidden = true
            //cell.tag_label.isHidden = true
            cell.tag_label.backgroundColor = tag_colour
            cell.tag_label.layer.cornerRadius = 8.0
            cell.tag_label.layer.masksToBounds = false
            cell.tag_label.clipsToBounds = true
            cell.tag_label.font = cell.tag_label.font.withSize(9)
            if ((temp._tag) != nil)
            {
                let t = temp._tag
                if t == 1
                {//cell.tagg.image = UIImage(named: "huodong")
                    cell.tag_label.text = "活动".toLocal()
                }
                else if t == 2
                {//cell.tagg.image = UIImage(named: "renwu")
                    cell.tag_label.text = "任务".toLocal()
                }
                else if t == 0
                {//cell.tagg.image = UIImage(named: "yuema")
                    cell.tag_label.text = "约嘛".toLocal()
                }
                else if t == 3
                {//cell.tagg.image = UIImage(named: "qita")
                    cell.tag_label.text = "其他".toLocal()
                }
            }
            
            
            
            
            
            
            cell.image_collection.backgroundColor = mid
           // cell.image_collection.reloadData()
            let contentSize = cell.image_collection.collectionViewLayout.collectionViewContentSize
            cell.image_collection.collectionViewLayout.invalidateLayout()
            cell.collectionViewHeight.constant = contentSize.height
           
            
            
            cell.tool_bar.backgroundColor = mid
            cell.tool_bar.layer.borderColor = light.cgColor
            cell.tool_bar.layer.borderWidth = 1
            cell.bot_bar.backgroundColor = light
            
            
            
            cell.backgroundColor = mid
            return cell
        }
        return UITableViewCell()
       
    }
    
    

    
    
    
    func sort_posts(){
        var id_list:[Int] = []
        for a in posts
        {
            id_list.append(Int(a._id!)!)
        }
        id_list.sort(by: >)
        var temp_list:[ChanceWithValue] = []
        
        for a in 0...posts.count - 1
        {
            for b in posts
            {
                if b._id == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        posts = temp_list
    }
    
    
    
    func sort_posts2(){
        var id_list:[Int] = []
        for a in posts2
        {
            id_list.append(Int(a._id!)!)
        }
        id_list.sort(by: >)
        var temp_list:[ChanceWithValue] = []
        
        for a in 0...posts2.count - 1
        {
            for b in posts2
            {
                if b._id == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        posts2 = temp_list
    }
    
    func sort_posts3(){
        var id_list:[Int] = []
        for a in posts3
        {
            id_list.append(Int(a._id!)!)
        }
        id_list.sort(by: >)
        var temp_list:[ChanceWithValue] = []
        
        for a in 0...posts3.count - 1
        {
            for b in posts3
            {
                if b._id == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        posts3 = temp_list
    }
    
    

    
    
    @objc func refresh() {
        
        //********************************//
        //************** TIME ******************//
        let date = Date()
        let calendar = Calendar.current
        time[0] = calendar.component(.year, from: date) // 0
        time[1] = calendar.component(.month, from: date) // 1
        time[2] = calendar.component(.day, from: date) //2
        time[3] = calendar.component(.hour, from: date) // 3
        time[4] = calendar.component(.minute, from: date) // 4
        time[5] = calendar.component(.second, from: date) // 5
        //************** TIME ******************//
        
        
        
        //*********************** ALL***********************
        
            var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            var queryExpression = AWSDynamoDBScanExpression()
            self.posts = []
        self.posts2 = []
         self.posts3 = []
            var temp_list:[ChanceWithValue] = []
        if p._chanceIdList != nil{
            post_key_list = p._chanceIdList!}
        else
        {
            post_key_list = []
        }
        
            for a in post_key_list{
                let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: a, rangeKey:nil)
                heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let resultBook = task.result as? ChanceWithValue {
                        
                        var temp = resultBook as! ChanceWithValue
                        if temp._getList == nil && temp._completeList == nil
                        {self.posts.append(temp)}
                        if temp._getList != nil
                        {self.posts2.append(temp)}
                        if temp._completeList != nil
                        {self.posts3.append(temp)}
                        if self.posts.count > 0
                        {self.sort_posts()}
                        if self.posts2.count > 0
                        {self.sort_posts2()}
                        if self.posts3.count > 0
                        {self.sort_posts3()}
                    }
                    return nil
                })
                heihei.waitUntilFinished()
            }
            
            
        
        self.tableView2.reloadData()
        self.tableView1.reloadData()
        self.tableView3.reloadData()
    }
    
    
    
}
