//
//  SnapshotViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/30/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit
import CloudKit

class SnapshotViewController: UIViewController {

    @IBOutlet weak var whoOwesLabel: UILabel!
    @IBOutlet weak var amountOwedLabel: UILabel!
    @IBOutlet weak var calvinBudgetStatusLabel: UILabel!
    @IBOutlet weak var rosieBudgetStatusLabel: UILabel!
    
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var budgetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadResults()
    }
    
    @IBAction func addExpenseTapped(_ sender: AnyObject) {
        
        let publicDB = CKContainer.default().publicCloudDatabase
        let recordID = CKRecordID.init(recordName:NSUUID.init().uuidString)
        let record = CKRecord.init(recordType: ExpenseKeys.expenseRecordType, recordID: recordID)
        record.setValue(NSNumber.init(value: 56.00), forKey:ExpenseKeys.expenseAmountKey)
        record.setValue(NSDate.init(), forKey: ExpenseKeys.expenseDateKey)
        record.setValue("Groceries", forKey: ExpenseKeys.expenseCategoryKey)
        record.setValue("Burgers", forKey: ExpenseKeys.expenseMemoKey)
        record.setValue(NSNumber.init(value: 0.5), forKey: ExpenseKeys.expensePercentageOwedKey)
        record.setValue(Spender.calvin, forKey: ExpenseKeys.expenseSpenderKey)
        
        publicDB.save(record) { (record, error) in
            if error != nil {
                self.showError(error: error!)
            } else {
                self.loadResults()
            }
        }
    }
    
    func loadResults() {
        let publicDB = CKContainer.default().publicCloudDatabase
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.expenseRecordType, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                let expenseRecords = records
                self.parseResults(results: expenseRecords!);
            } else {
                self.showError(error: error!)
            }
        }
    }
    
    func parseResults(results:[CKRecord]) {
        let userRecordID = results.first?.creatorUserRecordID
        print(userRecordID?.recordName)
    }
    
    func showError(error:Error) {
        // Shop and show error
        let errorAlert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        errorAlert.addAction(okAction)
        print(error.localizedDescription)
        self.present(errorAlert, animated: true, completion: nil)
    }


}

