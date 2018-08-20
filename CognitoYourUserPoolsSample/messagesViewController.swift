//
//  messagesViewController.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-19.
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


class messagesViewController:  UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    var user = ""
   
    
    let table_titles:[String] = ["机会秘书","机会广播","我的私信"]
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "message_cell", for: indexPath) as! message_cell
        //cell.textLabel?.textColor = text_light
        //cell.textLabel?.text = table_titles[indexPath.row]
        let temp = load_UserChat(key: user)
        let row = indexPath.row
        if row == 0{
            cell.icon.image = UIImage(named:"kefu")
            cell.name.text = "机会秘书"
            cell.name.textColor = text_light
            cell.message.isHidden = true
            
        }
        if row == 1{
            cell.icon.image = UIImage(named:"guangbo")
            cell.name.text = "机会广播"
            cell.name.textColor = text_light
            cell.message.isHidden = true
            
        }
        if row == 2{
            cell.icon.image = UIImage(named:"sixin")
            cell.name.text = "我的私信"
            cell.name.textColor = text_light
            cell.message.isHidden = false
            cell.message.backgroundColor = UIColor.red
            cell.message.layer.cornerRadius = cell.message.frame.height/2
            cell.message.layer.borderWidth = 1.0
            cell.message.layer.masksToBounds = false
            cell.message.layer.borderColor = UIColor.red.cgColor
            cell.message.clipsToBounds = true
            cell.message.textColor = text_light
            let number = temp._totalUnread
            if number == nil || number == 0
            {cell.message.isHidden = true}
            else
            {cell.message.text = String(number as! Int)}
            
        }
        cell.backgroundColor = mid
        cell.accessoryType = .disclosureIndicator
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = text_mid.cgColor
        return cell
        //cell.title = table_titles[indexPath.row]
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func load_UserChat(key:String) -> UserChat{
        var temp:UserChat = UserChat()
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var aiya = dynamoDbObjectMapper.load(UserChat.self, hashKey: key, rangeKey:nil)
        aiya.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? UserChat {
                temp = resultBook
            }
            return nil
        })
        aiya.waitUntilFinished()
        if aiya.isCancelled
        {print("cancelled")}
        if aiya.isCompleted
        {print("completed")}
        if aiya.isFaulted
        {print("faulted")}
        //print(aiya.result)
        return temp
    }
    
    
    
    //displayed cell number
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if small == 0
        if indexPath.row == 2
        {
            
           performSegue(withIdentifier: "chats", sender: self)
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chats"
        {
            var upcoming: chat_message = segue.destination as! chat_message
            upcoming.user = user
            
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.tableView.isScrollEnabled = false
        self.view.backgroundColor = mid
        self.tableView.backgroundColor = mid
        self.tableView!.rowHeight = 50
        self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
