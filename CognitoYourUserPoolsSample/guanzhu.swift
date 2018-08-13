//
//  guanzhu.swift
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

class guanzhu: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBAction func guanzhu(_ sender: UIButton) {
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        let temp:UserPool = p
        let user = guanzhu_list[sender.tag]
        if temp._guanZhu != nil{
            if (temp._guanZhu?.contains(user))!
            {
                var temp_list:[String] = []
                for a in temp._guanZhu!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._guanZhu = temp_list}
                else
                {temp._guanZhu = nil}
            }
            else
            {
                temp._guanZhu?.append(user)
            }}
        else
        {
            temp._guanZhu = [user] as? [String]
        }
        p = temp

//        DispatchQueue.main.async(execute: {
//            let indexPath = IndexPath(item: sender.tag, section: 0)
//            self.tableView.reloadRows(at: [indexPath], with: .fade)
//        })
        
        dynamoDbObjectMapper.save(temp, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
        
    }
    
    @IBOutlet weak var tableView: UITableView!
    var p:UserPool = UserPool()
    var guanzhu_list:[String] = []
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
   
        if p._guanZhu != nil
        {
            return (guanzhu_list.count)}
        else
        { //print(p)
            return 0}
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "wodeguanzhu", for: indexPath) as! guanzhu_cell
        cell.backgroundColor = mid
        let name = guanzhu_list[indexPath.row]
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        //print("name")
        
        cell.guanzhu.tag = indexPath.row
            dynamoDbObjectMapper.load(UserPool.self, hashKey: name, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? UserPool {
                    DispatchQueue.main.async(execute: {
                    if ((resultBook._profilePic != nil))
                    {
                        let url = URL(string: resultBook._profilePic!)
                        let data = try? Data(contentsOf: url!)
                        cell.profile_picture.layer.borderWidth = 1.0
                        cell.profile_picture.layer.masksToBounds = false
                        cell.profile_picture.layer.borderColor = UIColor.white.cgColor
                        //print("width: \(self.profile_picture.frame.size.width)")
                        cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
                        cell.profile_picture.clipsToBounds = true
                        cell.profile_picture.image = UIImage(data: data!)
                    }
                    
                    cell.name.text = resultBook._userId
                    cell.name.textColor = text_light
                        if (self.p._guanZhu?.contains(resultBook._userId!))!
                        {
                            cell.guanzhu.setImage(UIImage(named:"yiguanzhu"), for: .normal)
                            cell.guanzhu.setTitle("已关注", for: .normal)
                            cell.guanzhu.setTitleColor(colour, for: .normal)
                        }
                        else
                        {
                            cell.guanzhu.setTitleColor(light, for: .normal)
                            cell.guanzhu.setTitle("关注", for: .normal)
                        }
                    
                    })
                    
                    
                }
                return nil
            })
        
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = mid
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
