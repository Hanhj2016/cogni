//
//  personal_info.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-08.
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

class personal_info: UIViewController {

    
    @IBOutlet weak var top_view: UIView!
    @IBOutlet weak var profile_picture: UIImageView!
    
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
    
    @IBOutlet weak var second_view: UIView!
    @IBOutlet weak var jihui_button: UIButton!
    @IBOutlet weak var fabu_button: UIButton!
    @IBOutlet weak var renwu_button: UIButton!
    @IBOutlet weak var qianbao_button: UIButton!
    @IBOutlet weak var guanzhu_button: UIButton!
    @IBOutlet weak var xiaoxi_button: UIButton!
    @IBOutlet weak var jihui_label: UILabel!
    @IBOutlet weak var fabu_second_label: UILabel!
    @IBOutlet weak var renwu_label: UILabel!
    @IBOutlet weak var qianbao_label: UILabel!
    @IBOutlet weak var guanzhu_label: UILabel!
    @IBOutlet weak var xiaoxi_label: UILabel!
    @IBOutlet weak var mid_line: UIView!
var renwu_list:[String] = []
    
    @IBOutlet weak var third_view: UIView!
    @IBOutlet weak var setting: UIButton!
    @IBOutlet weak var last_view: UIView!
    @IBOutlet weak var more: UIImageView!
    
    var title_name = ""
    @IBAction func jihui(_ sender: Any) {
        title_name = "我的机会".toLocal()
        
        //performSegue(withIdentifier: "zhuye", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "zhuye") as! zhuye
        new_chat.p = self.p
        new_chat.title = "我的机会".toLocal()
        self.navigationController?.pushViewController(new_chat, animated: true)
        
        
    }
    
    @IBAction func fabu(_ sender: Any) {
        title_name = "我的发布".toLocal()
        
        //performSegue(withIdentifier: "zhuye", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "wode_fabu") as! wode_fabu
        new_chat.p = self.p
        new_chat.title = "我的发布".toLocal()
     self.navigationController?.pushViewController(new_chat, animated: true)
        
        
    }
    
    
    @IBAction func renwu(_ sender: Any) {
//        title_name = "我的任务"
//
//        performSegue(withIdentifier: "zhuye", sender: self)
        
    }
    
    @IBAction func messages(_ sender: Any) {
        title_name = "我的信息".toLocal()
        performSegue(withIdentifier: "messages", sender: self)
    }
    
    @IBAction func qianbao(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "qianbao") as! qianbao
       
