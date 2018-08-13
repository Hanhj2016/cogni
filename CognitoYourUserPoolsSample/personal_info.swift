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
        title_name = "我的机会"
        performSegue(withIdentifier: "zhuye", sender: self)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    @IBAction func fabu(_ sender: Any) {
        title_name = "我的发布"
        performSegue(withIdentifier: "zhuye", sender: self)
    }
    
    
    @IBAction func renwu(_ sender: Any) {
        title_name = "我的任务"
        
        performSegue(withIdentifier: "zhuye", sender: self)
        
    }
    
    @IBAction func guanzhu(_ sender: Any) {
        title_name = "我的关注"
        performSegue(withIdentifier: "guanzhu", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "zhuye"
        {
            var upcoming: zhuye = segue.destination as! zhuye
            upcoming.all = false
            upcoming.title = title_name
            if title_name == "我的机会"{
            if p._gottenList != nil
            {upcoming.post_key_list = p._gottenList!}
            else
            {upcoming.post_key_list = []}}
            if title_name == "我的发布"{
                if p._chanceIdList != nil
                {upcoming.post_key_list = p._chanceIdList!}
                else
                {upcoming.post_key_list = []}}
            if title_name == "我的任务"
            {
                
                
               
                
                upcoming.p = self.p
                upcoming.post_key_list = renwu_list
            }
            
        }
        if segue.identifier == "guanzhu"
        {
            var upcoming: guanzhu = segue.destination as! guanzhu
            if title_name == "我的关注"
            {
                
                
                
                if p._guanZhu != nil
                {upcoming.guanzhu_list = p._guanZhu!}
                else
                {upcoming.guanzhu_list = []}
                upcoming.p = self.p
                
            }
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = sign_in_colour
        //////////////////////////////top/////////////////////////////
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
