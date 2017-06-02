//
//  TaskListCell.swift
//  todolist
//
//  Created by Alexey Kuznetsov on 31/10/2016.
//  Copyright © 2016 ProfIT. All rights reserved.
//

import UIKit

class TaskListCell : UITableViewCell {
    
    @IBOutlet weak var labelTaskName: UILabel!
    @IBOutlet weak var imageViewStatusDone: UIImageView!
    @IBOutlet weak var imageViewStatusClosed: UIImageView!
    @IBOutlet weak var labelCloseDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    
    func setupCell(_ taskName: String, statusDone: Bool, statusClosed: Bool, closeDate: Date, username: String) {
        self.labelTaskName.text = taskName
        self.imageViewStatusDone.image = statusDone ? UIImage(named: "StatusOk") : UIImage(named: "StatusBad")
        self.imageViewStatusClosed.image = statusClosed ? UIImage(named: "StatusOk") : UIImage(named: "StatusBad")
        self.labelUsername.text = username
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy HH:mm"
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        let dateObj = dateFormatter.string(from: closeDate)
        self.labelCloseDate.text = dateObj
        self.contentView.alpha = statusClosed ? 0.3 : 1.0
    }
}
