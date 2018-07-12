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
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell", for: indexPath) as! post_cell
        let temp:Posts = posts[indexPath.row]
        
        
        if ((temp._username) != nil)
        {cell.username.text = temp._username}
        if ((temp._title) != nil)
        {cell.title.text = temp._title}
        if ((temp._text) != nil)
        {cell.content.text = temp._text
            var greet4Height = cell.content.optimalHeight
            cell.content.frame = CGRect(x: cell.content.frame.origin.x, y: cell.content.frame.origin.y, width: cell.content.frame.width, height: greet4Height)
            cell.content.backgroundColor = UIColor.yellow
        }
        if ((temp._shared) != nil)
        {cell.shared.text = String(temp._shared as! Int)}
        if ((temp._comments) != nil)
        {cell.comments.text = String(temp._comments as! Int)}
        
        if ((temp._liked) != nil)
        {cell.liked.text = String(temp._liked as! Int)}
        
        if ((temp._time) != nil)
        {//using the easy way
            var output = ""
            var _time = temp._time as! Int
            var second = _time % 100
            var Rem = _time / 100
            var Minute = Rem % 100
            Rem = Rem / 100
            var hour = Rem % 100
            Rem = Rem / 100
            var day = Rem % 100
            Rem = Rem / 100
            var month = Rem % 100
            Rem = Rem / 100
            var year = (Rem % 100)%100
            time[0] = time[0]%100
         //   print("year:\(year)..month:\(month)..day:\(day)")
            
            if year == time[0]
            {
                if day == time[2]
                {
                    if hour == time[3]
                    {
                        if Minute == time[4]
                        {output = "\(time[5]-second) 秒前"}
                        else if time[4] - Minute == 1
                        {output = "\(time[5]+60-second) 秒前"}
                        else
                        {output = "\(time[4]-Minute) 分钟前"}
                    }
                    else if time[3] - hour == 1
                    {
                        output = "\(time[4]+60-Minute) 分钟前"
                    }
                    else
                    {
                        output = "\(hour):\(Minute)"
                    }
                }
                else if time[2] == (day + 1)
                {
                    output = "昨天\(hour):\(Minute)"
                }
                else if time[2] == day + 2
                {
                    output = "前天\(hour):\(Minute)"
                }
                else
                {
                    output = "\(month):\(day)"
                }
            }
            else
            {output = "\(year)/\(month)/\(day)"}
            
            
            cell.time.text = output
            
            
            
        }
        
        if ((temp._tag) != nil)
        {
            let t = temp._tag
            if t == 0
            {cell.tagg.image = UIImage(named: "huodong")}
            else if t == 1
            {cell.tagg.image = UIImage(named: "renwu")}
            else if t == 2
            {cell.tagg.image = UIImage(named: "yuema")}
            else if t == 3
            {cell.tagg.image = UIImage(named: "qita")}
        }
        if ((temp._profilePicture != nil))
        {
            let url = URL(string: temp._profilePicture!)
            let data = try? Data(contentsOf: url!)
             cell.profile_picture.image = UIImage(data: data!)
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = UIColor.white.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
        }
        


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
        
        //********************************//
        //************** TIME ******************//
        let date = Date()
        let calendar = Calendar.current
        time[0] = calendar.component(.year, from: date) // 0
        time[1] = calendar.component(.month, from: date) // 1
       time[2] = calendar.component(.day, from: date) //2
       time[3] = calendar.component(.hour, from: date) // 3
       time[4] = calendar.component(.minute, from: date) // 4
        time[5] = calendar.component(.second, from: date) // 5
    //    print("year:\(time[0])..month:\(time[1])..day:\(time[2])")
        //************** TIME ******************//
        
        
        
        //***********************
        //old version
        //print("refreshing")
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        //print("76")
        dynamoDbObjectMapper.scan(Posts.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    if (paginatedOutput.items.count < posts.count)
                    {posts = []}
                    for news in paginatedOutput.items {
                        if !posts.contains(news as! Posts)
                        {posts.append(news as! Posts)}
                    }
                }
                //   print("84")
            })
        })

        
        
        
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

