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
class other_zhuye: UIViewController {

    
    
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
    var p:UserPool = UserPool()
    
    @IBOutlet weak var bot_bar: UIStackView!
    
    @IBOutlet weak var guanzhu: UIButton!
    
    let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
    
    @IBAction func guanzhu(_ sender: Any) {
        if did_follow == 0
        {
            self.guanzhu.setTitle("已关注", for: .normal)
            did_follow = 1
            //self guanzhu ++
            //target: p beiguanzhu ++
            
        }
        else
        {
            self.guanzhu.setTitle("关注", for: .normal)
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        while(p._userId == nil)
        {
        }
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : colour]
        self.top_view.backgroundColor = mid
        if ((p._profilePic != nil))
        {
            let url = URL(string: p._profilePic!)
            let data = try? Data(contentsOf: url!)
            self.profile_picture.layer.borderWidth = 1.0
            self.profile_picture.layer.masksToBounds = false
            self.profile_picture.layer.borderColor = UIColor.white.cgColor
            //print("width: \(self.profile_picture.frame.size.width)")
            self.profile_picture.layer.cornerRadius = self.profile_picture.frame.size.width / 2
            self.profile_picture.clipsToBounds = true
            self.profile_picture.image = UIImage(data: data!)
        }
        
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
            self.resume.text = "简介：" + p._resume!}
        else
        {self.resume.isHidden = true}
        self.reputation.setTitle("声望: \(p._shengWang)", for: .normal)
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
        self.followed_label.text = "被关注"
        self.follow_label.text = "关注"
        self.fabu_label.text = "发布"
        // Do any additional setup after loading the view.
        
        
        
        ///////////////////bot/////////////
        self.bot_bar.backgroundColor = text_light
        self.bot_bar.layer.borderColor = light.cgColor
        self.bot_bar.layer.borderWidth = 1
        self.bot_bar.backgroundColor = light
        self.guanzhu.setTitleColor(colour, for: .normal)
        self.his_guanzhu.setTitleColor(colour, for: .normal)
        self.his_guanzhu.setTitle("他的关注", for: .normal)
        self.send_message.setTitleColor(colour, for: .normal)
        self.send_message.setTitle("发送私信", for: .normal)
        self.send_message.backgroundColor = mid
        self.his_guanzhu.backgroundColor = mid
        self.guanzhu.backgroundColor = mid
        
        
        
        if (p._beiGuanZhu != nil){
            if (p._beiGuanZhu?.contains(user!))!
            {
                self.guanzhu.setTitleColor(colour, for: .normal)
                self.guanzhu.setTitle("取消关注", for: .normal)
                self.did_follow = 1
            }
            else
            {
                self.guanzhu.setTitleColor(colour, for: .normal)
                self.guanzhu.setTitle("关注", for: .normal)
                self.did_follow = 0
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
