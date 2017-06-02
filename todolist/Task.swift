//
//  Task.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 31/10/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import Foundation

class Task {
    var id : String = ""
    var name : String = ""
    var isDone : Bool = false
    var isClose : Bool = false
    var comment : String = ""
    var bossComment : String = ""
    var detailed: String = ""
    var closeDate : Date = Date()
    var user : String = ""
    var username : String = ""
    
    init() {
        
    }
}
