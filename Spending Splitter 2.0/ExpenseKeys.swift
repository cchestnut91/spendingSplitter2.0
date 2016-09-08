//
//  ExpenseKeys.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/30/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation

class ExpenseKeys : NSObject {
    
    static let expenseRecordType = "Expense"
    static let recurringExpenseType = "Recurring"
    static let deletedExpenseType = "Deleted"
    static let categoryRecordType = "Category"
    static let budgetRecordType = "Budget"
    
    static let expenseAmountKey = "kExpenseAmount"
    static let expenseIDKey = "kExpenseID"
    static let expenseDateKey = "kExpenseDate"
    static let expenseMemoKey = "kExpenseMemo"
    static let expensePercentageOwedKey = "kExpenseOwed"
    static let expenseCategoryKey = "kExpenseCategory"
    static let expenseSpenderKey = "kExpenseSpender"
    static let expenseRecurringKey = "kExpenseRecurring"
    static let expenseIntervalKey = "kExpenseInterval"
    
    static let intervalDaily = "Daily"
    static let intervalWeekdays = "Weekdays"
    static let intervalWeekly = "Weekly"
    static let intervalBiWeekly = "Biweekly"
    static let intervalMonthly = "Monthly"
    static let intervalYearly = "Yearly"
    
    static let categoryName = "name"
    static let categoryCreated = "created"
    
    static let budgetAmount = "kBudgetAmount"
    static let budgetCategory = "kBudgetCategory"
    static let budgetSpender = "kBudgetSpender"
    
    static let newRecordNotificationKey = "kNotificationNewRecord"
    static let delRecordNotificationKey = "kNotificationDeletedRecord"
    
}
