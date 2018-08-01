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
    
    
    var p: ChanceWithValue = ChanceWithValue()
    let screenHeight = UIScreen.main.bounds.height
    let scrollViewContentHeight = 1200 as CGFloat
    var images:[UIImage] = []
    var comments:[CommentTable] = []
    
    
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = colour
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    
    
    
    
    @objc func refresh() {
        
        if self.p._commentIdList != nil
        {
            for comment_id in self.p._commentIdList!{
                let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
                dynamoDbObjectMapper.load(CommentTable.self, hashKey: comment_id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                    if let error = task.error as? NSError {
                        print("The request failed. Error: \(error)")
                    } else if let resultBook = task.result as? CommentTable {
                        print("in")
                        if self.comments.count < self.p._commentNumber as! Int
                        {self.comments.append(resultBook)}
                    }
                    return nil
                })
            }
        }
        print("158: \(self.comments.count)")
        
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
        //self.tableView.backgroundColor = light
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView!.delegate = self
        //self.tableView!.dataSource = self as! UITableViewDataSource
        
        

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
        tableView.bounces = false
        tableView.isScrollEnabled = false
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
        
        
        self.comment_number.backgroundColor = mid
        self.comment_number.tintColor = text_mid
        if self.p._commentNumber != nil
        {self.comment_number.setTitle("评论 \(self.p._commentNumber!)", for: .normal)}
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
        if p._commentNumber != nil
        {
        while (self.comments.count < p._commentNumber as! Int)
        {
            //self.refresh()
        }
        }
        self.bot_like.backgroundColor = sign_in_colour
        self.bot_comment.backgroundColor = sign_in_colour
        self.bot_share.backgroundColor = sign_in_colour
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
            let data = try? Data(contentsOf: url!)
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
        // Dispose of any resources that can be recreated.
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        
        if scrollView == self.scrollView {
            if yOffset >= scrollViewContentHeight - screenHeight {
                scrollView.isScrollEnabled = false
                tableView.isScrollEnabled = true
            }
        }
        
        if scrollView == self.tableView {
            if yOffset <= 0 {
                self.scrollView.isScrollEnabled = true
                self.tableView.isScrollEnabled = false
            }
        }
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
