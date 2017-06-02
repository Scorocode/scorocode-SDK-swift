//
//  History.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 09/11/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import Foundation

class History {
    var date: Date = Date()
    var value: String = ""
    var field: String = ""
    
    init(date: Date, value: String, field: String) {
        self.date = date
        self.value = value
        self.field = field
    }
}
