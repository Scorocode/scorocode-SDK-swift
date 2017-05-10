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
        
        var query = SCQuery(collection: "towns")
        query.equalTo("name", SCString("Moscow"))
        query.find { (success, error, result) in
            print(result)
        }
        
        SC.getCollections { (success, error, result, collections) in
            for coll in collections {
                print(coll.name)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

