//
//  CategoryBudget.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/7/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

class CategoryBudget: NSObject {
    
    var category: String!
    var budget: NSNumber!
    
    var spender: String!
    var ident: String!
    
    init(spender: String, category: String, budget: NSNumber) {
        self.category = category
        self.budget = budget
        self.spender = spender
        
        self.ident = UUID().uuidString
        
        super.init()
    }
    
    init(record: CKRecord) {
        self.category = record.value(forKey: ExpenseKeys.budgetCategory) as! String
        self.budget = record.value(forKey: ExpenseKeys.budgetAmount) as! NSNumber
        self.spender = record.value(forKey: ExpenseKeys.budgetSpender) as! String
        
        self.ident = record.recordID.recordName
        
        super.init()
    }
    
    func createRecord() -> CKRecord {
        let recordID = CKRecordID(recordName: self.ident)
        let record = CKRecord(recordType: ExpenseKeys.budgetRecordType, recordID: recordID)
        
        record.setValue(self.category, forKey: ExpenseKeys.budgetCategory)
        record.setValue(self.budget, forKey: ExpenseKeys.budgetAmount)
        record.setValue(self.spender, forKey: ExpenseKeys.budgetSpender)
        
        return record
    }
    
}
