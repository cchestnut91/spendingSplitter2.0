//
//  QuickActionManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/4/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class QuickActionManager: NSObject {
    
    var shortcut: UIApplicationShortcutItem?
    
    static let sharedInstance = QuickActionManager()
    
    static let addExpenseShortcutType = "com.calvinchestnut.Spending-Splitter-2-0.addExpense"
    
    override init() {
        super.init()
    }
    
}
