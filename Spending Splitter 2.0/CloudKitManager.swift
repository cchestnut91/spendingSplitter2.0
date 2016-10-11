//
//  CloudKitManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitManager : NSObject {
    
    var expenses: [Expense]
    var recurringExpenses: [RecurringExpense]
    var categories: [ExpenseCategory]
    
    var calvinBudget: [CategoryBudget]
    var rosieBudget: [CategoryBudget]
    
    var calvinCategorySpending: [String: NSNumber];
    var rosieCategorySpending: [String: NSNumber];
    var sharedCategorySpending: [String: NSNumber];
    
    let publicDB: CKDatabase
    
    var calcBudget: Bool
    
    static let sharedInstance = CloudKitManager()
    
    override init() {
        
        self.publicDB = CKContainer.init(identifier: "iCloud.com.calvinchestnut.Spending-Splitter-2-0").publicCloudDatabase
        
        self.expenses = []
        self.recurringExpenses = []
        self.categories = []
        
        self.calvinBudget = []
        self.rosieBudget = []
        
        self.calvinCategorySpending = [:]
        self.rosieCategorySpending = [:]
        self.sharedCategorySpending = [:]
        
        calcBudget = true
        
        super.init()
    }
    
    class func add(expense: Expense, onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        let record = expense.createRecord()
        
        CloudKitManager.sharedInstance.publicDB.save(record) { (record, error) in
            if error == nil {
                if let recurringRecord = expense.recurringRecord() {
                    CloudKitManager.sharedInstance.publicDB.save(recurringRecord, completionHandler: { (savedRecurring, error) in
                        if error == nil {
                            onSuccess()
                        } else {
                            onError(error!)
                        }
                    })
                } else {
                    CloudKitManager.sharedInstance.expenses.append(expense)
                    CloudKitManager.sortExpenses()
                    onSuccess()
                }
            } else {
                onError(error!)
            }
        }
        
    }
    
    class func delete(expense: Expense, onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let recordID = CKRecordID.init(recordName: NSUUID().uuidString)
        let record = CKRecord.init(recordType: ExpenseKeys.deletedExpenseType, recordID: recordID)
        
        record.setValue(expense.expenseID, forKey: ExpenseKeys.expenseIDKey)
        
        CloudKitManager.sharedInstance.publicDB.save(record) { (record, error) in
            if error == nil {
                CloudKitManager.sharedInstance.expenses.remove(at: CloudKitManager.sharedInstance.expenses.index(of: expense)!)
                onSuccess()
            } else {
                onError(error!)
            }
        }
    }
    
    class func updateBudget(budget: CategoryBudget, onSuccess: @escaping () -> Void, onError: @escaping (Error) -> ()) {
        
        let operation = CKModifyRecordsOperation.init(recordsToSave: [budget.createRecord()], recordIDsToDelete: nil)
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                onError(error!)
            } else {
                onSuccess()
            }
        }
        CloudKitManager.sharedInstance.publicDB.add(operation)
    }
    
    class func loadCategories(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.categoryRecordType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                CloudKitManager.sharedInstance.categories = []
                for record in records! {
                    let category = ExpenseCategory(record: record)
                    CloudKitManager.sharedInstance.categories.append(category)
                }
                CloudKitManager.sharedInstance.categories.sort { $0.name < $1.name }
                CloudKitManager.loadBudgets(onSuccess: onSuccess, onError: onError)
            } else {
                onError(error!)
            }
        }
    }
    
    class func getCategories() -> [ExpenseCategory] {
        return CloudKitManager.sharedInstance.categories
    }
    
    class func loadBudgets(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.budgetRecordType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                CloudKitManager.sharedInstance.calvinBudget = []
                CloudKitManager.sharedInstance.rosieBudget = []
                
                var budgetedCategoriesCalvin = Set<String>()
                var budgetedCategoriesRosie = Set<String>()
                
                for record in records! {
                    let budget = CategoryBudget(record: record)
                    if budget.spender == Spender.calvin {
                        budgetedCategoriesCalvin.insert(budget.category)
                        CloudKitManager.sharedInstance.calvinBudget.append(budget)
                    } else {
                        budgetedCategoriesRosie.insert(budget.category)
                        CloudKitManager.sharedInstance.rosieBudget.append(budget)
                    }
                }
                
                var toAdd = [] as [CKRecord]
                let categories = CloudKitManager.getCategories()
                for category in categories {
                    let currentPerson = PersonManager.currentPerson()
                    if !budgetedCategoriesCalvin.contains(category.name) && currentPerson == Spender.calvin {
                        let newBudget = CategoryBudget(spender: Spender.calvin, category: category.name, budget: NSNumber(value: 0))
                        toAdd.append(newBudget.createRecord())
                        CloudKitManager.sharedInstance.calvinBudget.append(newBudget)
                    }
                    if !budgetedCategoriesRosie.contains(category.name) && currentPerson == Spender.rosie {
                        let newBudget = CategoryBudget(spender: Spender.rosie, category: category.name, budget: NSNumber(value: 0))
                        toAdd.append(newBudget.createRecord())
                        CloudKitManager.sharedInstance.rosieBudget.append(newBudget)
                    }
                }
                
                if toAdd.count > 0 {
                    let operation = CKModifyRecordsOperation.init(recordsToSave: toAdd, recordIDsToDelete: nil)
                    
                    operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
                        if error != nil {
                            onError(error!)
                        } else {
                            CloudKitManager.calculateSpentBudget(onSuccess: onSuccess, onError: onError)
                        }
                    }
                    
                    CloudKitManager.sharedInstance.publicDB.add(operation)
                } else {
                    CloudKitManager.calculateSpentBudget(onSuccess: onSuccess, onError: onError)
                }
                
            } else {
                onError(error!)
            }
        }
    }
    
    class func calculateSpentBudget(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        CloudKitManager.sharedInstance.calvinCategorySpending = [:]
        CloudKitManager.sharedInstance.rosieCategorySpending = [:]
        
        for category in CloudKitManager.getCategories() {
            let categoryString = category.name
            CloudKitManager.sharedInstance.calvinCategorySpending[categoryString] = NSNumber(value: 0.0)
            CloudKitManager.sharedInstance.rosieCategorySpending[categoryString] = NSNumber(value: 0.0)
        }
        
        for expense in CloudKitManager.sharedInstance.expenses {
            let category = expense.category!
            let amount = expense.amount!.doubleValue
            let owed = expense.amountOwed!
            if expense.spender == Spender.calvin {
                let savedNum = CloudKitManager.sharedInstance.calvinCategorySpending[category]! as NSNumber
                var alreadySpent = savedNum.doubleValue as Double
                alreadySpent += (amount - owed)
                CloudKitManager.sharedInstance.calvinCategorySpending[category] = NSNumber(value: alreadySpent)
            } else {
                let savedNum = CloudKitManager.sharedInstance.rosieCategorySpending[category]! as NSNumber
                var alreadySpent = savedNum.doubleValue as Double
                alreadySpent += (amount - owed)
                CloudKitManager.sharedInstance.rosieCategorySpending[category] = NSNumber(value: alreadySpent)
            }
        }
        
        for category in CloudKitManager.getCategories() {
            let categoryString = category.name
            let calvinNum = CloudKitManager.sharedInstance.calvinCategorySpending[categoryString]
            let rosieNum = CloudKitManager.sharedInstance.rosieCategorySpending[categoryString]
            
            let total = (calvinNum?.doubleValue)! + (rosieNum?.doubleValue)!
            CloudKitManager.sharedInstance.sharedCategorySpending[categoryString] = NSNumber(value: total)
        }
        
        onSuccess()
    }
    
    class func add(category: ExpenseCategory, onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let newRecord = category.createRecord()
        if CloudKitManager.sharedInstance.categories.index(of: category) == nil {
            CloudKitManager.sharedInstance.publicDB.save(newRecord) { (record, error) in
                if error == nil {
                    CloudKitManager.sharedInstance.categories.append(category)
                    CloudKitManager.sharedInstance.categories.sort { $0.name < $1.name }
                    onSuccess()
                } else {
                    onError(error!)
                }
            }
        } else {
            onSuccess()
        }
    }
    
    class func sortExpenses() {
        CloudKitManager.sharedInstance.expenses.sort(by: { $0.date?.compare($1.date as! Date) == ComparisonResult.orderedAscending })
    }
    
    class func updateExpenses(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.expenseRecordType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                let expenseRecords = records
                self.parseResults(records: expenseRecords!, onSuccess: onSuccess, onError: onError);
            } else {
                onError(error!)
            }
        }
        
    }
    
    class func parseResults(records: [CKRecord], onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        CloudKitManager.sharedInstance.expenses = []
        
        for record in records {
            let expense = Expense.init(record: record)
            CloudKitManager.sharedInstance.expenses.append(expense)
        }
        
        CloudKitManager.sortExpenses()
        
        self.checkRecurring(onSuccess: onSuccess, onError: onError)
    }
    
    class func checkRecurring(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.recurringExpenseType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                self.parseRecurringResults(records: records!, onSuccess: onSuccess, onError: onError);
            } else {
                onError(error!)
            }
        }
        
    }
    
    class func parseRecurringResults(records: [CKRecord], onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
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
            self.loadDeletedRecords(onSuccess: onSuccess, onError: onError)
        } else {
            self.addNewRecords(newRecords: newExpenses, onSuccess: onSuccess, onError: onError)
        }
    }
    
    class func addNewRecords(newRecords: [CKRecord], onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        let operation = CKModifyRecordsOperation.init(recordsToSave: newRecords, recordIDsToDelete: nil)
        
        operation.modifyRecordsCompletionBlock = { savedRecords, deletedRecordIDs, error in
            if error != nil {
                onError(error!)
            } else {
                
                self.loadDeletedRecords(onSuccess: onSuccess, onError: onError)
            }
        }
        
        CloudKitManager.sharedInstance.publicDB.add(operation)
        
    }
    
    class func loadDeletedRecords(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ExpenseKeys.deletedExpenseType, predicate: predicate)
        CloudKitManager.sharedInstance.publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if error == nil {
                self.parseDeletedRecords(records: records!, onSuccess: onSuccess, onError: onError)
            } else {
                onError(error!)
            }
        }
        
    }
    
    class func parseDeletedRecords(records: [CKRecord], onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        var recordsToDelete = [String]()
        
        for record in records {
            
            recordsToDelete.append(record.value(forKey: ExpenseKeys.expenseIDKey) as! String)

        }
        
        for expense in CloudKitManager.sharedInstance.expenses {
            
            if recordsToDelete.contains(expense.expenseID!) {
                CloudKitManager.sharedInstance.expenses.remove(at: CloudKitManager.sharedInstance.expenses.index(of: expense)!)
            }
            
        }
        
        self.wrapUp(onSuccess: onSuccess, onError: onError)
    }
    
    class func wrapUp(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
        
        CloudKitManager.sortExpenses()
        
        // TODO Does this make sense?
        if CloudKitManager.sharedInstance.calcBudget == false {
            onSuccess()
        } else {
            CloudKitManager.loadCategories(onSuccess: onSuccess, onError: onError)
        }
    }
    
    class func hasRegisteredSubscriptions() -> Bool! {
        if let bo = UserDefaults.standard.value(forKey: "RegisteredSubscriptions") as? Bool {
            return bo
        }
        return false
    }
    
    class func registerSubscriptions(onSuccess: @escaping () -> (), onError: @escaping (Error) -> ()) {
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
                        onSuccess()
                    } else {
                        onError(error!)
                    }
                })
            } else {
                onError(error!)
            }
        }
    }
    
}
