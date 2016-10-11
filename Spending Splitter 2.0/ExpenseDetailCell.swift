//
//  ExpenseDetailCell.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/13/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class ExpenseDetailCell: UITableViewCell {
    
    @IBOutlet weak var expenseName: UILabel!
    @IBOutlet weak var amountOwed: UILabel!
    @IBOutlet weak var amountSpent: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    func setupCell(expense: Expense) {
        self.expenseName.text = expense.memo
        self.amountOwed.text = NumberFormatterManger.sharedInstance.cf.string(from: NSNumber(value: expense.amountOwed!))
        self.amountSpent.text = NumberFormatterManger.sharedInstance.cf.string(from: expense.amount!)
        self.dateLabel.text = NumberFormatterManger.sharedInstance.df.string(from: expense.date! as Date)
    }
}
