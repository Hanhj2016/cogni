//
//  post_detail.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-30.
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

class post_detail: UIViewController, UIScrollViewDelegate,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var top_view: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profile_picture: UIImageView!
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var tagg: UIImageView!
    
    @IBOutlet weak var zhanwaifenxiang: UIButton!
    
    @IBOutlet weak var title_label: UILabel!
    
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var image_collection: UICollectionView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var top_view_height: NSLayoutConstraint!
    
    @IBOutlet weak var tool_bar: UIView!
    @IBOutlet weak var share_number: UIButton!
    
    @IBOutlet weak var comment_number: UIButton!
    @IBOutlet weak var like_number: UIButton!
    @IBOutlet weak var get: UIButton!
    
    @IBOutlet weak var bot_share: UIButton!
    @IBOutlet weak var bot_comment: UIButton!
    @IBOutlet weak var bot_like: UIButton!
    @IBOutlet weak var bot_bar: UIView!
    
    @IBOutlet weak var input_view: UIView!
    @IBOutlet weak var input: UITextView!
    @IBOutlet weak var send: UIButton!
    
    @IBOutlet weak var share_view: UIView!
    @IBOutlet weak var share_profile_picture: UIImageView!
    
    @IBOutlet weak var share_username: UILabel!
    @IBOutlet weak var share_title: UILabel!
    @IBOutlet weak var table_height: NSLayoutConstraint!
    
    
    
    
    var comment_click = false
    var share_click = false
    let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
    
    var p: ChanceWithValue = ChanceWithValue()
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat
    var images:[UIImage] = []
    var comments:[CommentTable] = []
    
    
    @IBAction func share_detail(_ sender: Any) {
        print("in")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let id = p._sharedFrom![0]
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                nextViewController.p = resultBook
                
            }
            return nil
        })
        nextViewController.navigationController?.navigationBar.isHidden = false
        self.navigationController!.pushViewController(nextViewController, animated: true)
        //self.present(nextViewController, animated:true, completion:nil)
        
    }
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = colour
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    func get_time() -> String{
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
    
    @IBAction func share(_ sender: Any) {
        
        self.performSegue(withIdentifier: "detail_share", sender: sender)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail_share"
        {
            var upcoming: share = segue.destination as! share
            let s = sender as! UIButton
            let temp = p
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
        
        
        
        
    }
    
    @IBAction func send(_ sender: Any) {
        self.view.endEditing(true)
        let text = self.input.text
        if (text != "")
        {
            var temp_comment:CommentTable = CommentTable()
            
            
            var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            var queryExpression = AWSDynamoDBScanExpression()
            dynamoDbObjectMapper.scan(CommentTable.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
                DispatchQueue.main.async(execute: {
                    if let paginatedOutput = task{
                        
                        //print(paginatedOutput.items.count)
                        let counter = paginatedOutput.items.count + 1
                        //print("counter: \(counter)")
                        temp_comment._chanceId = self.p._id
                        temp_comment._commentId = String(counter)
                        temp_comment._commentText = text
                        temp_comment._upTime = self.get_time()
                        temp_comment._userId = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
                        temp_comment._userPic = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + temp_comment._userId! + ".png"
                        
                        dynamoDbObjectMapper.save(temp_comment, completionHandler: nil)
                        if self.p._commentIdList != nil{
                            self.p._commentIdList!.append(String(counter))}
                        else {self.p._commentIdList = []
                            self.p._commentIdList!.append(String(counter))
                        }
                        var dynamoDbObjectMapper2 = AWSDynamoDBObjectMapper.default()
                        dynamoDbObjectMapper2.save(self.p, completionHandler: nil)
                        self.refresh()
                        self.tableView.reloadData()
                    }
                })
            })
        }
        self.input.text = ""
        self.input_view.isHidden = true
        
    }
    
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.setContentOffset(CGPoint(x:0,y:0), animated: true)
        
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        //print("after height: \(self.input_view.frame.maxY)")
        //print("after top height: \(self.top_view_height)")
       // if (self.top_view_height.constant > 200)
        scrollView.setContentOffset(CGPoint(x:0,y:300), animated: true)
//        else
//        {scrollView.setContentOffset(CGPoint(x:0,y:150), animated: true)}
    }
    
    @IBAction func comment_clicked(_ sender: Any) {
        //scrollView.setContentOffset(CGPoint(x:0,y:300), animated: true)
        self.input_view.isHidden = false
        self.input.becomeFirstResponder()
        
        
        //print("clicked")
    }
    
    @IBAction func like_clicked(_ sender: Any) {
        let temp:ChanceWithValue = self.p
        var contain = false
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
                contain = false
            }
            else
            {
                temp._liked?.append(user!)
                contain = true
            }}
        else
        {
            temp._liked = [user] as? [String]
            contain = true
        }
        self.p = temp
        DispatchQueue.main.async(execute: {
            if  contain{
                self.bot_like.setTitleColor(colour, for: .normal)
                self.bot_like.tintColor = colour
                self.bot_like.setTitle("取消", for: .normal)
            }
            else{
                self.bot_like.setTitleColor(text_mid, for: .normal)
                self.bot_like.tintColor = text_mid
                self.bot_like.setTitle("点赞", for: .normal)
            }
            
            })
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.save(temp, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
        
    }
    
    
    
    
    
    
    @objc func refresh() {
        
        if self.p._commentIdList != nil
        {
            for comment_id in self.p._commentIdList!{
                let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                dynamoDbObjectMapper.load(CommentTable.self, hashKey: comment_id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let resultBook = task.result as? CommentTable {
                        //print("in")
                        if self.comments.count < (self.p._commentIdList?.count)!
                        {
                            if !self.comments.contains(resultBook)
                            {self.comments.append(resultBook)}
                            //print("comment number: \(self.comments.count)")
                        }
                    }
                    return nil
                })
            }
        }
        
        DispatchQueue.main.async(execute: {
            //self.title = self.user?.username
            self.tableView.reloadData()
            if self.comments.count > 0{
                self.sort_comments()}
        })
        
        
        //print("158: \(self.comments.count)")
        
        //***********************
        
        
        
        self.refresher.endRefreshing()
        
        
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell",
                                                       for: indexPath) as! MyCollectionViewCell
        
        cell.photo.image = images[indexPath.row]
        cell.photo.tag = indexPath.row
        cell.photo.isUserInteractionEnabled = true
        //self.myViewController.view.addSubview(cell.photo)
        // this above line makes images big dont know why
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        cell.photo.addGestureRecognizer(tapSingle)
        return cell
        
    }
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: images, index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        while(p._username == nil)
        {
        }
        self.view.addSubview(self.bot_bar)
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
        //self.tableView.backgroundColor = light
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView!.delegate = self
        //self.tableView!.dataSource = self as! UITableViewDataSource
        self.scrollView.backgroundColor = mid
        self.view.backgroundColor = mid
        
        
        self.input_view.backgroundColor = sign_in_colour
        self.input.backgroundColor = sign_in_colour
        self.send.backgroundColor = sign_in_colour
        
        self.input_view.layer.cornerRadius = 5.0
        self.input.layer.cornerRadius = 5.0
        self.send.layer.cornerRadius = 5.0
        
        self.input.textColor = text_light
        self.send.tintColor = colour
        
        
        
        tableView!.estimatedRowHeight = 150
        tableView!.rowHeight = UITableViewAutomaticDimension
        
        //print("out: \(comments.count)")
        
        
        self.top_view.backgroundColor = mid
        self.view.backgroundColor = light
        self.image_collection.delegate = self
        self.image_collection.dataSource = self
        
        // 注册CollectionViewCell
        self.image_collection!.register(UINib(nibName:"MyCollectionViewCell", bundle:nil),forCellWithReuseIdentifier: "myCell")
        
        let date = Date()
        let calendar = Calendar.current
        var time__:[Int] = []
        time__.append(calendar.component(.year, from: date)) // 0
        time__.append(calendar.component(.month, from: date)) // 1
        time__.append(calendar.component(.day, from: date)) //2
        time__.append(calendar.component(.hour, from: date)) // 3
        time__.append(calendar.component(.minute, from: date)) // 4
        time__.append(calendar.component(.second, from: date)) // 5
        
        scrollView.contentSize = CGSize(width:UIScreen.main.bounds.width, height:scrollViewContentHeight)
        scrollView.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        scrollView.bounces = false
        tableView.bounces = true
        tableView.isScrollEnabled = true
        // Do any additional setup after loading the view.
        
        
        
        if ((p._username) != nil)
        {self.username.text = p._username
            self.username.textColor = text_light
            self.username.font = self.username.font.withSize(17)
        }
        if ((p._title) != nil)
        {self.title_label.text = p._title
            self.title_label.font = self.title_label.font.withSize(15)
            self.title_label.textColor = text_light
            
        }
        if ((p._text) != nil)
        {self.content.text = p._text
            self.content.font = self.content.font.withSize(14)
            self.content.textColor = text_light
            self.content.numberOfLines = 0
            self.content.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.content.sizeToFit()
            self.content.backgroundColor = mid
        }
        else
        {
            self.content.isHidden = true
        }
        
        
        var url: URL
        if (p._profilePicture != nil){
            url = URL(string:p._profilePicture!)!
            self.profile_picture.image = UIImage(data:try! Data(contentsOf: url))}
        //displaying pictures
        if (p._pictures != nil)&&(p._pictures?.count != 0)
        {
            
            //DispatchQueue.main.async(execute: {
            for i in 0...(p._pictures?.count)!-1
            {
                
                let url = URL(string:p._pictures![i])!
                //  self.urls.append(url)
                var data:NSData = try! NSData(contentsOf: url)
                let image = UIImage(data: data as Data)!
                self.images.append(image)
                
            }
            
            
            
            
            
            //})
        }
        
        
        
        if ((p._time) != nil)
        {//using the easy way
            
            
            
            var output = ""
            let _time = p._time as! Int
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
            var a = time__[0] % 100
            //   print("year:\(year)..month:\(month)..day:\(day)")
            
            if year == a
            {
                if day == time__[2]
                {
                    if hour == time__[3]
                    {
                        if Minute == time__[4]
                        {output = "\(time__[5]-second) 秒前"}
                        else if time__[4] - Minute == 1
                        {
                            if (time__[5]+60-second <= 60)
                            {output = "\(time__[5]+60-second) 秒前"}
                            else
                            {output = "1分钟前"}
                            
                        }
                        else
                        {output = "\(time__[4]-Minute) 分钟前"}
                    }
                    else if time__[3] - hour == 1
                    {
                        if time__[4]+60-Minute <= 60
                        {output = "\(time__[4]+60-Minute) 分钟前"}
                        else
                        {output = "\(hour):\(Minute)"}
                    }
                    else
                    {
                        output = "\(hour):\(Minute)"
                    }
                }
                else if time__[2] == (day + 1)
                {
                    output = "昨天\(hour):\(Minute)"
                }
                else if time__[2] == day + 2
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
            
            self.time.font = self.time.font.withSize(13)
            self.time.text = output
            self.time.textColor = text_mid
            
            
            
            
        }
        
        if ((p._tag) != nil)
        {
            let t = p._tag
            if t == 1
            {self.tagg.image = UIImage(named: "huodong")}
            else if t == 2
            {self.tagg.image = UIImage(named: "renwu")}
            else if t == 0
            {self.tagg.image = UIImage(named: "yuema")}
            else if t == 3
            {self.tagg.image = UIImage(named: "qita")}
        }
        if ((p._profilePicture != nil))
        {
            let url = URL(string: p._profilePicture!)
            let data = try? Data(contentsOf: url!)
            // self.profile_picture.image = UIImage(data: data!)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = UIColor.white.cgColor
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
        }
        
        self.get.layer.borderWidth = 1.0
        self.get.layer.cornerRadius = self.get.frame.height/2
        self.get.backgroundColor = colour
        self.get.tintColor = mid
        
        self.image_collection.reloadData()
        let contentSize = self.image_collection.collectionViewLayout.collectionViewContentSize
        let text_content_size = self.content.frame.height
        self.image_collection.collectionViewLayout.invalidateLayout()
        self.collectionViewHeight.constant = contentSize.height
        self.top_view_height.constant = 70 + text_content_size + contentSize.height + 80
        self.image_collection.backgroundColor = mid
        
        self.tool_bar.backgroundColor = mid
        self.like_number.backgroundColor = mid
        self.like_number.tintColor = text_mid
        if self.p._liked != nil
        {self.like_number.setTitle("赞 \((self.p._liked?.count)!)", for: .normal)}
        else
        {self.like_number.setTitle("赞 0", for: .normal)}
        
        
        self.share_number.backgroundColor = mid
        self.share_number.tintColor = text_mid
        if self.p._shared != nil
        {self.share_number.setTitle("转发 \(self.p._shared!)", for: .normal)}
        else
        {self.share_number.setTitle("转发 0", for: .normal)}
        
        var comment_number = 0
        if self.p._commentIdList != nil
        {
            comment_number = (p._commentIdList?.count)!
        }
        self.comment_number.backgroundColor = mid
        self.comment_number.tintColor = text_mid
        if self.p._commentIdList != nil
        {self.comment_number.setTitle("评论 \(comment_number)", for: .normal)}
        else
        {self.comment_number.setTitle("评论 0", for: .normal)}
        
        self.tableView.backgroundColor = mid
        //print("bot: \(self.comments.count)")
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        self.refresh()
        if p._commentIdList != nil
        {
            while (self.comments.count < p._commentIdList?.count as! Int)
            {
                //self.refresh()
            }
        }
        self.bot_like.backgroundColor = sign_in_colour
        let origImage = UIImage(named: "dianzan")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        self.bot_like.setImage(tintedImage, for: .normal)
        if (p._liked != nil){
        if (p._liked?.contains(user!))!
        {
            self.bot_like.setTitleColor(colour, for: .normal)
            self.bot_like.tintColor = colour
            self.bot_like.setTitle("取消", for: .normal)
        }
        else
        {
            self.bot_like.setTitleColor(text_mid, for: .normal)
            self.bot_like.tintColor = text_mid
            self.bot_like.setTitle("点赞", for: .normal)
        }
        }
        
        self.bot_comment.backgroundColor = sign_in_colour
        self.bot_share.backgroundColor = sign_in_colour
         //print("before top height: \(self.top_view_height)")
        
        if p._sharedFrom == nil //no share
        {
            self.share_view.isHidden = true
        }
        else
        {
            self.share_view.isHidden = false
           
            self.collectionViewHeight.constant = 130
            let url = URL(string:p._sharedFrom![3])!
            self.share_profile_picture.image = UIImage(data:try! Data(contentsOf: url))
            self.share_title.text = p._sharedFrom![2]
            self.share_username.text = p._sharedFrom![1]
            self.share_username.textColor = text_light
            self.share_view.backgroundColor = sign_in_colour
            self.share_title.textColor = text_light
            self.share_title.font = self.share_title.font.withSize(14)
            self.share_title.numberOfLines = 0
            self.share_title.lineBreakMode = NSLineBreakMode.byWordWrapping
            self.share_title.sizeToFit()
        }
        
        
        DispatchQueue.main.async(execute: {
            if self.comment_click
            {self.comment_clicked(self)}
            if self.share_click
            {self.comment_clicked(self)}
        })
        
        //print(" Collect Height: \(collectionViewHeight)")
        //print("tool bar bot: \(tool_bar.frame.maxY)")
        self.table_height.constant = screenHeight - 180 - collectionViewHeight.constant - 140
        
        
        
        
    }
    
    func sort_comments(){
        var id_list:[Int] = []
        for a in comments
        {
            id_list.append(Int(a._commentId!)!)
        }
        id_list.sort(by: >)
        var temp_list:[CommentTable] = []
        
        for a in 0...comments.count - 1
        {
            for b in comments
            {
                if b._commentId == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        comments = temp_list
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.setToolbarHidden(false, animated: true)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.tableView.indexPathForSelectedRow!.row
        self.input_view.isHidden = false
        self.input.becomeFirstResponder()
        self.input.text = "回复 \(comments[row]._userId!) ："
    }
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! comment_cell
        let index = indexPath.row
        
        if ((comments[index]._userPic != nil))
        {
            let url = URL(string: comments[index]._userPic!)
            do{
            let data = try? Data(contentsOf: url!)}
            cell.profile_picture.image = UIImage(data:try! Data(contentsOf: url!))
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = UIColor.white.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            //print("438")
        }
        
        
        if ((comments[index]._userId) != nil)
        {cell.username.text = comments[index]._userId
            cell.username.textColor = text_light
            cell.username.font = cell.username.font.withSize(17)
        }
        //print("439")
        if ((comments[index]._commentText) != nil)
        {cell.content.text = comments[index]._commentText
            cell.content.font = cell.content.font.withSize(14)
            cell.content.textColor = text_light
            cell.content.numberOfLines = 0
            cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.content.sizeToFit()
            cell.content.backgroundColor = mid
        }
        
        
        
        if ((comments[index]._upTime) != nil)
        {//using the easy way
            
            let date = Date()
            let calendar = Calendar.current
            var time__:[Int] = []
            time__.append(calendar.component(.year, from: date)) // 0
            time__.append(calendar.component(.month, from: date)) // 1
            time__.append(calendar.component(.day, from: date)) //2
            time__.append(calendar.component(.hour, from: date)) // 3
            time__.append(calendar.component(.minute, from: date)) // 4
            time__.append(calendar.component(.second, from: date)) // 5
            
            var output = ""
            let _time = Int(comments[index]._upTime!)
            let second = _time! % 100
            var Rem = _time! / 100
            let Minute = Rem % 100
            Rem = Rem / 100
            let hour = Rem % 100
            Rem = Rem / 100
            let day = Rem % 100
            Rem = Rem / 100
            let month = Rem % 100
            Rem = Rem / 100
            let year = (Rem % 100)%100
            var a = time__[0] % 100
            //   print("year:\(year)..month:\(month)..day:\(day)")
            
            if year == a
            {
                if day == time__[2]
                {
                    if hour == time__[3]
                    {
                        if Minute == time__[4]
                        {output = "\(time__[5]-second) 秒前"}
                        else if time__[4] - Minute == 1
                        {
                            if (time__[5]+60-second <= 60)
                            {output = "\(time__[5]+60-second) 秒前"}
                            else
                            {output = "1分钟前"}
                            
                        }
                        else
                        {output = "\(time__[4]-Minute) 分钟前"}
                    }
                    else if time__[3] - hour == 1
                    {
                        if time__[4]+60-Minute <= 60
                        {output = "\(time__[4]+60-Minute) 分钟前"}
                        else
                        {output = "\(hour):\(Minute)"}
                    }
                    else
                    {
                        output = "\(hour):\(Minute)"
                    }
                }
                else if time__[2] == (day + 1)
                {
                    output = "昨天\(hour):\(Minute)"
                }
                else if time__[2] == day + 2
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
            
            cell.time.font = cell.time.font.withSize(13)
            cell.time.text = output
            cell.time.textColor = text_mid
            
            
            
            
        }
        
        
        cell.backgroundColor = mid
        
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
}
