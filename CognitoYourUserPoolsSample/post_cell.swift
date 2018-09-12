//
//  post_self.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-11.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit

class post_cell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "image_cell",
                                                       for: indexPath) as! image_cell
        cell.photo.image = images[indexPath.row]
        return cell
        
    }
    
    
    
    @IBOutlet weak var profile_picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var tagg: UIImageView!
    
    @IBOutlet weak var post_images: UICollectionView!
    
    var images:[UIImage] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置collectionView的代理
        self.post_images.delegate = self
        self.post_images.dataSource = self
        
        // 注册CollectionViewCell
        //self.post_images!.register(UINib(nibName:"image_cell", bundle:nil),forCellWithReuseIdentifier: "post_cell")
    }
    
    
    func reloadData(temp:ChanceWithValue,time__:[Int]) {

        
        if ((temp._username) != nil)
        {self.username.text = temp._username
            self.username.textColor = text_light
            self.username.font = self.username.font.withSize(17)
        }
        if ((temp._title) != nil)
        {self.title.text = temp._title
            self.title.font = self.title.font.withSize(15)
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
        
        
        var url: URL
        if (temp._profilePicture != nil){
//            url = URL(string:temp._profilePicture!)!
//            self.profile_picture.image = UIImage(data:try! Data(contentsOf: url))
            downloadImage(key_: "\(temp._username!).png", destination: self.profile_picture)
            
        }
        
        //displaying pictures
        if (temp._pictures != nil)
        {
           images = []
            for i in 0...(temp._pictures?.count)!-1
            {
                var message = temp._pictures![i]
                message = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                var data:NSData = try! NSData(contentsOf: URL(string:message)!)
                let image = UIImage(data: data as Data)!
                images.append(image)
            }
            
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
            
            // self.profile_picture.image = UIImage(data: data!)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = UIColor.white.cgColor
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
        }
        
        
        
        self.post_images.reloadData()
        
    }
    
    
    
}
