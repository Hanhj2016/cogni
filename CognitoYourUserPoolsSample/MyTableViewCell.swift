//
//  post_self.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-11.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit
import Kingfisher
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // print("count:\(images.count)")
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell",
                                                       for: indexPath) as! MyCollectionViewCell
        
        cell.photo.image = images[indexPath.row]
        return cell
        
    }
    
    func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: images, index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
       // self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
   
    @IBOutlet weak var profile_picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var tagg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var image_collection: UICollectionView!
   // var urls:[URL] = []
    var images:[UIImage] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置collectionView的代理
        self.image_collection.delegate = self
        self.image_collection.dataSource = self
        
        // 注册CollectionViewCell
        self.image_collection!.register(UINib(nibName:"MyCollectionViewCell", bundle:nil),forCellWithReuseIdentifier: "myCell")
    }
    
    
    func reloadData(temp:ChanceWithValue,time__:[Int]) {
        
        
        if ((temp._username) != nil)
        {self.username.text = temp._username
            self.username.textColor = text_light
            self.username.font = self.username.font.withSize(17)
        }
        if ((temp._title) != nil)
        {self.title.text = temp._title
            self.title.font = self.title.font.withSize(17)
            self.title.textColor = text_light
            
        }
        if ((temp._text) != nil)
        {self.content.text = temp._text
            self.content.font = self.content.font.withSize(14)
            self.content.textColor = text_light
            let greet4Height = self.content.optimalHeight
            self.content.frame = CGRect(x: self.content.frame.origin.x, y: self.content.frame.origin.y, width: self.content.frame.width, height: greet4Height)
            self.content.backgroundColor = mid
        }
        
        
        if (temp._profilePicture != nil){
            let url = URL(string:temp._profilePicture!)!
            self.profile_picture.image = UIImage(data:try! Data(contentsOf: url))}
        //displaying pictures
        //self.urls = []
        self.images = []
        if (temp._pictures != nil)
        {
            
             //DispatchQueue.main.async(execute: {
            for i in 0...(temp._pictures?.count)!-1
            {
                
                let url = URL(string:temp._pictures![i])!
              //  self.urls.append(url)
                var data:NSData = try! NSData(contentsOf: url)
                self.images.append(UIImage(data: data as Data)!)
               // images.append(URL(string:temp._pictures![i])!)
            }
            //})
        }
        
        
        
        if ((temp._time) != nil)
        {//using the easy way
            
            
            
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
            
            self.time_label.font = self.time_label.font.withSize(13)
            self.time_label.text = output
            self.time_label.textColor = text_mid
            
            
            
            
        }
        
        if ((temp._tag) != nil)
        {
            let t = temp._tag
            if t == 1
            {self.tagg.image = UIImage(named: "huodong")}
            else if t == 2
            {self.tagg.image = UIImage(named: "renwu")}
            else if t == 0
            {self.tagg.image = UIImage(named: "yuema")}
            else if t == 3
            {self.tagg.image = UIImage(named: "qita")}
        }
        if ((temp._profilePicture != nil))
        {
            let url = URL(string: temp._profilePicture!)
            let data = try? Data(contentsOf: url!)
            // self.profile_picture.image = UIImage(data: data!)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = UIColor.white.cgColor
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
        }
        
        
        self.image_collection.backgroundColor = mid
        self.image_collection.reloadData()
        let contentSize = self.image_collection.collectionViewLayout.collectionViewContentSize
         self.image_collection.collectionViewLayout.invalidateLayout()
        collectionViewHeight.constant = contentSize.height
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}
