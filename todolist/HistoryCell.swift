//
//  HistoryCell.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 09/11/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit

class HistoryCell : UITableViewCell {
    
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelField: UILabel!
    @IBOutlet weak var labelValue: UILabel!
    
    func setCell(_ date: Date, field: String, value: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        let dateObj = dateFormatter.string(from: date)
        self.labelDate.text = dateObj
        self.labelField.text = field
        self.labelValue.text = value
        self.isUserInteractionEnabled = false
    }
    
}
