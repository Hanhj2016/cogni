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
class UserDetailTableViewController : UITableViewController, UICollectionViewDelegate,UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pics.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "post_images", for: indexPath) as! post_images
        DispatchQueue.main.async(execute: {
            cell.photo.image = self.pics[indexPath.row]})
        return cell
    }
    
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var queryExpression = AWSDynamoDBScanExpression()
    var lock:NSLock?
    var pics:[UIImage] = []
    
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = colour
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = light
        
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let logo = UIImage(named: "name")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
        self.navigationController?.navigationBar.tintColor = colour
        self.navigationController?.navigationBar.barTintColor = sign_in_colour
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:colour]

        self.navigationController?.toolbar.barTintColor = sign_in_colour
        if(posts.count == 0)
        {refresh()}
        //self.navigationController?.hidesBottomBarWhenPushed = false
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
    
    func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: pics, index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "post_cell", for: indexPath) as! post_cell
        let temp:ChanceWithValue = posts[indexPath.row]
        
        cell.setBottomBorder()
        
        cell.backgroundColor = mid
        if ((temp._username) != nil)
        {cell.username.text = temp._username
            cell.username.textColor = text_light
            cell.username.font = cell.username.font.withSize(17)
        }
        if ((temp._title) != nil)
        {cell.title.text = temp._title
            cell.title.font = cell.title.font.withSize(15)
            cell.title.textColor = text_light
            
        }
        if ((temp._text) != nil)
        {cell.content.text = temp._text
             cell.content.font = cell.content.font.withSize(14)
            cell.content.textColor = text_light
            let greet4Height = cell.content.optimalHeight
            cell.content.frame = CGRect(x: cell.content.frame.origin.x, y: cell.content.frame.origin.y, width: cell.content.frame.width, height: greet4Height)
            cell.content.backgroundColor = mid
        }
        
        
        var url: URL
        if (temp._profilePicture != nil){
        url = URL(string:temp._profilePicture!)!
            cell.profile_picture.image = UIImage(data:try! Data(contentsOf: url))}
        //displaying pictures
        if (temp._pictures != nil)
        {
            pics = []
            for i in 0...(temp._pictures?.count)!-1
            {
                url = URL(string:temp._pictures![i])!
                var data:NSData = try! NSData(contentsOf: url)
                if data != nil
                {pics.append(UIImage(data: data as Data)!)}
                else
                {print(url)}
             
                //cell.post_images = pics[0]
                
                
                
                
                
//                let imageView = UIImageView()
//                print("\(indexPath.row):\(cell.content.frame.origin.y)")
//                imageView.frame = CGRect(x: cell.content.frame.origin.x, y: cell.content.frame.origin.y, width:60, height:60)
                //imageView.tag = i
                //imageView.contentMode = .scaleAspectFill
               // imageView.clipsToBounds = true
                //imageView.image = pics[i]
                //设置允许交互（后面要添加点击）
//                imageView.isUserInteractionEnabled = true
//self.view.addSubview(imageView)
//                //添加单击监听
//                let tapSingle=UITapGestureRecognizer(target:self,
//                                                     action:#selector(imageViewTap(_:)))
//                tapSingle.numberOfTapsRequired = 1
//                tapSingle.numberOfTouchesRequired = 1
//                imageView.addGestureRecognizer(tapSingle)
                
            }
            DispatchQueue.main.async(execute: {
               cell.post_images.frame = CGRect(x: cell.post_images.frame.origin.x, y: cell.post_images.frame.origin.y, width: CGFloat(60 * self.pics.count), height: 60)
            })
           // pics = []
            
            
            
        }
        
        
        
        
        
        
        
        
        //if ((temp._shared) != nil)
        //{cell.shared.text = String(temp._shared as! Int)}
        //if ((temp._comments) != nil)
        //{cell.comments.text = String(temp._comments?.count as! Int)}
        
        //if ((temp._liked) != nil)
        //{cell.liked.text = String(temp._liked as! Int)}
        
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
                        {
                            if (time[5]+60-second <= 60)
                            {output = "\(time[5]+60-second) 秒前"}
                            else
                            {output = "1分钟前"}
                            
                        }
                        else
                        {output = "\(time[4]-Minute) 分钟前"}
                    }
                    else if time[3] - hour == 1
                    {
                        if time[4]+60-Minute <= 60
                        {output = "\(time[4]+60-Minute) 分钟前"}
                        else
                        {output = "\(hour):\(Minute)"}
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
                    output = "\(month)月\(day)日"
                }
            }
            else
            {output = "\(year)/\(month)/\(day)"}
            
            cell.time.font = cell.time.font.withSize(13)
            cell.time.text = output
            cell.time.textColor = text_mid
            
            
            
            
        }
        
        if ((temp._tag) != nil)
        {
            let t = temp._tag
            if t == 1
            {cell.tagg.image = UIImage(named: "huodong")}
            else if t == 2
            {cell.tagg.image = UIImage(named: "renwu")}
            else if t == 0
            {cell.tagg.image = UIImage(named: "yuema")}
            else if t == 3
            {cell.tagg.image = UIImage(named: "qita")}
        }
        if ((temp._profilePicture != nil))
        {
            let url = URL(string: temp._profilePicture!)
            let data = try? Data(contentsOf: url!)
            // cell.profile_picture.image = UIImage(data: data!)
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
        //************** TIME ******************//
        
        
        
        //***********************
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    if (paginatedOutput.items.count < posts.count)
                    {posts = []}
                    for news in paginatedOutput.items {
                        if !posts.contains(news as! ChanceWithValue)
                        {posts.append(news as! ChanceWithValue)}
                    }
                }
            })
        })

        
        
        
        self.user?.getDetails().continueOnSuccessWith { (task) -> AnyObject? in
            DispatchQueue.main.async(execute: {
                self.response = task.result
                //self.title = self.user?.username
                self.tableView.reloadData()
            })
            return nil
        }
        
        self.refresher.endRefreshing()
        
        
        
    }
    
    
    
}



