//
//  CloudKitManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitDelegate: class {
    
    func didFinishTask()
    func failedWithError(error: Error)
    
}

class CloudKitManager : NSObject {
    
    var delegate: CloudKitDelegate?
    
    var expenses: [Expense]
    var recurringExpenses: [RecurringExpense]
    var deletedExpensees: [DeletedExpense]
    
    let publicDB: CKDatabase
    
    static let sharedInstance = CloudKitManager()
    
    override init() {
        
        self.publicDB = CKContainer.default().publicCloudDatabase
        
        self.expenses = []
        self.recurringExpenses = []
        self.deletedExpensees = []
        
        super.init()
    }
    
    static func updateExpenses() {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.expenseRecordType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                let expenseRecords = records
                self.parseResults(records: expenseRecords!);
            } else {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
        
    }
    
    static func parseResults(records: [CKRecord]) {
        CloudKitManager.sharedInstance.expenses = []
        
        for record in records {
            let expense = Expense.init(record: record)
            CloudKitManager.sharedInstance.expenses.append(expense)
        }
        
        CloudKitManager.sharedInstance.expenses.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedAscending })
        
        self.checkRecurring()
    }
    
    static func checkRecurring() {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.recurringExpenseType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                self.parseRecurringResults(records: records!);
            } else {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
        
    }
    
    static func parseRecurringResults(records: [CKRecord]) {
        CloudKitManager.sharedInstance.expenses = []
        
        for record in records {
            let expense = RecurringExpense.init(record: record)
            CloudKitManager.sharedInstance.recurringExpenses.append(expense)
        }
        
        var newExpenses = [CKRecord]()
        
        var reversedExpenses = CloudKitManager.sharedInstance.expenses
        reversedExpenses.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedDescending })
        
        for recurringExpense in CloudKitManager.sharedInstance.recurringExpenses {
            
            let expenseID = recurringExpense.expenseID
            
            let index = reversedExpenses.index(where: { (expense) -> Bool in
                return expense.expenseID == expenseID
            })
            
            let lastExpense = reversedExpenses[index!]
            
            var components = DateComponents()
            
            if recurringExpense.interval == ExpenseKeys.intervalWeekly {
            
                components.setValue(1, for: Calendar.Component.weekOfYear)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalBiWeekly {
                
                components.setValue(2, for: Calendar.Component.weekOfYear)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalMonthly {
                
                components.setValue(1, for: Calendar.Component.month)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalYearly {
                
                components.setValue(1, for: Calendar.Component.year)
                
            }
            
            let calendar = Calendar.current
            
            let nextOccurance = calendar.date(byAdding: components, to: lastExpense.date as! Date)
            
            if nextOccurance?.compare(Date()) != ComparisonResult.orderedDescending {
                newExpenses.append(recurringExpense.generateNewRecord(date: nextOccurance!))
            }
            
            
        }
        
        if newExpenses.count == 0 {
            self.loadDeletedRecords()
        } else {
            self.addNewRecords(newExpenses)
        }
    }
    
    func addNewRecords(newRecords: [CKRecord]) {
        
    }
    
    func loadDeletedRecords() {
        
    }
    
}
