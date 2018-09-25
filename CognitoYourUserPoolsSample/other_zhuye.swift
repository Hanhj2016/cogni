//
//  other_zhuye.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-13.
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
class other_zhuye: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var xiala_dick:[Int:Int] = [:]
    @IBAction func xiala(_ sender: Any) {
        let row = (sender as! UIButton).tag
        let temp = posts[row]
        let indexPath = IndexPath(item: row, section: 0)
        xiala_dick[row] = 1
        self.tableView.reloadRows(at: [indexPath], with: .fade)
        
        
    }
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var pool: AWSCognitoIdentityUserPool?
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var queryExpression = AWSDynamoDBScanExpression()
    var lock:NSLock?
    var pics:[UIImage] = []
    var comment_click = false
    var share_click = false
    var posts:[ChanceWithValue] = []
    var post_key_list:[String] = []
    var all = false
    var p:UserPool = UserPool()
    //var title_name = ""
    //var small = 0
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var image_collection: UICollectionView!
//    @IBAction func xiaoxi(_ sender: Any) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        var new_chat = storyboard.instantiateViewController(withIdentifier: "xinxi") as! chat_message
//        new_chat.user = (AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username)!
//        self.navigationController?.pushViewController(new_chat, animated: true)
//    }
//
//
    @IBOutlet weak var top_view: UIView!
    @IBOutlet weak var profile_picture: UIImageView!
    var did_follow = 0
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var resume: UILabel!
    @IBOutlet weak var reputation: UIButton!
    @IBOutlet weak var follow_label: UILabel!
    @IBOutlet weak var follow_value: UILabel!
    @IBOutlet weak var followed_value: UILabel!
    @IBOutlet weak var followed_label: UILabel!
    @IBOutlet weak var fabu_value: UILabel!
    @IBOutlet weak var fabu_label: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bot_bar: UIStackView!
    
    @IBOutlet weak var guanzhu: UIButton!
    
    
    init(list:[String]){
        self.post_key_list = list
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
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
    
    let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
    
    @IBAction func guanzhu(_ sender: Any) {
        if did_follow == 0
        {
            self.guanzhu.setTitle("已关注".toLocal(), for: .normal)
            did_follow = 1
            //self guanzhu ++
            //target: p beiguanzhu ++
            
        }
        else
        {
            self.guanzhu.setTitle("关注".toLocal(), for: .normal)
            did_follow = 0
        }
        
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        let temp:UserPool = p
        
        var add = 0
        if temp._beiGuanZhu != nil{
            if (temp._beiGuanZhu?.contains(user!))!
            {
                var temp_list:[String] = []
                for a in temp._beiGuanZhu!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._beiGuanZhu = temp_list}
                else
                {temp._beiGuanZhu = nil}
                add = 0
            }
            else
            {   //没被关注：增加
                add = 1
                temp._beiGuanZhu?.append(user!)
            }}
        else
        {//没被关注：增加
            add = 1
            temp._beiGuanZhu = [user] as? [String]
        }
        p = temp
    
        dynamoDbObjectMapper.save(temp, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
        dynamoDbObjectMapper.load(UserPool.self, hashKey: user, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? UserPool {
                
                if add == 1
                {
                    if resultBook._guanZhu == nil
                    {resultBook._guanZhu = [self.p._userId] as! [String]}else
                    {resultBook._guanZhu!.append(self.p._userId!)}
                    
                }
                else if resultBook._guanZhu?.count == 1
                {
                    resultBook._guanZhu = nil
                }
                else
                {
                    var temp:[String] = []
                    for a in resultBook._guanZhu!
                    {
                        if a != self.p._userId
                        {
                            temp.append(a)
                        }
                    }
                    resultBook._guanZhu = temp
                    
                }
                dynamoDbObjectMapper.save(resultBook, completionHandler: {
                    (error: Error?) -> Void in
                    
                    if let error = error {
                        print("Amazon DynamoDB Save Error: \(error)")
                        return
                    }
                    print("An item was saved.")
                })
                
            }
            return nil
        })
        
        
        
        
    }
    @IBOutlet weak var send_message: UIButton!
    
    @IBAction func send_message(_ sender: Any) {
        performSegue(withIdentifier: "chat_from_zhuye", sender: self)
    }
    
    @IBOutlet weak var his_guanzhu: UIButton!
    
    @IBAction func his_guanzhu(_ sender: Any) {
        performSegue(withIdentifier: "tarenguanzhu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "tarenguanzhu"
        {
            var upcoming: guanzhu = segue.destination as! guanzhu
            
                if p._guanZhu != nil
                {upcoming.guanzhu_list = p._guanZhu!}
                else
                {upcoming.guanzhu_list = []}
                upcoming.p = self.p
            
        }
        if segue.identifier == "show_post_detail_zhuye_other"
        {
            
            var upcoming: post_detail = segue.destination as! post_detail
            let indexPath = self.tableView.indexPathForSelectedRow!
            upcoming.p = posts[indexPath.row]
            
            
        }
        else if segue.identifier == "share_detail_zhuye_other"
        {
            var upcoming: post_detail = segue.destination as! post_detail
            let s = sender as! UIButton
            let temp = posts[s.tag]
            let id = temp._sharedFrom![0]
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? ChanceWithValue {
                    upcoming.p = resultBook
                    
                }
                return nil
            })
        }
        else if segue.identifier == "comment_zhuye_other" || segue.identifier == "share_zhuye_other"
        {
            var upcoming: post_detail = segue.destination as! post_detail
            let s = sender as! UIButton
            upcoming.p = posts[s.tag]
            upcoming.share_click = self.share_click
            upcoming.comment_click = self.comment_click
            
        }
        else if segue.identifier == "pyq_share_zhuye_other"
        {
            var upcoming: share = segue.destination as! share
            let s = sender as! UIButton
            let temp = posts[s.tag]
            if temp._sharedFrom == nil{
                upcoming.profile_picture_link = temp._profilePicture!
                upcoming.username_ = "@" + temp._username!
                upcoming.title_ = temp._title!
                upcoming.id = temp._id!
                upcoming.tag = Int(temp._tag!)}
            else
            {
                upcoming.profile_picture_link = temp._sharedFrom![3]
                upcoming.username_ =  temp._sharedFrom![1]
                upcoming.title_ = temp._sharedFrom![2]
                upcoming.id = temp._sharedFrom![0]
                upcoming.tag = Int(temp._tag!)
                upcoming.share_from = temp._id!
            }
            
        }
        else if segue.identifier == "chat_from_zhuye"
        {
            var upcoming: chat = segue.destination as! chat
            upcoming.target = p._userId!
            upcoming.user = user!
            var url = URL(string: "")
            if p._profilePic != nil{
                var message = p._profilePic!
                message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                 url = URL(string:message)!
                
                upcoming.target_image = UIImage(data:try! Data(contentsOf: url!))!
            }
            else
            { upcoming.target_image = UIImage(named: "boy")!}
            
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            
            let heihei = dynamoDbObjectMapper.load(UserPool.self, hashKey: user, rangeKey:nil)
                heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    
                    var message = resultBook._profilePic!
                    message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    url = URL(string:message)!
                    
                    upcoming.user_image = UIImage(data:try! Data(contentsOf: url!))!
                    
                }
                return nil
            })
            heihei.waitUntilFinished()
            if upcoming.user_image != nil
            {upcoming.user_image = UIImage(named: "girl")!}
        }
        
    }
    
    @IBOutlet weak var bot_view: UIView!
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = 0
        //进入图片全屏展示
        if self.profile_picture.image != nil{
            let previewVC = ImagePreviewVC(images: [self.profile_picture.image!], index: index)
            //self.navigationController?.setToolbarHidden(true, animated: true)
            self.navigationController?.pushViewController(previewVC, animated: true)}
    }
    
    
    
    @objc func guanzhu_label_(sender : MyTapGesture){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "guanzhu") as! guanzhu
        if p._guanZhu != nil
        {new_chat.guanzhu_list = p._guanZhu!}
        else
        {new_chat.guanzhu_list = []}
        new_chat.p = self.p
        
        
        new_chat.title = "他的关注".toLocal()
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    @objc func beiguanzhu_label_(sender : MyTapGesture){
        let title_name = "被关注".toLocal()
        
        //performSegue(withIdentifier: "zhuye", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "guanzhu") as! guanzhu
        if p._guanZhu != nil
        {new_chat.guanzhu_list = p._beiGuanZhu!}
        else
        {new_chat.guanzhu_list = []}
        new_chat.p = self.p
        
        
        new_chat.title = "被关注".toLocal()
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        while(p._userId == nil)
//        {
//        }
        //self.refresh()
        
        
        let tap:MyTapGesture = MyTapGesture(target: self, action: #selector(guanzhu_label_))
        let tap2:MyTapGesture = MyTapGesture(target: self, action: #selector(beiguanzhu_label_))
    
        let tap4:MyTapGesture = MyTapGesture(target: self, action: #selector(guanzhu_label_))
        let tap5:MyTapGesture = MyTapGesture(target: self, action: #selector(beiguanzhu_label_))
  
        //tap3.cancelsTouchesInView = true
        self.follow_label.isUserInteractionEnabled = true
        self.follow_label.addGestureRecognizer(tap)
        self.follow_value.isUserInteractionEnabled = true
        self.follow_value.addGestureRecognizer(tap4)
        self.followed_label.isUserInteractionEnabled = true
        self.followed_label.addGestureRecognizer(tap2)
        self.followed_value.isUserInteractionEnabled = true
        self.followed_value.addGestureRecognizer(tap5)
        
     
        self.top_view.backgroundColor = mid

        
        if ((p._profilePic != nil))
        {
//            let url = URL(string: p._profilePic!)
//            let data = try? Data(contentsOf: url!)
//
//            self.profile_picture.image = UIImage(data: data!)
            downloadImage(key_: "\(p._userId!).png", destination: self.profile_picture)
        }
        else
        {self.profile_picture.image = UIImage(named: "girl")}
        
        
        if ((p._profilePic != nil))
        {
            //
            let heihei = p._userId!
            // print(heihei)
            // downloadImage(key_: "\(p._userId!).png", destination: self.profile_picture)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = mid.cgColor
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
            
        }
        
        self.profile_picture.isUserInteractionEnabled = true
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        self.profile_picture.addGestureRecognizer(tapSingle)
        
        
        
        self.username.text = p._userId
        self.username.textColor = text_light
        self.username.font = self.username.font.withSize(20)
        self.resume.font = self.resume.font.withSize(12)
        self.resume.numberOfLines = 0
        self.resume.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.resume.sizeToFit()
        self.fabu_label.font = self.fabu_label.font.withSize(12)
        self.followed_label.font = self.followed_label.font.withSize(12)
        self.follow_label.font = self.follow_label.font.withSize(12)
        self.resume.textColor = text_mid
        if p._resume != nil{
            self.resume.text = "简介".toLocal() + "：" + p._resume!}
        else
        {self.resume.isHidden = true}
        self.reputation.setTitle("声望".toLocal() + ": \(p._shengWang!)", for: .normal)
        self.reputation.backgroundColor = colour
        self.reputation.layer.cornerRadius = self.reputation.frame.height / 2
        self.reputation.setTitleColor(sign_in_colour, for: .normal)
        
        self.follow_value.textColor = text_light
        self.followed_value.textColor = text_light
        self.fabu_value.textColor = text_light
        if p._guanZhu != nil
        {self.follow_value.text = String((p._guanZhu?.count)!)}
        else
        {self.follow_value.text = "0"}
        if p._beiGuanZhu != nil
        {self.followed_value.text = String((p._beiGuanZhu?.count)!)}
        else
        {self.followed_value.text = "0"}
        if p._chanceIdList != nil
        {self.fabu_value.text = String((p._chanceIdList?.count)!)}
        else
        {self.fabu_value.text = "0"}
        
        self.follow_label.textColor = text_mid
        self.followed_label.textColor = text_mid
        self.fabu_label.textColor = text_mid
        self.followed_label.text = "被关注".toLocal()
        self.follow_label.text = "关注".toLocal()
        self.fabu_label.text = "发布".toLocal()
        // Do any additional setup after loading the view.
        
        
        
        ///////////////////bot/////////////
        self.bot_bar.backgroundColor = text_light
        self.bot_bar.layer.borderColor = light.cgColor
        self.bot_view.layer.borderWidth = 1
        self.bot_view.layer.borderColor = light.cgColor
        self.bot_bar.layer.borderWidth = 1
        self.bot_bar.backgroundColor = light
        self.guanzhu.setTitleColor(colour, for: .normal)
        self.his_guanzhu.setTitleColor(colour, for: .normal)
        self.his_guanzhu.setTitle("他的关注".toLocal(), for: .normal)
        self.send_message.setTitleColor(colour, for: .normal)
        self.send_message.setTitle("发送私信".toLocal(), for: .normal)
        self.send_message.backgroundColor = mid
        self.his_guanzhu.backgroundColor = mid
        self.guanzhu.backgroundColor = mid
        
        
        
        
        if (p._beiGuanZhu != nil){
            if (p._beiGuanZhu?.contains(user!))!
            {
                self.guanzhu.setTitleColor(colour, for: .normal)
                self.guanzhu.setTitle("取消关注".toLocal(), for: .normal)
                self.did_follow = 1
            }
            else
            {
               // print("396")
                self.guanzhu.setTitleColor(colour, for: .normal)
                self.guanzhu.setTitle("关注".toLocal(), for: .normal)
                self.did_follow = 0
            }
        }
        else{
            self.guanzhu.setTitleColor(colour, for: .normal)
            self.guanzhu.setTitle("关注".toLocal(), for: .normal)
            self.did_follow = 0
        }
        
        ////////////////// table
        self.view.backgroundColor = light
        self.tableView.backgroundColor = mid
        
        //        self.title = self.title_name
        lock = NSLock()
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        //self.tableView!.separatorInset = UIEdgeInsetsMake(0, 3, 0, 20);
        
        self.tableView!.estimatedRowHeight = 150
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        self.refresh()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
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
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        })
        dynamoDbObjectMapper.save(temp, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
    }
    
    @IBAction func comments(_ sender: Any) {
        // small = 1
        self.comment_click = true
        self.performSegue(withIdentifier: "comment_zhuye_other", sender: sender)
        
        
    }
    @IBAction func share(_ sender: Any) {
        
        self.performSegue(withIdentifier: "pyq_share_zhuye_other", sender: sender)
        
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if small == 0
        self.performSegue(withIdentifier: "show_post_detail_zhuye_other", sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //
        //        let logo = UIImage(named: "name")
        //        let imageView = UIImageView(image:logo)
        //        self.navigationItem.titleView = imageView
        //   self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName:colour] as [NSAttributedStringKey : Any]
        
        self.navigationController?.toolbar.barTintColor = sign_in_colour
        if(posts.count == 0)
        {refresh()}
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "other_zhuye", for: indexPath) as! MyTableViewCell
        // tableView.register(MyTableViewCell.self, forCellReuseIdentifier: "MyTableViewCell")
        let temp:ChanceWithValue = posts[indexPath.row]
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
        
        
        
        
        
        
        
        //print("title: \(temp._title)" + "count: \(cell.images.count)")
        // print()
        
        //cell.image_collection.backgroundColor = mid
        
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
    
    
    @IBAction func share_detail(_ sender: Any) {
        //print("row: \((sender as! UIButton).tag)")
        self.performSegue(withIdentifier: "share_detail_other", sender: sender)
    }
    
    
    
    
    @objc func bigButtonTapped(_ recognizer:UITapGestureRecognizer) {
        //print("bigButtonTapped")
        self.performSegue(withIdentifier: "share_detail_other", sender: self)
    }
    
    func sort_posts(){
        var id_list:[Int] = []
        for a in posts
        {
            id_list.append(Int(a._id!)!)
        }
       // print(id_list)
        id_list.sort(by: >)
       // print(id_list)
        var temp_list:[ChanceWithValue] = []
        //print(id_list)
        //print(posts)
        for a in 0...posts.count - 1
        {
            for b in posts
            {
                //print(a)
                if b._id == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        posts = temp_list
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
        var key_list:[String] = []
            posts = []
            var temp_list:[ChanceWithValue] = []
     
            var heihei = dynamoDbObjectMapper.load(UserPool.self, hashKey: p._userId, rangeKey:nil)
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    if resultBook._chanceIdList != nil{
                        key_list = resultBook._chanceIdList!}
                    else
                    {
                        key_list = []
                    }
                   // print("keylist: \(key_list)")
                }
                return nil
            })
            heihei.waitUntilFinished()
        //print("892 keylist: \(key_list)")
        //print(p)
            for a in key_list{
                 let haha = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: a, rangeKey:nil)
                    haha.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let resultBook = task.result as? ChanceWithValue {
                        
                        self.posts.append(resultBook as! ChanceWithValue)
                    }
                    return nil
                })
                haha.waitUntilFinished()
               
            }
            
            
        //print(posts)
        //print("number: \(posts.count)")
        if self.posts.count > 0
        {self.sort_posts()}
        
        
        self.tableView.reloadData()
        
        self.refresher.endRefreshing()
        
        
        
    }
    
    
    


}
