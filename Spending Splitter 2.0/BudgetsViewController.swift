//
//  BudgetsViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/8/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class BudgetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSourcevar    
    @IBOutlet weak var personControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var initialSelection: NSNumber?
    
    var currentDictionary: [String: NSNumber]?
    var dictionaryKeys: [String]?
    
    override func viewDidLoad() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.currentDictionary = CloudKitManager.sharedInstance.calvinCategorySpending
        self.dictionaryKeys = Array(self.currentDictionary!.keys)
        
        self.personControl.selectedSegmentIndex = initialSelection!.intValue
        
        super.viewDidLoad()
    }
    
    @IBAction func selectedValueChanged(_ sender: AnyObject) {
        switch self.personControl.selectedSegmentIndex {
        case 0:
            self.currentDictionary = CloudKitManager.sharedInstance.calvinCategorySpending
            break
        case 1:
            self.currentDictionary = CloudKitManager.sharedInstance.rosieCategorySpending
            break
        case 2:
            self.currentDictionary = CloudKitManager.sharedInstance.sharedCategorySpending
            break
        default:
            break
        }
        self.tableView.reloadData()
        self.tableView.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
    }
    
    @IBAction func closeTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentDictionary?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "budgetCell") as! BudgetTableViewCell
        let key = self.dictionaryKeys?[indexPath.row]
        let totalSpent = (self.currentDictionary?[key!])!
        var totalBudget: Double = 0
        
        if self.personControl.selectedSegmentIndex == 0 {
            totalBudget = (CloudKitManager.sharedInstance.calvinBudget.filter({ (categoryBudget) -> Bool in
                return categoryBudget.category == key
            }).first?.budget.doubleValue)!
        } else if self.personControl.selectedSegmentIndex == 1 {
            totalBudget = (CloudKitManager.sharedInstance.rosieBudget.filter({ (categoryBudget) -> Bool in
                return categoryBudget.category == key
            }).first?.budget.doubleValue)!
        } else {
            let a = (CloudKitManager.sharedInstance.calvinBudget.filter({ (categoryBudget) -> Bool in
                return categoryBudget.category == key
            }).first?.budget.doubleValue)!
            let b = (CloudKitManager.sharedInstance.rosieBudget.filter({ (categoryBudget) -> Bool in
                return categoryBudget.category == key
            }).first?.budget.doubleValue)!
            totalBudget = a + b
        }
        
        cell.configureFor(category: key!, budget: NSNumber(value: totalBudget), andAmount: totalSpent)
        
        // Set category on cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction.init(style: UITableViewRowActionStyle.normal, title: "Change Budget", handler: { (rowAction, indexPath) in
            let changeAlert = UIAlertController(title: "Change Budget", message: "Update your budget for this category", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = ErrorManager.cancelAction()
            let saveAction = UIAlertAction(title: "Save", style: UIAlertActionStyle.default, handler: { (alertAction) in
                let text = changeAlert.textFields?.first?.text
                let doubleValue = Double(text!)
                let key = self.dictionaryKeys?[indexPath.row]
                var budget: CategoryBudget
                if self.personControl.selectedSegmentIndex == 0 {
                    budget = CloudKitManager.sharedInstance.calvinBudget.filter({ (categoryBudget) -> Bool in
                        return categoryBudget.category == key
                    }).first!
                } else {
                    budget = CloudKitManager.sharedInstance.rosieBudget.filter({ (categoryBudget) -> Bool in
                        return categoryBudget.category == key
                    }).first!
                }
                budget.budget = NSNumber(value: doubleValue!)
                CloudKitManager.updateBudget(budget: budget, onSuccess: {
                        self.tableView.reloadData()
                    }, onError: { (error) in
                        ErrorManager.present(error: error, onViewController: self)
                })
            })
            changeAlert.addTextField(configurationHandler: { (textField) in
                textField.placeholder = "New Budget"
                textField.keyboardType = UIKeyboardType.decimalPad
            })
            changeAlert.addAction(cancelAction)
            changeAlert.addAction(saveAction)
            self.present(changeAlert, animated: true, completion: nil)
        })
        
        if self.personControl.selectedSegmentIndex == 0 {
            if (PersonManager.currentPerson() == Spender.calvin) {
                return [editAction]
            }
        } else if self.personControl.selectedSegmentIndex == 1 {
            if (PersonManager.currentPerson() == Spender.rosie) {
                return [editAction]
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.personControl.selectedSegmentIndex != 2 {
            self.performSegue(withIdentifier: "showExpenses", sender: indexPath)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showExpenses" {
            let indexPath = sender as! IndexPath
            let key = self.dictionaryKeys?[indexPath.row]
            let person = self.personControl.selectedSegmentIndex == 0 ? Spender.calvin : Spender.rosie
            let expenses = CloudKitManager.sharedInstance.expenses.filter({ (expense) -> Bool in
                return expense.spender == person
            })
            
            let detailsController = segue.destination as! CategoryDetailsTableViewController
            detailsController.category = key
            detailsController.expenses = expenses
        }
    }
    
}
