//
//  SCScript.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public struct SCScript {
    
    public static func run(_ scriptId: String, pool: [String: AnyObject], debug: Bool, callback: @escaping (Bool, SCError?) -> Void) {
        
        SCAPI.sharedInstance.scripts(scriptId, pool: pool, debug: debug, callback: callback)
    }
}
