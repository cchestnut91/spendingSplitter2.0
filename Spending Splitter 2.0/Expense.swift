//
//  Expense.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/30/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

class Expense : NSObject {
    
    var identifier : String!
    var expenseID : String!
    var amount : NSNumber?
    var date : NSDate?
    var memo : String?
    var percentageOwed : NSNumber?
    var amountOwed : Double?
    var category : String?
    var spender : String?
    var recurring : Bool?
    var interval : String?
    
    override init() {
        self.identifier = NSUUID().uuidString
        self.expenseID = NSUUID().uuidString
        self.date = Date() as NSDate
        
        super.init()
    }
    
    init( record : CKRecord) {
        
        self.identifier = record.recordID.recordName
        self.expenseID = record.value(forKey: ExpenseKeys.expenseIDKey) as? String
        self.amount = record.value(forKey: ExpenseKeys.expenseAmountKey) as? NSNumber
        self.date = record.value(forKey: ExpenseKeys.expenseDateKey) as? NSDate
        self.memo = record.value(forKey: ExpenseKeys.expenseMemoKey) as? String
        self.percentageOwed = record.value(forKey: ExpenseKeys.expensePercentageOwedKey) as? NSNumber
        self.category = record.value(forKey: ExpenseKeys.expenseCategoryKey) as? String
        self.spender = record.value(forKey: ExpenseKeys.expenseSpenderKey) as? String
        self.recurring = record.value(forKey: ExpenseKeys.expenseRecurringKey) as? Bool
        self.interval = record.value(forKey: ExpenseKeys.expenseIntervalKey) as? String
        
        super.init()
    }
   
    func createRecord() -> CKRecord {
        
        let recordID = CKRecordID.init(recordName:self.identifier!)
        let record = CKRecord.init(recordType: ExpenseKeys.expenseRecordType, recordID: recordID)
        record.setValue(self.expenseID, forKey: ExpenseKeys.expenseIDKey)
        record.setValue(self.amount, forKey:ExpenseKeys.expenseAmountKey)
        record.setValue(self.date, forKey: ExpenseKeys.expenseDateKey)
        record.setValue(self.category, forKey: ExpenseKeys.expenseCategoryKey)
        record.setValue(self.memo, forKey: ExpenseKeys.expenseMemoKey)
        record.setValue(self.percentageOwed, forKey: ExpenseKeys.expensePercentageOwedKey)
        record.setValue(self.spender, forKey: ExpenseKeys.expenseSpenderKey)
        record.setValue(NSNumber.init(value: self.recurring!), forKey: ExpenseKeys.expenseRecurringKey)
        if (self.recurring)! {
            record.setValue(self.interval, forKey: ExpenseKeys.expenseIntervalKey)
        }
        
        return record;
    }
    
    func recurringRecord() -> CKRecord? {
        if (!self.recurring!) {
            return nil
        }
        let recordID = CKRecordID.init(recordName: self.identifier! + "Recurring")
        let record = CKRecord.init(recordType: ExpenseKeys.recurringExpenseType, recordID: recordID)
        record.setValue(self.expenseID, forKey: ExpenseKeys.expenseIDKey)
        record.setValue(self.amount, forKey: ExpenseKeys.expenseAmountKey)
        record.setValue(self.category, forKey: ExpenseKeys.expenseCategoryKey)
        record.setValue(self.memo, forKey: ExpenseKeys.expenseMemoKey)
        record.setValue(self.percentageOwed, forKey: ExpenseKeys.expensePercentageOwedKey)
        record.setValue(self.spender, forKey: ExpenseKeys.expenseSpenderKey)
        record.setValue(self.interval, forKey: ExpenseKeys.expenseIntervalKey)
        
        return record;
    }
    
    func validate() -> String? {
        
        if self.identifier == nil {
            return "Identifier is missing"
        }
        if self.expenseID == nil {
            return "ExpenseID is missing"
        }
        if self.amount == nil {
            return "Amount is missing"
        }
        if self.amount == 0.0 {
            return "Amount cannot be empty"
        }
        if self.date == nil {
            return "Date is missing"
        }
        if self.memo?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == "" {
            return "Memo is empty or invalid"
        }
        if self.percentageOwed == nil && self.amountOwed == nil {
            return "Amount Owed is empty"
        }
        if self.amountOwed != nil && self.percentageOwed == nil {
            self.percentageOwed = NSNumber.init(value: (self.amount?.doubleValue.divided(by: self.amountOwed!))!)
        }
        if self.percentageOwed!.doubleValue < 0.0 || self.percentageOwed!.doubleValue > 1 {
            return "Percentage owed is invalid"
        }
        if self.category == nil || category == "" {
            return "Category is missing"
        }
        if self.spender == nil {
            return "Spender is missing"
        }
        if self.recurring! && self.interval == nil {
            return "Interval not specified"
        }
        
        return nil
    }
    
}
