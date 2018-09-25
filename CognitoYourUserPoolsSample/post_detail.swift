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
import PCLBlurEffectAlert
class post_detail: UIViewController, UIScrollViewDelegate,UITableViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UITableViewDataSource {
    
    @IBOutlet weak var tag_label: UILabel!
    @IBOutlet weak var content_height: NSLayoutConstraint!
    @IBOutlet weak var button_height: NSLayoutConstraint!
    @IBOutlet weak var alertview: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var share_detail: UIButton!
    @IBAction func share_detail(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //print("in")
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let id = p._sharedFrom![0]
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil)
        heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                nextViewController.p = resultBook
                
            }
            return nil
        })
        heihei.waitUntilFinished()
        nextViewController.navigationController?.navigationBar.isHidden = false
        self.navigationController!.pushViewController(nextViewController, animated: true)
        //self.present(nextViewController, animated:true, completion:nil)
        
    }
    
    
 
    @IBOutlet weak var post_content: UILabel!
    @IBOutlet weak var ok: UILabel!
    @IBOutlet weak var wodejihui: UILabel!
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
    @IBOutlet weak var input_height: NSLayoutConstraint!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var tool_bar_height: NSLayoutConstraint!
    
    
    
    
    var comment_click = false
    var share_click = false
    let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
    
    var p: ChanceWithValue = ChanceWithValue()
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat
    var images:[UIImage] = []
    var comments:[CommentTable] = []
    
    
    @IBAction func get(_ sender: Any) {
        
        var con_count = 0
        var uncon_count = 0
        if p._confirmList != nil
        {con_count = (p._confirmList?.count)!}
        if p._unConfirmList != nil
        {uncon_count = (p._unConfirmList?.count)!}
        if con_count + uncon_count == Int(p._renShu!)
       {
        let alertController = UIAlertController(title: "哟".toLocal(),
                                                message: "人刚好满了".toLocal(),
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion:  nil)
        return
        }
        
        var expense = 0.0
        if self.p._shouFei != nil
        {expense = Double(self.p._shouFei!) }
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        var avail = 0.0
        var froz = 0.0
        
        let haha = dynamoDbObjectMapper.load(UserPool.self, hashKey: user, rangeKey:nil)
        var user_pool:UserPool = UserPool()
        haha.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? UserPool {
                avail = resultBook._availableWallet as! Double
                froz = resultBook._frozenwallet as! Double
                user_pool = resultBook
                //print("bs \(avail)")
                //print("this bs comes again")
            }
            return nil
        })
        haha.waitUntilFinished()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            
        }
        
        
        if p._shouFei != nil && p._shouFei != 0{
            expense = Double(self.p._shouFei!)
            //print("133 \(avail)")
            //print("134 \(expense)")
        if avail < expense {
            let alertController = UIAlertController(title: "无法通过".toLocal(),
                                                    message: "钱包可用金额不足".toLocal(),
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }else
        {
            avail = avail - expense
            froz = froz + expense
            user_pool._availableWallet = avail as NSNumber
            user_pool._frozenwallet = froz as NSNumber
           if user_pool._gottenList == nil
           {user_pool._gottenList = [p._id!]}
            else
           {
            user_pool._gottenList!.append(p._id!)
            }
            dynamoDbObjectMapper.save(user_pool,completionHandler:nil)
            
            if p._getList != nil
            {p._getList!.append(user!)}
            else
            {p._getList = [user!]}
            
            dynamoDbObjectMapper.save(p,completionHandler:nil)
            self.alertview.isHidden = false
            
            return
        }
        }
        
        
    
        if user_pool._gottenList == nil
        {user_pool._gottenList = [p._id!]}
        else
        {
            user_pool._gottenList!.append(p._id!)
        }
        dynamoDbObjectMapper.save(user_pool,completionHandler:nil)
        
        if p._getList != nil
        {p._getList!.append(user!)}
        else
        {p._getList = [user!]}
        
        dynamoDbObjectMapper.save(p,completionHandler:nil)
        
        
      
        
        
       
        //print("heihei")
        self.alertview.isHidden = false
        
        
    }
    
    
    
    
    
    
     @objc func share_tap(sender : MyTapGesture){
        //print("in")
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //print("in")
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "post_detail") as! post_detail
        let id = p._sharedFrom![0]
        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let heihei = dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil)
            heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? ChanceWithValue {
                nextViewController.p = resultBook
                
            }
            return nil
        })
       heihei.waitUntilFinished()
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
                if temp._profilePicture != nil{
                    upcoming.profile_picture_link = temp._profilePicture!}
                else
                {
                    upcoming.profile_picture_link = ""
                }
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
       
        self.table_height.constant = 500
        self.input_height.constant = 10
    }
    
    @objc func keyboardWillAppear(notification: NSNotification) {
        
        
        
        let userInfo = notification.userInfo
        let keyboardframe = (userInfo![UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
        let difference = self.screenHeight - (self.navigationController?.navigationBar.frame.height)! - self.top_view_height.constant - self.input_view.frame.height -
            keyboardframe!.height
        var offset = 0
        if difference < 200
        {
            offset = Int(200 - difference)
        }
        self.input_height.constant = keyboardframe!.height
      //  print("height: \(self.input_height.constant)")
        
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
                let number = Int(self.bot_like.title(for: .normal)!)
                if number == 1{
                    self.bot_like.setTitle("", for: .normal)
                }else
                {
                    self.bot_like.setTitle(String(number! - 1), for: .normal)
                }
                //self.bot_like.setTitle("取消", for: .normal)
            }
            else{
                self.bot_like.setTitleColor(text_mid, for: .normal)
                self.bot_like.tintColor = text_mid
                
                if self.bot_like.title(for: .normal) == ""
                {
                    self.bot_like.setTitle("1", for: .normal)
                }
                else{
                let number = Int(self.bot_like.title(for: .normal)!)
                
                    self.bot_like.setTitle(String(number! + 1), for: .normal)
                
                }
                
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
                let heihei = dynamoDbObjectMapper.load(CommentTable.self, hashKey: comment_id, rangeKey:nil)
                    heihei.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
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
                heihei.waitUntilFinished()
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
        if p._pictures != nil{
            return p._pictures!.count}
        else
        {
            return 0
        }
        
    }
     var image_links:[String] = []
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell",
                                                       for: indexPath) as! MyCollectionViewCell
        let message = self.image_links[indexPath.row].deletingPrefix("https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/")
        if let cachedVersion = imageCache.object(forKey: message as NSString) {
            cell.photo.image = cachedVersion
            if !self.images.contains(cachedVersion){
                self.images.append(cachedVersion)}
        }
        else{
            downloadImage(key_: message, destination: cell.photo)
            //print("title: \(self.title.text) count: \(self.images.count)" )
        }
        
        cell.photo.backgroundColor = sign_in_colour
        cell.photo.contentMode = .scaleAspectFit
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
        //print("count: \(images.count) index: \(index)" )
        images = []
        var image_dick:[Int:Int] = [:]
        var counter = 0
        for a in 0...self.image_links.count - 1
        {
            let indexPath = IndexPath(item: a, section: 0)
            if let x = (self.image_collection.cellForItem(at: indexPath) as! MyCollectionViewCell).photo.image
            {
                images.append(x)
                image_dick[a] = counter
                counter = counter + 1
            }
        }
        
        let previewVC = ImagePreviewVC(images: images, index: image_dick[index]!)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    
    @objc func wodejihui_(sender : MyTapGesture){
        let title_name = "我的机会".toLocal()
        
        //performSegue(withIdentifier: "zhuye", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "zhuye") as! zhuye
        
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        
           let lala = dynamoDbObjectMapper.load(UserPool.self, hashKey: user, rangeKey:nil)
            lala.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool{
                     new_chat.p = resultBook
                }
                return nil
            })
        
        lala.waitUntilFinished()
        
        
        
       
        new_chat.title = "我的机会".toLocal()
        self.navigationController?.pushViewController(new_chat, animated: true)
        
    }
    
    @objc func cancel_alert(sender : MyTapGesture){
        //print("im in dude")
        self.alertview.isHidden = true
        self.get.isHidden = true
        var ren = 0
        var ge = 0
        var conf = 0
        var unconf = 0
        if p._renShu != nil && p._renShu != 0
        {
            ren = p._renShu as! Int
        }
        if p._getList != nil
        {
            ge = (p._getList?.count)!
        }
        if p._confirmList != nil
        {
            conf = (p._confirmList?.count)!
        }
        if p._unConfirmList != nil
        {
            unconf = (p._unConfirmList?.count)!
        }
        
        let left = ren - ge - conf - unconf
        self.like_number.setTitle("还剩".toLocal() + " \(left)" + "人".toLocal(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        while(p._username == nil)
        {
            print("post_detail: wasting time here man")
        }
        
        self.alertview.layer.cornerRadius = 5.0
        
        let tap8:MyTapGesture = MyTapGesture(target: self, action: #selector(share_tap))
         let tap9:MyTapGesture = MyTapGesture(target: self, action: #selector(share_tap))
         let tap10:MyTapGesture = MyTapGesture(target: self, action: #selector(share_tap))
        if p._sharedFrom != nil{
            tap8.username = p._sharedFrom![0]
            tap9.username = p._sharedFrom![0]
            tap10.username = p._sharedFrom![0]
           self.share_profile_picture.backgroundColor = sign_in_colour
            self.share_profile_picture.contentMode = .scaleAspectFit
            self.share_detail.isHidden = false
            
            self.image_collection.isHidden = true
            
            self.share_view.isHidden = false
            self.share_view.isUserInteractionEnabled = true
           self.share_view.addGestureRecognizer(tap8)
            

        }
        else
        {
            self.share_view.isHidden = true
            self.share_detail.isHidden = true
            self.image_collection.isHidden = false
        }
        
        
        self.alertview.isHidden = true
        let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
        let tap2: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
        tap.username = p._username!
        //tap.cancelsTouchesInView = true
        //tap2.username = p._username!
        tap2.cancelsTouchesInView = true
        
        
        let tap3:MyTapGesture = MyTapGesture(target: self, action: #selector(cancel_alert))
        //tap3.cancelsTouchesInView = true
        self.ok.isUserInteractionEnabled = true
        self.ok.addGestureRecognizer(tap3)
        
        
        let tap4:MyTapGesture = MyTapGesture(target: self, action: #selector(wodejihui_))
        self.wodejihui.isUserInteractionEnabled = true
        self.wodejihui.addGestureRecognizer(tap4)
        
        var con_count = 0
        var uncon_count = 0
        if p._confirmList != nil
        {con_count = (p._confirmList?.count)!}
        if p._unConfirmList != nil
        {uncon_count = (p._unConfirmList?.count)!}
        
      
        var ren = 0
        var ge = 0
        var conf = 0
        var unconf = 0
        if p._renShu != nil && p._renShu != 0
        {
            ren = p._renShu as! Int
        }
        if p._getList != nil
        {
            ge = (p._getList?.count)!
        }
        if p._confirmList != nil
        {
            conf = (p._confirmList?.count)!
        }
        if p._unConfirmList != nil
        {
            unconf = (p._unConfirmList?.count)!
        }
        
        let left = ren - ge - conf - unconf
        
      
        
        self.profile_picture.isUserInteractionEnabled = true
        self.profile_picture.addGestureRecognizer(tap)
        
        self.username.isUserInteractionEnabled = true
        self.username.addGestureRecognizer(tap2)
        
        self.label1.backgroundColor = colour
        self.label1.layer.cornerRadius = 5.0
        self.label1.textColor = sign_in_colour
        self.label2.textColor = colour
        self.label3.textColor = colour
        var in_or_out = ""
        if p._fuFei != nil && Double(p._fuFei!) > 0
        {
            in_or_out = "福利".toLocal()
            self.label1.text = in_or_out
            self.label2.text = "\(p._fuFei!) \(p._fuFeiType!)"
            self.label3.text = "还剩 \(left) 人"
        }
        else if p._shouFei != nil && Double(p._shouFei!) > 0
        {
            in_or_out = "服务".toLocal()
            self.label1.text = in_or_out
            self.label2.text = "\(p._shouFei!) \(p._shouFeiType!)"
            self.label3.text = "还剩 \(left) 人"
        }
        else
        {
            self.label1.isHidden = true
            self.label2.isHidden = true
            self.label3.isHidden = true
        }
        //self.label1.text =
        
        
        //self.view.addSubview(self.input_view)
        self.zhanwaifenxiang.isHidden = true
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : colour]
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
        scrollView.bounces = true
        tableView.bounces = true
        tableView.isScrollEnabled = true
        scrollView.isScrollEnabled = true
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
            self.content_height.constant = self.content.text!.height(withConstrainedWidth: self.content.frame.width, font: self.content.font)
        }
        else
        {
            //self.content.isHidden = true
            self.content_height.constant = 0
        }
        
        
        var url: URL
        
        if (p._pictures != nil)&&(p._pictures?.count != 0)
        {
            for i in 0...(p._pictures?.count)!-1
            {
                
                var message = p._pictures![i]
                if let cachedVersion = imageCache.object(forKey: message as NSString) {
                    self.images.append(cachedVersion)
                    //print("1")
                }
                else{
                    message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                    var data:NSData = try! NSData(contentsOf: URL(string:message)!)
                    let image = UIImage(data: data as Data)!
                    set_image_cache(key: message, image: image)
                    // print("2")
                }
                
                
            }
        }
        if (p._profilePicture != nil){
            
            if let cachedVersion = imageCache.object(forKey: "\(p._username!).png" as NSString) {
                self.profile_picture.image = cachedVersion
            }
            else{
                downloadImage(key_: "\(p._username!).png", destination: self.profile_picture)
            }
        }
        else
        {self.profile_picture.image = UIImage(named: "girl")}
        
    
        
        
        
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
                        {output = "\(time__[5]-second) " + "秒前".toLocal()}
                        else if time__[4] - Minute == 1
                        {
                            if (time__[5]+60-second < 60)
                            {output = "\(time__[5]+60-second) " + "秒前".toLocal()}
                            else
                            {output = "1" + "分钟前".toLocal()}
                            
                        }
                        else
                        {output = "\(time__[4]-Minute) " + "分钟前".toLocal()}
                    }
                    else if time__[3] - hour == 1
                    {
                        if time__[4]+60-Minute < 60
                        {output = "\(time__[4]+60-Minute) " + "分钟前".toLocal()}
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
                else if time__[2] == (day + 1)
                {
                    if Minute < 10{
                        output = " \(hour):0\(Minute)"
                    }else{
                        output = " \(hour):\(Minute)"}
                    output = "昨天".toLocal() + output
                }
                else if time__[2] == day + 2
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
            
            self.time.font = self.time.font.withSize(13)
            self.time.text = output
            self.time.textColor = text_mid
            
            
            
            
        }
        
        self.tagg.isHidden = true
        //cell.tag_label.isHidden = true
        self.tag_label.backgroundColor = tag_colour
        self.tag_label.layer.cornerRadius = 8.0
        self.tag_label.layer.masksToBounds = false
        self.tag_label.clipsToBounds = true
        self.tag_label.font = self.tag_label.font.withSize(9)
        if ((p._tag) != nil)
        {
            let t = p._tag
            if t == 1
            {//cell.tagg.image = UIImage(named: "huodong")
                self.tag_label.text = "活动".toLocal()
            }
            else if t == 2
            {//cell.tagg.image = UIImage(named: "renwu")
                self.tag_label.text = "任务".toLocal()
            }
            else if t == 0
            {//cell.tagg.image = UIImage(named: "yuema")
                self.tag_label.text = "约嘛".toLocal()
            }
            else if t == 3
            {//cell.tagg.image = UIImage(named: "qita")
                self.tag_label.text = "其他".toLocal()
            }
        }
        
        if ((p._profilePicture != nil))
        {
            
            // self.profile_picture.image = UIImage(data: data!)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = mid.cgColor
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
        }
        
        self.get.layer.borderWidth = 1.0
        self.get.layer.cornerRadius = self.get.frame.height/2
        self.get.backgroundColor = colour
        self.get.tintColor = mid
        
        self.image_links = []
        if (p._pictures != nil)&&(p._pictures?.count != 0)
        {
            for i in 0...(p._pictures?.count)!-1
            {
                
                self.image_links.append(p._pictures![i])
            }
        }
        self.image_collection.reloadData()
        let contentSize = self.image_collection.collectionViewLayout.collectionViewContentSize
        
        var text_content_size:CGFloat = 0.0
        if p._text != nil{ text_content_size = self.content.frame.height}
        self.image_collection.collectionViewLayout.invalidateLayout()
     
        self.collectionViewHeight.constant = contentSize.height
       // self.button_height.constant = contentSize.height
       // print("height: \(contentSize.height)")
        self.top_view_height.constant = 70 + text_content_size + contentSize.height + 80
        self.image_collection.backgroundColor = mid
        
       // self.share_detail.backgroundColor = UIColor.red
       // self.button_height.constant = 150
       // self.view.addSubview(self.share_detail)
        self.tool_bar.backgroundColor = mid
        self.like_number.backgroundColor = mid
        self.like_number.tintColor = colour
        if self.p._liked != nil
        {self.like_number.setTitle("赞".toLocal() + "\((self.p._liked?.count)!)", for: .normal)}
        else
        {self.like_number.setTitle("赞".toLocal() + "0", for: .normal)}
        
        
        self.share_number.backgroundColor = mid
        self.share_number.tintColor = colour
        if self.p._shared != nil
        {self.share_number.setTitle("转发".toLocal() + " \(self.p._shared!)", for: .normal)}
        else
        {self.share_number.setTitle("转发".toLocal() + "0", for: .normal)}
        
        var comment_number = 0
        if self.p._commentIdList != nil
        {
            comment_number = (p._commentIdList?.count)!
        }
        self.comment_number.backgroundColor = mid
        self.comment_number.tintColor = colour
        if self.p._commentIdList != nil
        {self.comment_number.setTitle("评论".toLocal() + "\(comment_number)", for: .normal)}
        else
        {self.comment_number.setTitle("评论".toLocal() + "0", for: .normal)}
        
        
        
        if p._fuFei != nil && Double(p._fuFei!) > 0
        {
            in_or_out = "付费".toLocal()
            self.share_number.setTitle(in_or_out, for: .normal)
            self.comment_number.setTitle("\(p._fuFei!) \(p._fuFeiType!)", for: .normal)
            self.like_number.setTitle("还剩".toLocal() + "\(left) " + "人".toLocal(), for: .normal)
        }
        else if p._shouFei != nil && Double(p._shouFei!) > 0
        {
            in_or_out = "收费".toLocal()
            self.share_number.setTitle(in_or_out, for: .normal)
            self.comment_number.setTitle("\(p._shouFei!) \(p._shouFeiType!)", for: .normal)
            self.like_number.setTitle("还剩".toLocal() + "\(left) " + "人".toLocal(), for: .normal)
        }
        else
        {
            self.share_number.isHidden = true
            self.like_number.isHidden = true
            self.comment_number.isHidden = true
            self.tool_bar_height.constant = 0
        }
        
        
        
        
        
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
            //self.bot_like.setTitle("取消", for: .normal)
            
        }
        else
        {
            self.bot_like.setTitleColor(text_mid, for: .normal)
            self.bot_like.tintColor = text_mid
           // self.bot_like.setTitle("点赞", for: .normal)
        }
        }
        else
        {
            self.bot_like.setTitleColor(text_mid, for: .normal)
            self.bot_like.tintColor = text_mid
            //self.bot_like.setTitle("点赞", for: .normal)
        }
        if self.p._liked?.count != nil && self.p._liked?.count != 0{
            self.bot_like.setTitle("\((self.p._liked?.count)!)", for: .normal)}
        else{
            self.bot_like.setTitle("", for: .normal)
        }
        
        if self.p._commentIdList?.count != nil && self.p._commentIdList?.count != 0{
            self.bot_comment.setTitle("\((self.p._commentIdList?.count)!)", for: .normal)}
        else{
            self.bot_comment.setTitle("", for: .normal)
        }
        if self.p._shared != nil && self.p._shared != 0{
            self.bot_share.setTitle("\((self.p._shared)!)", for: .normal)}
        else{
            self.bot_share.setTitle("", for: .normal)
        }
        
        
        
        
        self.bot_comment.backgroundColor = sign_in_colour
        self.bot_share.backgroundColor = sign_in_colour
         //print("before top height: \(self.top_view_height)")
        if p._sharedFrom == nil //no share
        {
            self.share_view.isHidden = true
            self.share_profile_picture.isHidden = true
            self.content.isHidden = false
           // self.content_height.constant = 0
            
        }
        else
        {
            self.content_height.constant = 0
            self.content.isHidden = true
            self.share_view.isHidden = false
            self.share_profile_picture.isHidden = false
            //print("height: \(cell.share_view.frame.height)")
            self.collectionViewHeight.constant = 130
            self.share_profile_picture.backgroundColor = sign_in_colour
            self.share_profile_picture.contentMode = .scaleAspectFit
            self.share_profile_picture.image = UIImage(named:"morenzhuanfa")
            var link = p._sharedFrom![3].deletingPrefix("https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/")
            
            if let cachedVersion = imageCache.object(forKey: link as NSString) {
                self.share_profile_picture.image = cachedVersion
            }
            else{
                downloadImage(key_: link, destination: self.share_profile_picture)
            }
            //downloadImage(key_: "\(temp._sharedFrom![1]).png".deletingPrefix("@"), destination: cell.share_profile_picture)
            self.share_title.text = p._sharedFrom![2]
            self.post_content.textColor = text_light
            if p._sharedFrom!.count > 4{
                self.post_content.text = p._sharedFrom![4]
                self.post_content.textColor = text_light
                self.post_content.isHidden = false
            }
            else
            {
                self.post_content.isHidden = true
            }
            self.share_username.text = p._sharedFrom![1]
            self.share_view.backgroundColor = sign_in_colour
            self.share_username.textColor = text_light
            self.share_title.textColor = text_light
        

        }
        
        
        DispatchQueue.main.async(execute: {
            if self.comment_click
            {self.comment_clicked(self)}
            if self.share_click
            {self.comment_clicked(self)}
        })
        
        
        self.table_height.constant = 500
        self.input_height.constant = 10
        self.label1.isHidden = true
        self.label2.isHidden = true
        self.label3.isHidden = true
        // get show
        if self.p._sharedFrom != nil || left == 0
        {self.get.isHidden = true
        }
        else
        {self.get.isHidden = false}
       if p._getList != nil && p._getList!.contains(user!)
       {self.get.isHidden = true
       }
        if p._confirmList != nil && p._confirmList!.contains(user!)
        {self.get.isHidden = true
        }
        if p._unConfirmList != nil && p._unConfirmList!.contains(user!)
        {self.get.isHidden = true
        }
       // p._confirmList!.contains(user!) || p._unConfirmList!.contains(user!)
        
     //   self.share_title.backgroundColor = UIColor.green
     //   self.share_username.backgroundColor = UIColor.green
    
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
        self.input.text = "回复".toLocal() + " \(comments[row]._userId!) ："
    }
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "comment_cell", for: indexPath) as! comment_cell
        let index = indexPath.row
        
        let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
        let tap2: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
        let dest = comments[index]._userId!
        tap.username = dest
        tap.cancelsTouchesInView = true
        tap2.username = dest
        tap2.cancelsTouchesInView = true
        
        cell.profile_picture.isUserInteractionEnabled = true
        cell.profile_picture.addGestureRecognizer(tap)
        
        cell.username.isUserInteractionEnabled = true
        cell.username.addGestureRecognizer(tap2)
        
        
        if ((comments[index]._userPic != nil))
        {

            
            if (comments[index]._userPic != nil){
                
                if let cachedVersion = imageCache.object(forKey: "\(comments[index]._userId!).png" as NSString) {
                    cell.profile_picture.image = cachedVersion
                }
                else{
                    downloadImage(key_: "\(comments[index]._userId!).png", destination: cell.profile_picture)
                }
            }
            else
            {cell.profile_picture.image = UIImage(named: "girl")}
            
            //downloadImage(key_: "\(comments[index]._userId!).png".deletingPrefix("@"), destination: cell.profile_picture)
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = mid.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
            //print("438")
        }else{
            cell.profile_picture.image = UIImage(named:"boy")
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
