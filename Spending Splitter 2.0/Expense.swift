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
    
    var identifier : String?
    var amount : NSNumber?
    var date : NSDate?
    var memo : String?
    var percentageOwed : NSNumber?
    var category : String?
    var spender : String?
    var recurring : Bool?
    var interval : String?
    
    override init() {
        super.init()
    }
    
    init( record : CKRecord) {
        
        self.identifier = record.recordID.recordName
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
    }
    
}
