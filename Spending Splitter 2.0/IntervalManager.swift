//
//  IntervalManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation

class IntervalManager: NSObject {
    
    class func intervals() -> [String]! {
        return [ExpenseKeys.intervalWeekly, ExpenseKeys.intervalBiWeekly, ExpenseKeys.intervalMonthly, ExpenseKeys.intervalYearly]
    }
    
}
