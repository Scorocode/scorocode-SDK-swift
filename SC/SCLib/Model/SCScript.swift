//
//  SCScript.swift
//  SC
//
//  Created by Aleksandr Konakov on 28/04/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import Foundation

public struct SCScript {
    
    public static func run(_ scriptId: String, pool: [String: AnyObject], callback: @escaping (Bool, SCError?) -> Void) {
        
        SCAPI.sharedInstance.scripts(scriptId, pool: pool, callback: callback)
    }
}
