//
//  EventViewCell.swift
//  ToDoList
//
//  Created by Shawn Wu on 7/19/18.
//  Copyright © 2018 Shawn Wu. All rights reserved.
//

import UIKit

class EventViewCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var categoryIcon: UIImageView!
    
    func configure(item: Event) {
        categoryIcon.image = UIImage(named: item.category.stringValue)
        title?.text = item.content
        let df = DateFormatter()
        df.dateFormat = "MM/dd hh:mm"
        let time = df.string(from: item.time)
        self.time.text = time
        
        switch item.state {
        case .overdue:
            title.textColor = UIColor.gray
            self.time.textColor = UIColor.gray
            self.icon.image = UIImage(named: "cross")
        case .complete:
            title.textColor = UIColor.black
            self.time.textColor = UIColor.black
            self.icon.image = UIImage(named: "check")
        default:
            break
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        icon.image = nil
        categoryIcon.image = nil
        title.textColor = UIColor.black
        time.textColor = UIColor.black
    }
}
