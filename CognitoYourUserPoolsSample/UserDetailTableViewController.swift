//
// Copyright 2014-2018 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// Licensed under the Amazon Software License (the "License").
// You may not use this file except in compliance with the
// License. A copy of the License is located at
//
//     http://aws.amazon.com/asl/
//
// or in the "license" file accompanying this file. This file is
// distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, express or implied. See the License
// for the specific language governing permissions and
// limitations under the License.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSDynamoDB
//var temp = "start"
class UserDetailTableViewController : UITableViewController {
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var queryExpression = AWSDynamoDBScanExpression()
    var lock:NSLock?
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = colour
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lock = NSLock()
        self.tableView.delegate = self
        self.pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
        if (self.user == nil) {
            self.user = self.pool?.currentUser()
        }
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
        self.refresh()
        print("did load: \(posts.count)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        print("will disappear: \(posts.count)")
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("will appear: \(posts.count)")
        
        if(posts.count == 0)
        {refresh()}
        //******************test**********************//
        //        dynamoDbObjectMapper.scan(Posts.self, expression: queryExpression).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject? in
        //            if let paginatedOutput = task.result{
        //                        for news in paginatedOutput.items {
        //                            posts.append(news as! Posts)
        //                        }
        //            }
        //            return nil
        //        })
        
        //****************************************
        
        
        //var temp:Posts = dynamoDbObjectMapper.load(Posts.self, hashKey: "Potaty", rangeKey: 5).result as! Posts
        //while(posts.count == 0){self.tableView.reloadData()}
        // load one post
        //***********
        //        dynamoDbObjectMapper.load(Posts.self, hashKey: "Potaty", rangeKey: 5).continueWith(executor: AWSExecutor.mainThread(), block: { (task:AWSTask!) -> AnyObject! in
        //            if let error = task.error as NSError? {
        //                print("Amazon DynamoDB Read Error: \(error)")
        //            }else if let resultBook = task.result as? Posts {
        //        DispatchQueue.main.async(execute: {
        //            self.posts.append(resultBook)
        //        })
        //            }
        //            return nil
        //        })
        //**************
        
        
        //load some posts:
        //********************
        //        let queryExpression = AWSDynamoDBQueryExpression()
        //        queryExpression.keyConditionExpression = "#postId > :postId"
        //        queryExpression.expressionAttributeNames = [
        //            "#postId": "post_id",
        //        ]
        //        queryExpression.expressionAttributeValues = [
        //            ":postId": "0",
        //        ]
        //        dynamoDbObjectMapper.query(Posts.self, expression: queryExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
        //            if error != nil {
        //                print("The request failed. Error: \(String(describing: error))")
        //            }
        //            if output != nil {
        //                DispatchQueue.main.async(execute: {
        //                    for news in output!.items {
        //                        self.posts.append(news as! Posts)
        //                    }
        //                })
        //            }
        //        }
        //**********************
        
        
        
        
        
        
        //**************
        //scan
        //        let scanExpression = AWSDynamoDBScanExpression()
        //        dynamoDbObjectMapper.scan(Posts.self, expression: scanExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
        //            if error != nil {
        //                print("The request failed. Error: \(String(describing: error))")
        //            }
        //            if output != nil {
        //                DispatchQueue.main.async(execute: {
        //                    for news in output!.items {
        //                        posts.append(news as! Posts)
        //                    }
        //                })
        //            }
        //        }
        //***************************
        
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    // MARK: - Table view data source
    //copys?
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    //displayed cell number
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "attribute", for: indexPath)
        //let userAttribute = self.response?.userAttributes![indexPath.row]
        cell.textLabel!.text = "\(indexPath.row)"
        cell.detailTextLabel!.text = String(posts.count)
        
        //cell.textLabel!.text = posts[0]._text
        //cell.detailTextLabel!.text = posts[0]._postId
        
        // ****************************supposed to be storing local data****************************//
        //        var userDefaults = UserDefaults.standard
        //        let decoded  = userDefaults.object(forKey: "posts") as! Data
        //        let decodedTeams = NSKeyedUnarchiver.unarchiveObject(with: decoded) as! [Posts]
        //        print(decodedTeams.count)\
        //********************************************************************************************
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func signOut(_ sender: AnyObject) {
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.tableView.reloadData()
        self.refresh()
    }
    
    func refresh() {
        
        //***********************
        //old version
        print("refreshing")
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        //print("76")
        dynamoDbObjectMapper.scan(Posts.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    for news in paginatedOutput.items {
                        posts.insert(news as! Posts)
                    }
                }
                //   print("84")
            })
        })
        
        
        ////////////////////  weird fuk//////////////////////////
        //        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        //        var queryExpression = AWSDynamoDBScanExpression()
        //
        //        let temp = dynamoDbObjectMapper.scan(Posts.self, expression: queryExpression)
        //        let real = temp.result
        //        for news in (real?.items)! {
        //            posts.append(news as! Posts)
        //        }
        
        
        
        
        
        
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                self.title = self.user?.username
                self.tableView.reloadData()
            })
            return nil
        }
        
        self.refresher.endRefreshing()
        
        
        
    }
    
    
    
}

