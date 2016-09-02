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
    
    let publicDB: CKDatabase
    
    static let sharedInstance = CloudKitManager()
    
    override init() {
        
        self.publicDB = CKContainer.default().publicCloudDatabase
        
        self.expenses = []
        self.recurringExpenses = []
        
        super.init()
    }
    
    class func add(expense: Expense) {
        
        let record = expense.createRecord()
        
        CloudKitManager.sharedInstance.publicDB.save(record) { (record, error) in
            if error == nil {
                if let recurringRecord = expense.recurringRecord() {
                    CloudKitManager.sharedInstance.publicDB.save(recurringRecord, completionHandler: { (savedRecurring, error) in
                        if error == nil {
                            CloudKitManager.sharedInstance.delegate?.didFinishTask()
                        } else {
                            CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
                        }
                    })
                } else {
                    CloudKitManager.sharedInstance.expenses.append(expense)
                    CloudKitManager.sortExpenses()
                    CloudKitManager.sharedInstance.delegate?.didFinishTask()
                }
            } else {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
        
    }
    
    class func delete(expense: Expense) {
        let recordID = CKRecordID.init(recordName: NSUUID().uuidString)
        let record = CKRecord.init(recordType: ExpenseKeys.deletedExpenseType, recordID: recordID)
        
        record.setValue(expense.expenseID, forKey: ExpenseKeys.expenseIDKey)
        
        CloudKitManager.sharedInstance.publicDB.save(record) { (record, error) in
            if error != nil {
                CloudKitManager.sharedInstance.expenses.remove(at: CloudKitManager.sharedInstance.expenses.index(of: expense)!)
                CloudKitManager.sharedInstance.delegate?.didFinishTask()
            } else {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
    }
    
    class func sortExpenses() {
        CloudKitManager.sharedInstance.expenses.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedAscending })
    }
    
    class func updateExpenses() {
        
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
    
    class func parseResults(records: [CKRecord]) {
        CloudKitManager.sharedInstance.expenses = []
        
        for record in records {
            let expense = Expense.init(record: record)
            CloudKitManager.sharedInstance.expenses.append(expense)
        }
        
        CloudKitManager.sortExpenses()
        
        self.checkRecurring()
    }
    
    class func checkRecurring() {
        
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
    
    class func parseRecurringResults(records: [CKRecord]) {
        CloudKitManager.sharedInstance.recurringExpenses = []
        
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
            
            if recurringExpense.interval == ExpenseKeys.intervalDaily {
                
                components.setValue(1, for: Calendar.Component.day)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalWeekdays {
                
                components.setValue(1, for: Calendar.Component.weekday)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalWeekly {
                
                components.setValue(1, for: Calendar.Component.weekOfYear)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalBiWeekly {
                
                components.setValue(2, for: Calendar.Component.weekOfYear)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalMonthly {
                
                components.setValue(1, for: Calendar.Component.month)
                
            } else if recurringExpense.interval == ExpenseKeys.intervalYearly {
                
                components.setValue(1, for: Calendar.Component.year)
                
            }
            
            let calendar = Calendar.current
            
            var nextOccurance = calendar.date(byAdding: components, to: lastExpense.date as! Date)!
            
            while nextOccurance.compare(Date()) != ComparisonResult.orderedDescending {
                let newRecord = recurringExpense.generateNewRecord(date: nextOccurance)
                newExpenses.append(newRecord)
                CloudKitManager.sharedInstance.expenses.append(Expense.init(record: newRecord))
                nextOccurance = calendar.date(byAdding: components, to: nextOccurance)!
            }
            
        }
        
        CloudKitManager.sortExpenses()
        
        if newExpenses.count == 0 {
            self.loadDeletedRecords()
        } else {
            self.addNewRecords(newRecords: newExpenses)
        }
    }
    
    class func addNewRecords(newRecords: [CKRecord]) {
        let operation = CKModifyRecordsOperation.init(recordsToSave: newRecords, recordIDsToDelete: nil)
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            } else {
                
                self.loadDeletedRecords()
            }
        }
        
        CloudKitManager.sharedInstance.publicDB.add(operation)
        
    }
    
    class func loadDeletedRecords() {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.deletedExpenseType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                self.parseDeletedRecords(records: records!)
            } else {
                CloudKitManager.sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
        
    }
    
    class func parseDeletedRecords(records: [CKRecord]) {
        
        var recordsToDelete = [String]()
        
        for record in records {
            
            recordsToDelete.append(record.value(forKey: ExpenseKeys.expenseIDKey) as! String)

        }
        
        for expense in CloudKitManager.sharedInstance.expenses {
            
            if recordsToDelete.contains(expense.expenseID!) {
                CloudKitManager.sharedInstance.expenses.remove(at: CloudKitManager.sharedInstance.expenses.index(of: expense)!)
            }
            
        }
        
        self.wrapUp()
    }
    
    class func wrapUp() {
        
        CloudKitManager.sortExpenses()
        
        CloudKitManager.sharedInstance.delegate?.didFinishTask()
    }
    
    class func hasRegisteredSubscriptions() -> Bool! {
        if let bo = UserDefaults.standard.value(forKey: "RegisteredSubscriptions") as? Bool {
            return bo
        }
        return false
    }
    
    class func registerSubscriptions() {
        let predicate = NSPredicate(value: true)
        let newRecordSubscription = CKQuerySubscription(recordType: ExpenseKeys.expenseRecordType, predicate: predicate, options: CKQuerySubscriptionOptions.firesOnRecordCreation)
        let newRecordInfo = CKNotificationInfo()
        
        newRecordInfo.alertLocalizationKey = ExpenseKeys.newRecordNotificationKey
        
        newRecordSubscription.notificationInfo = newRecordInfo
        
        let deletedSubscription = CKQuerySubscription(recordType: ExpenseKeys.deletedExpenseType, predicate: predicate, options: CKQuerySubscriptionOptions.firesOnRecordCreation)
        let delRecordInfo = CKNotificationInfo()
        
        delRecordInfo.alertLocalizationKey = ExpenseKeys.delRecordNotificationKey
        
        deletedSubscription.notificationInfo = delRecordInfo
        
        sharedInstance.publicDB.save(newRecordSubscription) { (newSub, error) in
            if error == nil {
                sharedInstance.publicDB.save(deletedSubscription, completionHandler: { (delSub, delError) in
                    if error == nil {
                        UserDefaults.standard.set(true, forKey: "RegisteredSubscriptions")
                        UserDefaults.standard.synchronize()
                        sharedInstance.delegate?.didFinishTask()
                    } else {
                        sharedInstance.delegate?.failedWithError(error: delError!)
                    }
                })
            } else {
                sharedInstance.delegate?.failedWithError(error: error!)
            }
        }
    }
    
}
