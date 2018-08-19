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
    
    let table_titles:[String] = ["更换头像","昵称","机会号","钱包地址","姓名","性别","职业","简介"]
    var pic:UIImage = UIImage()
    var p:UserPool = UserPool()
    let imagePicker = UIImagePickerController()
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = self.table.indexPathForSelectedRow!.row
        if row == 0
        {
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            
        }
        else
        {
            let cell = self.table.cellForRow(at: indexPath) as! info_cell
            cell.info.becomeFirstResponder()
        }
    }
//
//    @objc func keyboardWillHide(notification: NSNotification) {
//        table.setContentOffset(CGPoint(x:0,y:0), animated: true)
//        let row = self.table.indexPathForSelectedRow!.row
//        let indexPath = self.table.indexPathForSelectedRow!
//        let cell = self.table.cellForRow(at: indexPath) as! info_cell
//        if row == 1
//        {p._nickName = cell.info.text}
//        if row == 2
//        {p._chanceId = cell.info.text}
//        if row == 3
//        {p._walletAddress = cell.info.text}
//        if row == 4
//        {
//            p._name = cell.info.text
//        }
//        if row == 5
//        {p._gender = cell.info.text}
//        if row == 6
//        {p._career = cell.info.text}
//        if row == 7
//        {p._resume = cell.info.text}
//
//    }
//
//    @objc func keyboardWillAppear(notification: NSNotification) {
//
//        let row = self.table.indexPathForSelectedRow!.row
//
//        if row == 6
//        {table.setContentOffset(CGPoint(x:0,y:30), animated: true)}
//        else if row == 7
//        {
//            let indexPath = self.table.indexPathForSelectedRow!
//            let cell = self.table.cellForRow(at: indexPath) as! info_cell
//            table.setContentOffset(CGPoint(x:0,y:60 + cell.image_height.constant), animated: true)}
//    }
//
    
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
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: .UIKeyboardWillShow, object: nil)
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
            //print("nimei")
           //cell.profile_picture.isHidden = false
            cell.info.isHidden = true
            if ((p._profilePic != nil))
            {//print("nimei")
                
                cell.profile_picture.layer.borderWidth = 1.0
                cell.profile_picture.layer.masksToBounds = false
                cell.profile_picture.layer.borderColor = UIColor.white.cgColor
                //print("width: \(cell.profile_picture.frame.size.height)")
                cell.image_height.constant = 50
                cell.profile_picture.layer.cornerRadius = cell.profile_picture.frame.size.width / 2
                cell.profile_picture.clipsToBounds = true
                cell.profile_picture.image = pic
                //self.table.addSubview(cell.profile_picture)
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
              //  print(cell.image_height.constant)
            }
            
            
            
           
            
           // cell.info_height.constant = cell.image_height.constant + 10
            

            
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
        if p._profilePic != nil{
        let url = URL(string: p._profilePic!)
            let data = try? Data(contentsOf: url!)
            pic = UIImage(data:data!)!
        }
        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确认", style: .plain, target: self, action: #selector(confirm))
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
        print("in")
        let image: UIImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        let dude = String(p._userId!) + ".png"
        print(dude)
        uploadImage(with: UIImagePNGRepresentation(image)!, bucket: pictures, key: dude)
        pic = image
        //self.download(key_: "download.png")
    }
    
    table.reloadData()
    dismiss(animated: true, completion: nil)
}
}
