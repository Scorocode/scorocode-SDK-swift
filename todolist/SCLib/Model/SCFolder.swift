//
//  SCFolder.swift
//  Scorocode
//
//  Created by Alexey Kuznetsov on 02.04.17.
//  Copyright © 2017 Prof-IT Group OOO. All rights reserved.
//

import Foundation

public class SCFolder {
    
    public init () {
        
    }
    
    // Создание новой папки
    public func createFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        SCAPI.sharedInstance.createFolder(path: path, callback: callback)
    }
    
    // Удаление папки со всем содержимым
    public func deleteFolder(path: String, callback: @escaping (Bool, SCError?, [String: Any]?) -> Void) {
        SCAPI.sharedInstance.deleteFolder(path: path, callback: callback)
    }
    
}
