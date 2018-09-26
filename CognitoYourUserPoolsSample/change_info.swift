//
//  change_info.swift
//  chain
//
//  Created by xuechuan mi on 2018-08-09.
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

class change_info: UIViewController,UITableViewDelegate,UITableViewDataSource, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate {
    var dude = ""
    var head:UIImage = UIImage()
    let table_titles:[String] = ["更换头像".toLocal(),"昵称".toLocal(),"机会号".toLocal(),"钱包地址".toLocal(),"姓名".toLocal(),"性别".toLocal(),"职业".toLocal(),"简介".toLocal()]
    var pic:UIImage = UIImage()
    var p:UserPool = UserPool()
    let imagePicker = UIImagePickerController()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.table.indexPathForSelectedRow!.row
        let cell = self.table.cellForRow(at: indexPath) as! info_cell
        cell.info.isEditable = true
        if row == 0
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            
        }
        else if row != 3
        {
            let cell = self.table.cellForRow(at: indexPath) as! info_cell
            cell.info.becomeFirstResponder()
        }
        else
        {
            let cell = self.table.cellForRow(at: indexPath) as! info_cell
            cell.info.isEditable = false
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        let row = textView.tag
        
        if row == 6
        {table.setContentOffset(CGPoint(x:0,y:30), animated: true)}
        else if row == 7
        {
            let indexPath = IndexPath(item: row, section: 0)
            let cell = self.table.cellForRow(at: indexPath) as! info_cell
            table.setContentOffset(CGPoint(x:0,y:60 + cell.image_height.constant), animated: true)}
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        table.setContentOffset(CGPoint(x:0,y:0), animated: true)
        let row = textView.tag
        let indexPath = IndexPath(item: row, section: 0)
        let cell = self.table.cellForRow(at: indexPath) as! info_cell
        if row == 1
        {p._nickName = cell.info.text}
        if row == 2
        {p._chanceId = cell.info.text}
        if row == 3
        {p._walletAddress = cell.info.text}
        if row == 4
        {
            p._name = cell.info.text
        }
        if row == 5
        {p._gender = cell.info.text}
        if row == 6
        {p._career = cell.info.text}
        if row == 7
        {p._resume = cell.info.text}
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            //print("done")
            textView.resignFirstResponder()
            return false
        }
        return true
    }
  
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "info_cell", for: indexPath) as! info_cell
        cell.info.delegate = self
        cell.info.returnKeyType = UIReturnKeyType.done
        cell.textLabel?.textColor = text_light
        cell.textLabel?.text = table_titles[indexPath.row]
        cell.backgroundColor = mid
        //cell.accessoryType = .disclosureIndicator
        cell.layer.borderWidth = 0.2
        cell.layer.borderColor = text_mid.cgColor
        cell.info.textColor = text_mid
        cell.info.backgroundColor = mid
        cell.info.tag = indexPath.row
        if indexPath.row == 0
        {
            cell.info.isHidden = true
            if ((p._profilePic != nil))
            {
                
                cell.profile_picture.layer.borderWidth = 1.0
                cell.profile_picture.layer.masksToBounds = false
                cell.profile_picture.layer.borderColor = UIColor.white.cgColor
                //print("width: \(cell.profile_picture.frame.size.height)")
                cell.image_height.constant = 50
                cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
                cell.profile_picture.clipsToBounds = true
                
                
//                if let cachedVersion = imageCache.object(forKey: "\(p._userId!).png" as NSString) {
//                    cell.profile_picture.image = cachedVersion
//                }
//                else{
//                    downloadImage(key_: "\(p._userId!).png", destination: cell.profile_picture)
//                }
                
                let message = "\(p._userId!).png"
                if let value = cache.secondaryCache?.load(key: message) {
                    // print("inhaha")
                    let cachedVersion = UIImage(data:value as! Data)
                    cell.profile_picture.image = cachedVersion
                    
                }else
                {
                    downloadImage(key_: message as String, destination: cell.profile_picture)
                }
                
                //downloadImage(key_: "\(p._userId!).png", destination: cell.profile_picture)
            }
        }
        else
        {
            //cell.profile_picture.isHidden = true
            cell.image_height.constant = 30
            cell.info_width.constant = 100
            cell.info.isHidden = false
            cell.info.font = cell.info.font?.withSize(14)
            
             if indexPath.row == 1
             {
                cell.info.text = p._nickName
            }
            if indexPath.row == 2
            {
                cell.info.text = p._chanceId
            }
            if indexPath.row == 3
            {
                cell.info.text = p._walletAddress
                cell.info_width.constant = 200
                cell.image_height.constant = (cell.info.text?.height(withConstrainedWidth: 200, font: cell.info.font!))! + 20
            }
            if indexPath.row == 4
            {
                cell.info.text = p._name
            }
            if indexPath.row == 5
            {
                cell.info.text = p._gender
            }
            if indexPath.row == 6
            {
                cell.info.text = p._career
            }
            if indexPath.row == 7
            {
                cell.info.text = p._resume
            cell.info_width.constant = 200
                 cell.image_height.constant = (cell.info.text?.height(withConstrainedWidth: 200, font: cell.info.font!))! + 20
            }
            
            
            

            
        }
       
        if indexPath.row != 0 && indexPath.row != 7
        {
            //cell.textLabel?.textColor = UIColor.gray
        }
        
        return cell
        
    }
    
    @objc func confirm(){
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        dynamoDbObjectMapper.save(p,completionHandler: nil)
        
        self.navigationController?.popViewController(animated: true)
    }
    


    @IBOutlet weak var table_height: NSLayoutConstraint!
    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker.delegate = self
        while(p._userId == nil)
        {
        }
        self.hideKeyboardWhenTappedAround()

        self.table.isScrollEnabled = false
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确认".toLocal(), style: .plain, target: self, action: #selector(confirm))
        self.table.estimatedRowHeight = 150
        self.table.rowHeight = UITableViewAutomaticDimension
        self.view.backgroundColor = mid
        self.table.backgroundColor = mid
        self.table.separatorStyle = UITableViewCellSeparatorStyle.none
    
        
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    //    self.navigationController?.navigationBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
       // self.navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

   

}



@objc extension change_info{
public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    if "public.image" == info[UIImagePickerControllerMediaType] as? String {
        //print("in")
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dude = String(p._userId!) + ".png"
        head = image
        set_image_cache(key: dude, image: head)
        uploadImage(with: UIImagePNGRepresentation(head)!, bucket: pictures, key: dude)
        
        self.table.reloadRows(at: [[0,1] as IndexPath], with: .automatic)
        
        pic = image
    }
    
    table.reloadData()
    dismiss(animated: true, completion: nil)
}
}
