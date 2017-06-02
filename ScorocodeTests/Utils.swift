//
//  Utils.swift
//  SC
//
//  Created by Alexey Kuznetsov on 27/12/2016.
//  Copyright © 2016 Prof-IT Group OOO. All rights reserved.
//

import XCTest

func assertSuccess(success: Bool, error: SCError?, result: Any?) {
    
    XCTAssertTrue(success)
    XCTAssertNil(error)
    XCTAssertNotNil(result)
}

func assertError(success: Bool, error: SCError?, result: Any?) {
    
    XCTAssertFalse(success)
    XCTAssertNotNil(error)
    XCTAssertNil(result)
}
