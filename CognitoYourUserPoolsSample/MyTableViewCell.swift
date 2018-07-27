//
//  post_self.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-11.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit
import Kingfisher
class MyTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       // print("count:\(images.count)")
        return images.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell",
                                                       for: indexPath) as! MyCollectionViewCell
        
        cell.photo.image = images[indexPath.row]
        cell.photo.tag = indexPath.row
        cell.photo.isUserInteractionEnabled = true
        //self.myViewController.view.addSubview(cell.photo)
       // this above line makes images big dont know why
        let tapSingle=UITapGestureRecognizer(target:self,
                                             action:#selector(imageViewTap(_:)))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        cell.photo.addGestureRecognizer(tapSingle)
        return cell
        
    }
    
    @objc func imageViewTap(_ recognizer:UITapGestureRecognizer){
        //图片索引
        let index = recognizer.view!.tag
        //进入图片全屏展示
        let previewVC = ImagePreviewVC(images: images, index: index)
        //self.navigationController?.setToolbarHidden(true, animated: true)
        self.firstViewController()?.navigationController?.pushViewController(previewVC, animated: true)
    }
    
   
    @IBOutlet weak var profile_picture: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var time_label: UILabel!
    @IBOutlet weak var tagg: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var image_collection: UICollectionView!
   // var urls:[URL] = []
     var myViewController: UIViewController!
    var images:[UIImage] = []
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //设置collectionView的代理
        self.image_collection.delegate = self
        self.image_collection.dataSource = self
        
        // 注册CollectionViewCell
        self.image_collection!.register(UINib(nibName:"MyCollectionViewCell", bundle:nil),forCellWithReuseIdentifier: "myCell")
    }
    
    

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    
}
