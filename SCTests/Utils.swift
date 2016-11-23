//
//  Utils.swift
//  SC
//
//  Created by Aleksandr Konakov on 20/05/16.
//  Copyright © 2016 Aleksandr Konakov. All rights reserved.
//

import XCTest
@testable import SC

func assertSuccess(_ success: Bool, _ error: SCError?, _ result: AnyObject?) {
    
    XCTAssertTrue(success)
    XCTAssertNil(error)
    XCTAssertNotNil(result)
}

func assertError(_ success: Bool, _ error: SCError?, _ result: AnyObject?) {
    
    XCTAssertFalse(success)
    XCTAssertNotNil(error)
    XCTAssertNil(result)
}
