//
//  ViewController.swift
//  SwiftSDK
//
//  Created by Alexey Kuznetsov on 10.05.17.
//  Copyright © 2017 Prof-IT Group OOO. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        let user = SCUser()
        user.login("alexey@company.com", password: "TestUser1") { (success, error, result) in
            print(error)
            
            let obj = SCObject(collection: "testcollection")
            obj.set(["fieldString": SCString("bla bla")])
            obj.save { (success, error, result) in
                print(error, result)
            }
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

