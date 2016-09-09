//
//  BudgetTableViewCell.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/8/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class BudgetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var spentTotalLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    func configureFor(category: String, budget: NSNumber, andAmount: NSNumber) {
        self.categoryLabel.text = category
        let nf: NumberFormatter = NumberFormatterManger.sharedInstance.cf
        var spentText = nf.string(from: andAmount)
        spentText = spentText! + "/" + nf.string(from: budget)!
        self.spentTotalLabel.text = spentText
        var diff = budget.doubleValue - andAmount.doubleValue
        var color: UIColor?
        if diff < 0.0 {
            color = UIColor.red
            diff = diff * -1
        } else {
            color = self.tintColor
        }
        self.differenceLabel.text = NumberFormatterManger.sharedInstance.cf.string(from: NSNumber(value: diff));
        self.differenceLabel.textColor = color
    }
    
}
