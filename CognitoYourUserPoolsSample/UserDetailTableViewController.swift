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


class UserDetailTableViewController : UITableViewController {
    
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    var user: AWSCognitoIdentityUser?
    var pool: AWSCognitoIdentityUserPool?
    var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
    var queryExpression = AWSDynamoDBScanExpression()
    var lock:NSLock?
    var pics:[UIImage] = []
    var comment_click = false
    var share_click = false
    var posts:[ChanceWithValue] = []
    var post_key_list:[String] = []
    var all = true
    var myTimer:Timer = Timer()
    @IBOutlet weak var xiaoxi: UIButton!
    @IBAction func xiaoxi(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var new_chat = storyboard.instantiateViewController(withIdentifier: "xinxi") as! chat_message
        new_chat.user = (AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username)!
        self.navigationController?.pushViewController(new_chat, animated: true)
    }
    
    
    //var small = 0
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var image_collection: UICollectionView!
    
    
    init(list:[String]){
        self.post_key_list = list
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
   
    lazy var refresher:UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.clear
        let refreshImage = UIImageView()
        refreshImage.image = UIImage(named: "jake")
        refreshControl.backgroundColor = UIColor.clear
        refreshControl.addSubview(refreshImage)
        refreshImage.frame = refreshControl.bounds.offsetBy(dx: self.view.frame.size.width / 2 - 20, dy: 20)
            refreshImage.frame.size.width = 40 // Whatever width you want
            refreshImage.frame.size.height = 40
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return refreshControl
    }()
    

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
    
    
    @IBOutlet weak var notification: UIImageView!
    
