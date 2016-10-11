//
//  CategoryDetailsTableViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/13/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class CategoryDetailsTableViewController: UITableViewController
{
    
    let category: String? = nil
    let expenses: [Expense]? = nil
    
    override func viewDidLoad() {
        self.title = self.category!
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.expenses?.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "expenseCell") as! ExpenseDetailCell
        
        cell.setupCell(expense: self.expenses![indexPath.row])
        
        return cell
    }
    
}
