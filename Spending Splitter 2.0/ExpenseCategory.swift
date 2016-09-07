//
//  ExpenseCategory.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/7/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation
import CloudKit

class ExpenseCategory: NSObject {
    
    var name: String
    var created: Date
    
    var ident: String
    
    override init() {
        self.name = ""
        self.created = Date()
        self.ident = UUID().uuidString
        
        super.init()
    }
    
    init(name: String) {
        self.name = name
        self.created = Date()
        self.ident = UUID().uuidString
        
        super.init()
    }
    
    init(record: CKRecord) {
        self.name = record.value(forKey: ExpenseKeys.categoryName) as! String
        self.created = record.value(forKey: ExpenseKeys.categoryCreated) as! Date
        self.ident = record.recordID.recordName
        
        super.init()
    }
    
    func createRecord() -> CKRecord {
        let recordID = CKRecordID(recordName: self.ident)
        let record = CKRecord(recordType: ExpenseKeys.categoryRecordType, recordID: recordID)
        
        record.setValue(self.name, forKey: ExpenseKeys.categoryName)
        record.setValue(self.created, forKey: ExpenseKeys.categoryCreated)
        
        return record
    }
    
}