    @objc func reload_notification(){
        let username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        
        let temp_chat = load_UserChat(key: username!)
        if temp_chat._totalUnread != nil || temp_chat._totalUnread != 0
        {
            notification.isHidden = true
        }
        else
        {
            notification.isHidden = false
            notification.backgroundColor = UIColor.red
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = sign_in_colour
        
        
        lock = NSLock()
       self.tableView!.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
        //self.tableView!.separatorInset = UIEdgeInsetsMake(0, 3, 0, 20);

        self.tableView!.estimatedRowHeight = 150
        //rowHeight属性设置为UITableViewAutomaticDimension
        self.tableView!.rowHeight = UITableViewAutomaticDimension
        
        
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
        
        myTimer = Timer(timeInterval: 1.0, target: self, selector: "reload_notification", userInfo: nil, repeats: true)
        RunLoop.main.add(myTimer, forMode: RunLoopMode.defaultRunLoopMode)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.navigationBar.isHidden = false
        myTimer.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        self.navigationController?.toolbar.barTintColor = sign_in_colour
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
    
    @IBAction func like(_ sender: UIButton) {
        let temp:ChanceWithValue = posts[sender.tag]
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        if temp._liked != nil{
            if (temp._liked?.contains(user!))!
            {
                var temp_list:[String] = []
                for a in temp._liked!
                {
                    if a != user
                    {
                        temp_list.append(a)
                    }
                }
                if temp_list.count != 0
                {temp._liked = temp_list}
                else
                {temp._liked = nil}
            }
            else
            {
                temp._liked?.append(user!)
            }}
        else
        {
            temp._liked = [user] as? [String]
        }
        posts[sender.tag] = temp
        DispatchQueue.main.async(execute: {
            let indexPath = IndexPath(item: sender.tag, section: 0)
            self.tableView.reloadRows(at: [indexPath], with: .fade)
        })
        dynamoDbObjectMapper.save(temp, completionHandler: {
            (error: Error?) -> Void in
            
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("An item was saved.")
        })
        
    }
    
    @IBAction func comments(_ sender: Any) {
       // small = 1
        self.comment_click = true
         self.performSegue(withIdentifier: "comment", sender: sender)
        
        
    }
    @IBAction func share(_ sender: Any) {
       
         self.performSegue(withIdentifier: "pyq_share", sender: sender)
        
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if small == 0
        self.performSegue(withIdentifier: "show_post_detail", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "show_post_detail"
        {
            
            var upcoming: post_detail = segue.destination as! post_detail
            let indexPath = self.tableView.indexPathForSelectedRow!
            upcoming.p = posts[indexPath.row]
            

        }
        else if segue.identifier == "share_detail"
        {
            var upcoming: post_detail = segue.destination as! post_detail
          let s = sender as! UIButton
            let temp = posts[s.tag]
            let id = temp._sharedFrom![0]
            let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: id, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? ChanceWithValue {
                    upcoming.p = resultBook
                    
                }
                return nil
            })
        }
        else if segue.identifier == "wode"
        {
            var upcoming: personal_info = segue.destination as! personal_info
          
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
        else if segue.identifier == "comment" || segue.identifier == "share"
        {
            var upcoming: post_detail = segue.destination as! post_detail
            let s = sender as! UIButton
            upcoming.p = posts[s.tag]
            upcoming.share_click = self.share_click
            upcoming.comment_click = self.comment_click
            
        }
        else if segue.identifier == "pyq_share"
        {
            var upcoming: share = segue.destination as! share
            let s = sender as! UIButton
            let temp = posts[s.tag]
            if temp._sharedFrom == nil{
            upcoming.profile_picture_link = temp._profilePicture!
            upcoming.username_ = "@" + temp._username!
            upcoming.title_ = temp._title!
            upcoming.id = temp._id!
                upcoming.tag = Int(temp._tag!)}
            else
            {
                upcoming.profile_picture_link = temp._sharedFrom![3]
                upcoming.username_ =  temp._sharedFrom![1]
                upcoming.title_ = temp._sharedFrom![2]
                upcoming.id = temp._sharedFrom![0]
                upcoming.tag = Int(temp._tag!)
                upcoming.share_from = temp._id!
            }
            
        }
        
        
        
        
    }
    

    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell", for: indexPath) as! MyTableViewCell
        let temp:ChanceWithValue = posts[indexPath.row]
        let temp_time:[Int] = time
        
        
        let tap: MyTapGesture = MyTapGesture(target: self, action: #selector(show_zhuye))
        tap.username = temp._username!
        tap.cancelsTouchesInView = true
        cell.profile_picture.isUserInteractionEnabled = true
       cell.profile_picture.addGestureRecognizer(tap)
        
        cell.username.isUserInteractionEnabled = true
        cell.username.addGestureRecognizer(tap)
        
        //self.view.addSubview(cell.profile_picture)
        
        cell.frame = tableView.bounds
        cell.layoutIfNeeded()
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
        cell.like.tag = indexPath.row
        cell.comments.tag = indexPath.row
        cell.share.tag = indexPath.row
        cell.share_detail.tag = indexPath.row
        cell.image_collection.backgroundColor = light
        let origImage = UIImage(named: "dianzan")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        cell.like.setImage(tintedImage, for: .normal)
        if temp._liked != nil{
        let like_number = (temp._liked?.count)!
        let clicked = (temp._liked?.contains(user!))
        if (clicked)!
        {cell.like.setTitleColor(colour, for: .normal)
            cell.like.tintColor = colour
        }
        else
        {
            cell.like.tintColor = text_mid
            cell.like.setTitleColor(text_mid, for: .normal)

        }
        if like_number != 0
        {cell.like.setTitle("\(like_number)", for: .normal)}
        else
        {cell.like.setTitle("", for: .normal)}
        }
        else
        {
            cell.like.tintColor = text_mid
            cell.like.setTitle("", for: .normal)
        }
        
        
        if (temp._commentIdList) != nil && (temp._commentIdList?.count)! > 0
        {
            cell.comments.setTitle("\((temp._commentIdList?.count)!)", for: .normal)
        }
        else
        {
            cell.comments.setTitle("", for: .normal)
        }
        
        if (temp._shared) != nil
        {
            cell.share.setTitle("\((temp._shared)!)", for: .normal)
        }
        else
        {
            cell.share.setTitle("", for: .normal)
        }
        
        
        
        if ((temp._username) != nil)
        {cell.username.text = temp._username
            cell.username.textColor = text_light
            cell.username.font = cell.username.font.withSize(17)
        }
        if ((temp._title) != nil)
        {cell.title.text = temp._title
            cell.title.font = cell.title.font.withSize(17)
            cell.title.textColor = text_light
            
        }
    
        if ((temp._text) != nil)
        {   cell.content.isHidden = false
            cell.content.text = temp._text
            cell.content.font = cell.content.font.withSize(14)
            cell.content.textColor = text_light
            cell.content.numberOfLines = 0
            cell.content.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.content.sizeToFit()
            cell.content.backgroundColor = mid
        }
        else{
            cell.content.isHidden = true
        }
        
        
        if (temp._profilePicture != nil){
            let url = URL(string:temp._profilePicture!)!
            cell.profile_picture.image = UIImage(data:try! Data(contentsOf: url))}
        cell.images = []
        if (temp._pictures != nil)&&(temp._pictures?.count != 0)
        {
            for i in 0...(temp._pictures?.count)!-1
            {
                
                let url = URL(string:temp._pictures![i])!
                var data:NSData = try! NSData(contentsOf: url)
                let image = UIImage(data: data as Data)!
                cell.images.append(image)
                
            }
        }
        
        
        
        if ((temp._time) != nil)
        {
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
            var a = time[0] % 100
            if year == a
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
            
            cell.time_label.font = cell.time_label.font.withSize(13)
            cell.time_label.text = output
            cell.time_label.textColor = text_mid
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
            cell.profile_picture.layer.borderWidth = 1.0
            cell.profile_picture.layer.masksToBounds = false
            cell.profile_picture.layer.borderColor = UIColor.white.cgColor
            cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
            cell.profile_picture.clipsToBounds = true
        }
        
        
        
        
        
        //cell.image_collection.backgroundColor = mid
        cell.image_collection.reloadData()
        let contentSize = cell.image_collection.collectionViewLayout.collectionViewContentSize
        cell.image_collection.collectionViewLayout.invalidateLayout()
        cell.collectionViewHeight.constant = contentSize.height
        if temp._sharedFrom == nil //no share
        {
            cell.share_view.isHidden = true
            }
        else
        {
            cell.share_view.isHidden = false
            print("height: \(cell.share_view.frame.height)")
            cell.collectionViewHeight.constant = 130
            let url = URL(string:temp._sharedFrom![3])!
            cell.share_profile_picture.image = UIImage(data:try! Data(contentsOf: url))
            cell.share_title.text = temp._sharedFrom![2]
            cell.share_username.text = temp._sharedFrom![1]
            cell.share_view.backgroundColor = sign_in_colour
            cell.share_username.textColor = text_light
           cell.share_title.textColor = text_light
           cell.share_title.font = cell.share_title.font.withSize(14)
            cell.share_title.numberOfLines = 0
            cell.share_title.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell.share_title.sizeToFit()
            //let tap = UITapGestureRecognizer(target:self,action:#selector(bigButtonTapped(_:)))
            //cell.share_view.addGestureRecognizer(tap)
            
        }
        
        
        
        cell.tool_bar.backgroundColor = mid
        cell.tool_bar.layer.borderColor = light.cgColor
        cell.tool_bar.layer.borderWidth = 1
        cell.bot_bar.backgroundColor = light
        

        
        cell.backgroundColor = mid
        return cell
    }
    
    
    @IBAction func share_detail(_ sender: Any) {
        //print("row: \((sender as! UIButton).tag)")
        self.performSegue(withIdentifier: "share_detail", sender: sender)
    }
    
    
    
    
     @objc func bigButtonTapped(_ recognizer:UITapGestureRecognizer) {
        //print("bigButtonTapped")
        self.performSegue(withIdentifier: "share_detail", sender: self)
    }
    
    // MARK: - IBActions
    
//
//    @IBAction func signOut(_ sender: Any) {
//        self.user?.signOut()
//        //self.title = nil
//        self.response = nil
//        //self.tableView.reloadData()
//        self.refresh()
//    }
//    
       func signOut() {
        self.user?.signOut()
        self.title = nil
        self.response = nil
        self.tableView.reloadData()
        self.refresh()
    }
    
    
    @IBAction func wode(_ sender: Any) {
        self.performSegue(withIdentifier: "wode", sender: sender)
    }
    
    
    
    func sort_posts(){
        var id_list:[Int] = []
        for a in posts
        {
            id_list.append(Int(a._id!)!)
        }
        id_list.sort(by: >)
        var temp_list:[ChanceWithValue] = []
        
        for a in 0...posts.count - 1
        {
            for b in posts
            {
                if b._id == String(id_list[a])
                {
                    temp_list.append(b)
                }
            }
        }
        posts = temp_list
    }
    
    
    @objc func refresh() {
        
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
        
        
        
        //*********************** ALL***********************
        if (all == true){
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()            
            let heihei = dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: queryExpression)
            heihei.continueWith(block: { (task:AWSTask<AWSDynamoDBPaginatedOutput>!) -> Any? in
                DispatchQueue.main.async(execute: {
                    if let paginatedOutput = task.result{
                        if (paginatedOutput.items.count < self.posts.count)
                        {self.posts = []}
                        for news in paginatedOutput.items {
                            if !self.posts.contains(news as! ChanceWithValue)
                            {self.posts.append(news as! ChanceWithValue)}
                        }
                    }
                    if self.posts.count > 0
                    {self.sort_posts()}
                })


            })
            heihei.waitUntilFinished()
            
        }
        else
        {
            var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
            var queryExpression = AWSDynamoDBScanExpression()
            
            var temp_list:[ChanceWithValue] = []
            for a in post_key_list{
            dynamoDbObjectMapper.load(ChanceWithValue.self, hashKey: a, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                if let error = task.error as? NSError {
                    print("The request failed. Error: \(error)")
                } else if let resultBook = task.result as? ChanceWithValue {
                    
                    if !self.posts.contains(resultBook as! ChanceWithValue)
                    {self.posts.append(resultBook as! ChanceWithValue)}
                }
                return nil
            })
            }
            
            
        }
        
        
        
        
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
