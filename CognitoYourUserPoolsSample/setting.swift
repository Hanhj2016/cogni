//
//  setting.swift
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
//var temp = "start"

class setting: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sign_out: UIButton!
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    @IBAction func sign_out(_ sender: Any) {
       self.user?.signOut()
        self.response = nil
        self.refresh()
         _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    let table_titles:[String] = ["个人信息".toLocal(),"偏好设置".toLocal(),"清除缓存".toLocal(),"夜间模式".toLocal(),"账号安全".toLocal(),"隐私".toLocal(),"语言".toLocal(),"关于我们".toLocal(),"小助手".toLocal()]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "setting_cell", for: indexPath)
        let row = indexPath.row
        
        cell.textLabel?.textColor = text_light
        cell.textLabel?.text = table_titles[indexPath.row]
        cell.backgroundColor = mid
        cell.accessoryType = .disclosureIndicator
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = text_mid.cgColor
        if row != 0
        {
           // cell.backgroundColor = UIColor.gray
            cell.textLabel?.textColor = UIColor.gray
        }
        return cell
        //cell.title = table_titles[indexPath.row]
    }
     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if small == 0
        if indexPath.row == 0
        {
            performSegue(withIdentifier: "个人信息", sender: self)
        }
        
    }
    
    
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "个人信息"
    {
    var upcoming: change_info = segue.destination as! change_info
    
    let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
    
    let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    dynamoDbObjectMapper.load(UserPool.self, hashKey: username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
    if let error = task.error as? NSError {
    print("The request failed. Error: \(error)")
    } else if let resultBook = task.result as? UserPool {
    upcoming.p = resultBook
    
    }
    return nil
    })
    }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.tableView.isScrollEnabled = false
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        
        self.sign_out.setTitleColor(text_light, for: .normal)
        self.view.backgroundColor = mid
        self.tableView.backgroundColor = mid
        self.tableView!.rowHeight = 60
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.sign_out.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func refresh(){
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                //self.title = self.user?.username
                self.tableView.reloadData()
            })
            return nil
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
