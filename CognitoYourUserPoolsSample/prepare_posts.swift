//
//  prepare_posts.swift
//  chain
//
//  Created by xuechuan mi on 2018-07-09.
//  Copyright © 2018 Dubal, Rohan. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB
import AWSMobileClient
import AWSCore
import AWSPinpoint
import Foundation
import AWSS3

class prepare_posts: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        let dynamoDbObjectMapper = AWSDynamoDBObjectMapper.default()
        let scanExpression = AWSDynamoDBScanExpression()
        DispatchQueue.main.async(execute: {
            dynamoDbObjectMapper.scan(ChanceWithValue.self, expression: scanExpression) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
                if error != nil {
                    print("The request failed. Error: \(String(describing: error))")
                }
                if output != nil {
                    //    DispatchQueue.main.async(execute: {
                    for news in output!.items {
                        //posts.append(news as! Posts)
                    }
                    //   })
                }
            }
        })
     //   while(posts.count == 0){}
        
       // print("delegate: \(posts.count)")
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
