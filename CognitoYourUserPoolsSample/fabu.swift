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
class fabu: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate,UICollectionViewDataSource,UITextFieldDelegate {
    var photos:[UIImage] = []
    var SelectedAssets = [PHAsset]()
    let imagePicker = UIImagePickerController()
    
    
    let comments_init = Set<String>()
    
   
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "image_cell", for: indexPath) as! image_cell
        cell.photo.tag = indexPath.row
        cell.photo.isUserInteractionEnabled = true
        //self.view.addSubview(cell.photo)
        //this above line makes images big dont know why
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        cell.photo.addGestureRecognizer(tapSingle)
        cell.photo.image = photos[indexPath.row]
        return cell
    }
    
    
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: photos, index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    var tag_ = 4
    var type = ""
    @IBOutlet weak var title_input: UITextField!
    
    @IBOutlet weak var content: UITextView!
    var placeholderLabel : UILabel!
    @IBAction func image_picker(_ sender: Any) {
        self.photos = []
        self.SelectedAssets = []
        let vc = BSImagePickerViewController()
        vc.maxNumberOfSelections = 9
        vc.selectionCharacter = "✓"
        self.bs_presentImagePickerController(vc, animated: true,
                                             select: { (asset: PHAsset) -> Void in}, deselect: { (asset: PHAsset) -> Void in}, cancel: { (assets: [PHAsset]) -> Void in}, finish: { (assets: [PHAsset]) -> Void in
                                                for i in 0..<assets.count
            {
                self.SelectedAssets.append(assets[i])
            }
            
            self.convertAssetToImages()
        }, completion: nil)
        
        
        //self.images.frame.width = self.photos.count * 30
    }
    
    @IBOutlet weak var choose_tag: UILabel!
    @IBOutlet weak var yuema_tag: UIButton!
    @IBOutlet weak var huodong_tag: UIButton!
    @IBOutlet weak var renwu_tag: UIButton!
    @IBOutlet weak var qita_tag: UIButton!
    @IBOutlet weak var reward_number: UITextField!
    @IBOutlet weak var bonus_number: UITextField!
    @IBOutlet weak var confirm: UIButton!
    @IBOutlet weak var top_bar: UIView!
    @IBOutlet weak var bot_bar: UIView!
    @IBOutlet weak var button: dropDownBtn!
    @IBOutlet weak var images: UICollectionView!
    
    @IBOutlet weak var button2: dropDownBtn!
    
    func convertAssetToImages() -> Void {
        if SelectedAssets.count != 0{
            for i in 0..<SelectedAssets.count{
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: SelectedAssets[i], targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in
                    thumbnail = result!
                })
                let data = UIImageJPEGRepresentation(thumbnail, 0.7)
                
                let newImage = UIImage(data: data!)
                self.photos.append(newImage! as UIImage)
                DispatchQueue.main.async(execute: {
                    
                    self.images.reloadData()})
            }
            
            
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = (self.navigationController?.navigationBar.frame.maxY)!
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let x = self.view.currentFirstResponder()
            if x == self.reward_number || x == self.bonus_number
            {
                let y = self.reward_number.frame.maxY
                //print("maxy: \(y)")
                let offset = self.view.frame.height - y - keyboardHeight
                self.view.frame.origin.y = offset
                
            }
            else if x == self.renshu
            {
                let y = self.renshu.frame.maxY
                //print("maxy: \(y)")
                let offset = self.view.frame.height - y - keyboardHeight
                self.view.frame.origin.y = offset
            }
            //self.view.frame.origin.y = 0 - keyboardHeight
        }
    }

    
    
    
    
    @IBOutlet weak var renshu: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.renshu.delegate = self
        self.renshu.add_placeholder(text: "人数", color: colour)
        self.renshu.backgroundColor = mid
        self.renshu.setBottomBorder()
        self.renshu.textColor = colour
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        self.hideKeyboardWhenTappedAround()
        self.imagePicker.delegate = self
        self.images.layer.cornerRadius = 5.0
        self.images.backgroundColor = light
        
        self.choose_tag.textColor = text_mid
        self.view.backgroundColor = mid
        self.title_input.textColor = text_light
        self.title_input.backgroundColor = light
        self.title_input.add_placeholder(text: "标题", color: text_mid)
    
        self.view.addSubview(self.yuema_tag)
        self.yuema_tag.backgroundColor = light
        self.view.addSubview(self.huodong_tag)
        self.huodong_tag.backgroundColor = light
        self.view.addSubview(self.renwu_tag)
        self.renwu_tag.backgroundColor = light
        self.view.addSubview(self.qita_tag)
        self.qita_tag.backgroundColor = light
        self.yuema_tag.setTitle("约嘛", for: .normal)
        self.huodong_tag.setTitle("活动", for: .normal)
        self.renwu_tag.setTitle("任务", for: .normal)
        self.qita_tag.setTitle("其他", for: .normal)
        self.yuema_tag.tintColor = text_mid
        self.huodong_tag.tintColor = text_mid
        self.renwu_tag.tintColor = text_mid
        self.qita_tag.tintColor = text_mid
        
        
        
        self.content.textColor = text_mid
        self.content.backgroundColor = light
        self.content.layer.cornerRadius = 5.0
        self.top_bar.backgroundColor = sign_in_colour
        self.bot_bar.backgroundColor = sign_in_colour
        
        
        let padding = UIView(frame: CGRect(x:0, y:0, width:87, height:self.reward_number.frame.height))
        let paddingView = UILabel(frame: CGRect(x:0, y:0, width:150, height:self.reward_number.frame.height))
        paddingView.text = "  奖励："
        self.reward_number.backgroundColor = colour
        self.reward_number.textColor = sign_in_colour
        self.reward_number.leftView = paddingView
        self.reward_number.leftViewMode = UITextFieldViewMode.always
        self.reward_number.rightView = padding
        self.reward_number.rightViewMode = UITextFieldViewMode.always
        
        
        let padding2 = UIView(frame: CGRect(x:0, y:0, width:87, height:self.reward_number.frame.height))
        let paddingView2 = UILabel(frame: CGRect(x:0, y:0, width:150, height:self.reward_number.frame.height))
        paddingView2.text = "  价格："
        self.bonus_number.backgroundColor = colour
        self.bonus_number.textColor = sign_in_colour
        self.bonus_number.leftView = paddingView2
        self.bonus_number.leftViewMode = UITextFieldViewMode.always
        self.bonus_number.rightView = padding2
        self.bonus_number.rightViewMode = UITextFieldViewMode.always
        
        
        self.button2.layer.cornerRadius = 5.0
        self.button2.backgroundColor = colour
        self.button2.tintColor = sign_in_colour
        self.button2.setTitle("cc", for: .normal)
        //self.view.addSubview(button2)
        self.button2.dropView.dropDownOptions = ["cc","btc", "eth"]//, "Magenta", "White", "Black", "Pink"]
        //self.button2.isHidden = true
    
        self.button.layer.cornerRadius = 5.0
        self.button.backgroundColor = colour
        self.button.tintColor = sign_in_colour
       self.button.setTitle("cc", for: .normal)
        //self.view.addSubview(button)
        self.button.dropView.dropDownOptions = ["cc","btc", "Green"]//, "Magenta", "White", "Black", "Pink"]
      //print("dude")
       // print(self.button.dropView.tableView.delegate)
        
        //self.view.addSubview(self.renshu)
        
        
        self.confirm.backgroundColor = colour
        self.confirm.setTitleColor(sign_in_colour, for:.normal)
        self.confirm.layer.cornerRadius = 5.0


    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.setToolbarHidden(false, animated: true)
        
    }
  
    override func viewDidLayoutSubviews() {
        self.yuema_tag.layer.cornerRadius = 0.5 * self.yuema_tag.bounds.size.width
        self.yuema_tag.clipsToBounds = true
        
        self.huodong_tag.layer.cornerRadius = 0.5 * self.huodong_tag.bounds.size.width
        self.huodong_tag.clipsToBounds = true
        
        self.renwu_tag.layer.cornerRadius = 0.5 * self.renwu_tag.bounds.size.width
        self.renwu_tag.clipsToBounds = true
        
        self.qita_tag.layer.cornerRadius = 0.5 * self.qita_tag.bounds.size.width
        self.qita_tag.clipsToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
        
        //background
        //self.view.backgroundColor = sign_in_colour
        
        //navigation bar
        self.title = "发布"
      
    }
    
    
    @IBAction func yuema_tag(_ sender: Any) {
        tag_ = 0
        self.yuema_tag.tintColor = colour
        self.huodong_tag.tintColor = text_mid
        self.renwu_tag.tintColor = text_mid
        self.qita_tag.tintColor = text_mid
        yuema_tag.backgroundColor = sign_in_colour
        renwu_tag.backgroundColor = light
        huodong_tag.backgroundColor = light
        qita_tag.backgroundColor = light
    }
    
    @IBAction func huodong_tag(_ sender: Any) {
        tag_ = 1
        self.yuema_tag.tintColor = text_mid
        self.huodong_tag.tintColor = colour
        self.renwu_tag.tintColor = text_mid
        self.qita_tag.tintColor = text_mid
        yuema_tag.backgroundColor = light
        renwu_tag.backgroundColor = light
        huodong_tag.backgroundColor = sign_in_colour
        qita_tag.backgroundColor = light
    }
    
    @IBAction func renwu_tag(_ sender: Any) {
        tag_ = 2
        self.yuema_tag.tintColor = text_mid
        self.huodong_tag.tintColor = text_mid
        self.renwu_tag.tintColor = colour
        self.qita_tag.tintColor = text_mid
        yuema_tag.backgroundColor = light
        renwu_tag.backgroundColor = sign_in_colour
        huodong_tag.backgroundColor = light
        qita_tag.backgroundColor = light
    }
    
    @IBAction func qita_tag(_ sender: Any) {
        self.yuema_tag.tintColor = text_mid
        self.huodong_tag.tintColor = text_mid
        self.renwu_tag.tintColor = text_mid
        self.qita_tag.tintColor = colour
        
        yuema_tag.backgroundColor = light
        renwu_tag.backgroundColor = light
        huodong_tag.backgroundColor = light
        qita_tag.backgroundColor = sign_in_colour
        tag_ = 3
    }
    
    @IBAction func confirm(_ sender: Any) {
       // _ = self.navigationController?.popToRootViewController(animated: true)
        var counter = 0
        
        guard let current_title = self.title_input.text, !current_title.isEmpty else {
            let alertController = UIAlertController(title: "信息不足",
                                                    message: "请输入标题",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        guard let current_content = self.content.text, !current_content.isEmpty else {
            let alertController = UIAlertController(title: "信息不足",
                                                    message: "请输入内容",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        if self.tag_ == 4 {
            let alertController = UIAlertController(title: "信息不足",
                                                    message: "请选择标签",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        if self.reward_number.text != nil && self.reward_number.text != "" && self.reward_number.text != "0" && self.bonus_number.text != nil && self.bonus_number.text != "" && self.bonus_number.text != "0" {
            let alertController = UIAlertController(title: "乱啦",
                                                    message: "一个发布不能同时作为收费和付费机会出现，请只输入其中至多一个数字",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        
        if self.renshu.text == "" || self.renshu.text == nil {
            let alertController = UIAlertController(title: "信息不足",
                                                    message: "请输入人数",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }
        var expense = 0.0
        if self.reward_number.text != nil
        {expense = Double(self.reward_number.text!)! * Double(self.renshu.text!)!}
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        var avail = 0.0
        var froz = 0.0
        let user = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
       let haha = dynamoDbObjectMapper.load(UserPool.self, hashKey: user, rangeKey:nil)
        var p:UserPool = UserPool()
        haha.continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
            if let error = task.error as? NSError {
                print("The request failed. Error: \(error)")
            } else if let resultBook = task.result as? UserPool {
                avail = resultBook._availableWallet as! Double
                froz = resultBook._frozenwallet as! Double
                p = resultBook
            }
            return nil
        })
        haha.waitUntilFinished()
        
       // print("avail: \(avail)")
        //print("expense: \(expense)")
        if avail < expense {
            let alertController = UIAlertController(title: "无法通过",
                                                    message: "钱包可用金额不足",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertController.addAction(okAction)
            
            self.present(alertController, animated: true, completion:  nil)
            return
        }else if self.reward_number.text != nil && Double(self.reward_number.text!) != 0
        {
            avail = avail - expense
            froz = froz + expense
            p._availableWallet = avail as NSNumber
            p._frozenwallet = froz as NSNumber
            dynamoDbObjectMapper.save(p,completionHandler:nil)
        }
        
        
        
        
        
        var temp:ChanceWithValue = ChanceWithValue()
        let date = Date()
        let calendar = Calendar.current
        let year  = calendar.component(.year, from: date) // 0
        let month = calendar.component(.month, from: date) // 1
        let day = calendar.component(.day, from: date) //2
        let hour = calendar.component(.hour, from: date) // 3
        let minute = calendar.component(.minute, from: date) // 4
        let second = calendar.component(.second, from: date) // 5
        let temp_time1 = UInt64(year * 10000000000 + month * 100000000 + day * 1000000)
        let temp_time2 = UInt64(hour * 10000 + minute * 100 + second)
        temp._time = (temp_time1 + temp_time2) as NSNumber
        temp._fuFeiType = self.button.titleLabel?.text
        temp._shouFeiType = self.button2.titleLabel?.text
        temp._tag = tag_ as NSNumber
        temp._username = user
       
        temp._title = self.title_input.text
        temp._text = self.content.text
        if self.bonus_number.text != nil && self.bonus_number.text != ""
        {temp._shouFei = Double(self.bonus_number.text!) as! NSNumber}
        else
        {temp._shouFei = 0}
        if self.reward_number.text != nil && self.reward_number.text != ""
        {temp._fuFei = Double(self.reward_number.text!) as! NSNumber}
        else
        {temp._fuFei = 0}
        var dude = ""//pictureid in the database
        //profile
        temp._profilePicture = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + temp._username! + ".png"
        temp._renShu = Int(self.renshu.text!) as! NSNumber
        
        
        dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    
             //   print(paginatedOutput.items.count)
                counter = paginatedOutput.items.count + 1
               // print("counter: \(counter)")
                temp._id = String(counter)
                
                    dynamoDbObjectMapper.load(UserPool.self, hashKey: temp._username, rangeKey:nil).continueWith(block: { (task:AWSTask<AnyObject>!) -> Any? in
                        if let error = task.error as? NSError {
                            print("The request failed. Error: \(error)")
                        } else if let resultBook = task.result as? UserPool {
                            if resultBook._chanceIdList != nil{
                                resultBook._chanceIdList?.append(temp._id!)}
                            else
                            {resultBook._chanceIdList = [temp._id] as! [String]}
                            dynamoDbObjectMapper.save(resultBook,completionHandler:nil)
                        }
                        return nil
                    })
                    
                    
                    
                    
                    if self.photos.count != 0{
                        temp._pictures = []
                    for a in 0...self.photos.count-1
                    {
                        dude = String(temp._id!) + "_" + String(a) + ".png"
                        uploadImage(with: UIImagePNGRepresentation(self.photos[a])!, bucket: pictures, key: dude)
                        dude = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + dude
                        temp._pictures!.append(dude)
                        }}
                    dynamoDbObjectMapper.save(temp, completionHandler: nil)
                    
                    _ = self.navigationController?.popToRootViewController(animated: true)
                    
                }
            })
        })
        
        
        
        
    }
    
    
    
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