        new_chat.number = Double(p._candyCurrency!)
       new_chat.frozen = Double(p._frozenwallet!)
       new_chat.avail = Double(p._availableWallet!)
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    @objc func guanzhu_label_(sender : MyTapGesture){
        title_name = "我的关注".toLocal()
        performSegue(withIdentifier: "guanzhu", sender: self)
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
    @objc func fabu_label_(sender : MyTapGesture){
        title_name = "我的发布".toLocal()
        
        //performSegue(withIdentifier: "zhuye", sender: self)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var new_chat = storyboard.instantiateViewController(withIdentifier: "wode_fabu") as! wode_fabu
        new_chat.p = self.p
        new_chat.title = "我的发布".toLocal()
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    @IBAction func guanzhu(_ sender: Any) {
        title_name = "我的关注".toLocal()
        performSegue(withIdentifier: "guanzhu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zhuye"
        {
            var upcoming: zhuye = segue.destination as! zhuye
            //upcoming.all = false
            upcoming.title = title_name
            if title_name == "我的机会".toLocal(){
            if p._gottenList != nil
            {upcoming.post_key_list = p._gottenList!}
            else
            {upcoming.post_key_list = []}}
            if title_name == "我的发布".toLocal(){
                if p._chanceIdList != nil
                {upcoming.post_key_list = p._chanceIdList!}
                else
                {upcoming.post_key_list = []}}
            if title_name == "我的任务".toLocal()
            {
                
                upcoming.p = self.p
                upcoming.post_key_list = renwu_list
            }
            
        }
        if segue.identifier == "guanzhu"
        {
            var upcoming: guanzhu = segue.destination as! guanzhu
            if title_name == "我的关注".toLocal()
            {
                
                
                
                if p._guanZhu != nil
                {upcoming.guanzhu_list = p._guanZhu!}
                else
                {upcoming.guanzhu_list = []}
                upcoming.p = self.p
                
            }
        }
        if segue.identifier == "messages"
        {
            var upcoming: messagesViewController = segue.destination as! messagesViewController
            if title_name == "我的信息".toLocal()
            {
                upcoming.user = (AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username)!
                
                
                
                
            }
        }
        
        
    }
    
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = 0
        //进入图片全屏展示
        if self.profile_picture.image != nil{
        let previewVC = ImagePreviewVC(images: [self.profile_picture.image!], index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
            self.navigationController?.pushViewController(previewVC, animated: true)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = sign_in_colour
        //////////////////////////////top/////////////////////////////
        //print("182")
        while (p._userId == nil)
        {
            
        }
       // UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : colour]
        self.top_view.backgroundColor = mid
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
        
        
        if (p._userId != nil){
            
//            if let cachedVersion = imageCache.object(forKey: "\(p._userId!).png" as NSString) {
//                self.profile_picture.image = cachedVersion
//            }
//            else{
//                downloadImage(key_: "\(p._userId!).png", destination: self.profile_picture)
//            }
            let message = "\(p._userId!).png"
            if let value = cache.secondaryCache?.load(key: message) {
                // print("inhaha")
                let cachedVersion = UIImage(data:value as! Data)
                self.profile_picture.image = cachedVersion
                
            }else
            {
                downloadImage(key_: message as String, destination: self.profile_picture)
            }
            
            
        }
        else
        {self.profile_picture.image = UIImage(named: "girl")}
        
        
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
        /////////////////////////////////////2nd/////////////////////////
        self.second_view.backgroundColor = mid
        self.jihui_label.textColor = text_light
        self.fabu_second_label.textColor = text_light
        self.renwu_label.textColor = text_light
        self.qianbao_label.textColor = text_light
        self.guanzhu_label.textColor = text_light
        self.xiaoxi_label.textColor = text_light
        
        self.jihui_label.font = self.jihui_label.font.withSize(12)
        self.fabu_second_label.font = self.fabu_second_label.font.withSize(12)
        self.renwu_label.font = self.renwu_label.font.withSize(12)
        self.qianbao_label.font = self.qianbao_label.font.withSize(12)
        self.guanzhu_label.font = self.guanzhu_label.font.withSize(12)
        self.xiaoxi_label.font = self.xiaoxi_label.font.withSize(12)
        self.mid_line.backgroundColor = text_light
    ///////////////////////3rd///////////////////
        
        self.third_view.backgroundColor = mid
        self.setting.backgroundColor = mid
        
        self.last_view.backgroundColor = mid
        self.more.image = UIImage(named:"more")
        
        let tap:MyTapGesture = MyTapGesture(target: self, action: #selector(guanzhu_label_))
         let tap2:MyTapGesture = MyTapGesture(target: self, action: #selector(beiguanzhu_label_))
         let tap3:MyTapGesture = MyTapGesture(target: self, action: #selector(fabu_label_))
        let tap4:MyTapGesture = MyTapGesture(target: self, action: #selector(guanzhu_label_))
        let tap5:MyTapGesture = MyTapGesture(target: self, action: #selector(beiguanzhu_label_))
        let tap6:MyTapGesture = MyTapGesture(target: self, action: #selector(fabu_label_))
        //tap3.cancelsTouchesInView = true
        self.follow_label.isUserInteractionEnabled = true
        self.follow_label.addGestureRecognizer(tap)
        self.follow_value.isUserInteractionEnabled = true
        self.follow_value.addGestureRecognizer(tap4)
        self.followed_label.isUserInteractionEnabled = true
        self.followed_label.addGestureRecognizer(tap2)
        self.followed_value.isUserInteractionEnabled = true
        self.followed_value.addGestureRecognizer(tap5)
        self.fabu_label.isUserInteractionEnabled = true
        self.fabu_label.addGestureRecognizer(tap3)
        self.fabu_value.isUserInteractionEnabled = true
        self.fabu_value.addGestureRecognizer(tap6)
        
        // Do any additional setup after loading the view.
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
