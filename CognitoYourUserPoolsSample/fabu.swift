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
class fabu: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UICollectionViewDelegate,UICollectionViewDataSource {
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
    var tag_ = 0
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
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        self.images.layer.cornerRadius = 5.0
        self.images.backgroundColor = light
        
        self.choose_tag.textColor = text_mid
        self.view.backgroundColor = mid
        self.title_input.textColor = text_light
        self.title_input.backgroundColor = light
        self.title_input.attributedPlaceholder = NSAttributedString(string: "标题",
                                                                    attributes: [kCTForegroundColorAttributeName as NSAttributedStringKey:text_light])
        
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
        paddingView.text = "  交易金额："
        self.reward_number.backgroundColor = colour
        self.reward_number.textColor = sign_in_colour
        self.reward_number.leftView = paddingView
        self.reward_number.leftViewMode = UITextFieldViewMode.always
        self.reward_number.rightView = padding
        self.reward_number.rightViewMode = UITextFieldViewMode.always
        
        
        let padding2 = UIView(frame: CGRect(x:0, y:0, width:87, height:self.reward_number.frame.height))
        let paddingView2 = UILabel(frame: CGRect(x:0, y:0, width:150, height:self.reward_number.frame.height))
        paddingView2.text = "  追加奖励："
        self.bonus_number.backgroundColor = colour
        self.bonus_number.textColor = sign_in_colour
        self.bonus_number.leftView = paddingView2
        self.bonus_number.leftViewMode = UITextFieldViewMode.always
        self.bonus_number.rightView = padding2
        self.bonus_number.rightViewMode = UITextFieldViewMode.always
        
        
        self.button.layer.cornerRadius = 5.0
        self.button.backgroundColor = colour
        self.button.tintColor = sign_in_colour
       self.button.setTitle("CC ▼", for: .normal)
        self.view.addSubview(button)
        self.button.dropView.dropDownOptions = ["Blue", "Green"]//, "Magenta", "White", "Black", "Pink"]
        
        self.confirm.backgroundColor = colour
        self.confirm.setTitleColor(sign_in_colour, for:.normal)
        self.confirm.layer.cornerRadius = 5.0


    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //self.navigationController?.hidesBottomBarWhenPushed = true
        self.navigationController?.setToolbarHidden(false, animated: true)
        
    }
//    func textViewDidChange(_ textView: UITextView) {
//        placeholderLabel.isHidden = !textView.text.isEmpty
//    }
//    
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
        self.navigationController?.navigationBar.tintColor = colour
        self.navigationController?.navigationBar.barTintColor = sign_in_colour
        self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName:colour] as [NSAttributedStringKey : Any]
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
        
        var temp:ChanceWithValue = ChanceWithValue()
        let date = Date()
        let calendar = Calendar.current
        let year  = calendar.component(.year, from: date) // 0
        let month = calendar.component(.month, from: date) // 1
        let day = calendar.component(.day, from: date) //2
        let hour = calendar.component(.hour, from: date) // 3
        let minute = calendar.component(.minute, from: date) // 4
        let second = calendar.component(.second, from: date) // 5
        let temp_time1 = Int(year * 10000000000 + month * 100000000 + day * 1000000)
        let temp_time2 = Int(hour * 10000 + minute * 100 + second)
        temp._time = (temp_time1 + temp_time2) as NSNumber
        temp._rewardType = self.button.titleLabel?.text
        temp._tag = tag_ as NSNumber
        temp._username = AWSCognitoUserPoolsSignInProvider.sharedInstance().getUserPool().currentUser()?.username
       // temp._comments = comments_init
        //seems that sets in aws database cannot be set to empty array
        // will just give value when first one comments
        //temp._shared = 0
        //temp._liked = 0
        temp._title = self.title_input.text
        temp._text = self.content.text
        temp._bonus = Int(self.bonus_number.text!) as! NSNumber
        temp._reward = Int(self.bonus_number.text!) as! NSNumber
        var dude = ""//pictureid in the database
        //profile
        temp._profilePicture = "https://s3.amazonaws.com/chance-userfiles-mobilehub-653619147/" + temp._username! + ".png"
        
        
        if (bonus_number.text != nil)
        {temp._bonus = Int(bonus_number.text!) as! NSNumber}
        if (reward_number.text != nil)
        {temp._reward = Int(reward_number.text!) as! NSNumber}
        var dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        var queryExpression = AWSDynamoDBScanExpression()
        dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: queryExpression, completionHandler:{(task:AWSDynamoDBPaginatedOutput?, error: Error?) -> Void in
            DispatchQueue.main.async(execute: {
                if let paginatedOutput = task{
                    
                print(paginatedOutput.items.count)
                counter = paginatedOutput.items.count + 1
                print("counter: \(counter)")
                temp._id = String(counter)
                
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

protocol dropDownProtocol {
    func dropDownPressed(string : String)
}

class dropDownBtn: UIButton, dropDownProtocol {
    
    func dropDownPressed(string: String) {
        self.setTitle(string, for: .normal)
        self.dismissDropDown()
    }
    
    var dropView = dropDownView()
    
    var height = NSLayoutConstraint()
    
    override func removeFromSuperview() {
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.darkGray
        
        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
    override func didMoveToSuperview() {
        self.superview?.addSubview(dropView)
        self.superview?.bringSubview(toFront: dropView)
        dropView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dropView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        dropView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        height = dropView.heightAnchor.constraint(equalToConstant: 0)
    }
    
    var isOpen = false
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isOpen == false {
            
            isOpen = true
            
            NSLayoutConstraint.deactivate([self.height])
            
            if self.dropView.tableView.contentSize.height > 150 {
                self.height.constant = 150
            } else {
                self.height.constant = self.dropView.tableView.contentSize.height
            }
            
            
            NSLayoutConstraint.activate([self.height])
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.layoutIfNeeded()
                self.dropView.center.y += self.dropView.frame.height / 2
            }, completion: nil)
            
        } else {
            isOpen = false
            
            NSLayoutConstraint.deactivate([self.height])
            self.height.constant = 0
            NSLayoutConstraint.activate([self.height])
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.dropView.center.y -= self.dropView.frame.height / 2
                self.dropView.layoutIfNeeded()
            }, completion: nil)
            
        }
    }
    
    func dismissDropDown() {
        isOpen = false
        NSLayoutConstraint.deactivate([self.height])
        self.height.constant = 0
        NSLayoutConstraint.activate([self.height])
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.dropView.center.y -= self.dropView.frame.height / 2
            self.dropView.layoutIfNeeded()
        }, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.backgroundColor = UIColor.darkGray
        
        dropView = dropDownView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
        dropView.delegate = self
        dropView.translatesAutoresizingMaskIntoConstraints = false
    }
}

class dropDownView: UIView, UITableViewDelegate, UITableViewDataSource  {
    
    var dropDownOptions = [String]()
    
    var tableView = UITableView()
    
    var delegate : dropDownProtocol!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        tableView.backgroundColor = colour
        self.backgroundColor = colour
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(tableView)
        
        tableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dropDownOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        cell.textLabel?.text = dropDownOptions[indexPath.row]
        cell.textLabel?.textColor = sign_in_colour
        cell.backgroundColor = colour
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.dropDownPressed(string: dropDownOptions[indexPath.row])
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
}




