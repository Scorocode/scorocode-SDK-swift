//
//  SCScript.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

struct SCScript {
    
    static func run(scriptId: String, pool: [String: AnyObject], callback: (Bool, SCError?) -> Void) {
        
        SCAPI.sharedInstance.scripts(scriptId, pool: pool, callback: callback)
    }
}