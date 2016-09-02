//
//  ExpenseManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation

class ExpenseManager {
    
    class func amountOwed() -> NSNumber! {
        
        var owed = 0.0
        
        for expense in CloudKitManager.sharedInstance.expenses {
            var amount = expense.amount!.doubleValue * expense.percentageOwed!.doubleValue
            if expense.spender == Spender.calvin {
                amount = amount * -1.0
            }
            
            owed += amount
        }
        
        return NSNumber.init(value: owed)
        
    }
    
    class func amountOwedToDisplay() -> NSNumber! {
        return NSNumber.init(value: abs(ExpenseManager.amountOwed().doubleValue))
    }
    
    class func whoOwes() -> String? {
        
        let amt = self.amountOwed().doubleValue
        
        if amt > 0.0 {
            return Spender.calvin
        } else if amt < 0.0 {
            return Spender.rosie
        }
        return nil
        
    }
    
}
