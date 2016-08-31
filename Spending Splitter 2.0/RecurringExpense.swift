//
//  RecurringExpense.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

class RecurringExpense : NSObject {
    
    var identifier : String?
    var expenseID : String?
    var amount : NSNumber?
    var memo : String?
    var percentageOwed : NSNumber?
    var category : String?
    var spender : String?
    var interval : String?
    
    override init() {
        super.init()
    }
    
    init( record : CKRecord) {
        
        self.identifier = record.recordID.recordName
        self.expenseID = record.value(forKey: ExpenseKeys.expenseIDKey) as? String
        self.amount = record.value(forKey: ExpenseKeys.expenseAmountKey) as? NSNumber
        self.memo = record.value(forKey: ExpenseKeys.expenseMemoKey) as? String
        self.percentageOwed = record.value(forKey: ExpenseKeys.expensePercentageOwedKey) as? NSNumber
        self.category = record.value(forKey: ExpenseKeys.expenseCategoryKey) as? String
        self.spender = record.value(forKey: ExpenseKeys.expenseSpenderKey) as? String
        self.interval = record.value(forKey: ExpenseKeys.expenseIntervalKey) as? String
        
        super.init()
    }
    
    func generateNewRecord(date: Date) -> CKRecord  {
        
        let recordID = CKRecordID.init(recordName: NSUUID().uuidString)
        let record = CKRecord.init(recordType: ExpenseKeys.expenseRecordType, recordID: recordID)
        record.setValue(self.expenseID, forKey: ExpenseKeys.expenseIDKey)
        record.setValue(self.amount, forKey:ExpenseKeys.expenseAmountKey)
        record.setValue(date, forKey: ExpenseKeys.expenseDateKey)
        record.setValue(self.category, forKey: ExpenseKeys.expenseCategoryKey)
        record.setValue(self.memo, forKey: ExpenseKeys.expenseMemoKey)
        record.setValue(self.percentageOwed, forKey: ExpenseKeys.expensePercentageOwedKey)
        record.setValue(self.spender, forKey: ExpenseKeys.expenseSpenderKey)
        record.setValue(NSNumber.init(value: true), forKey: ExpenseKeys.expenseRecurringKey)
        record.setValue(self.interval, forKey: ExpenseKeys.expenseIntervalKey)
        
        return record;
    }
    
}
