//
//  CategoryManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation

class CategoryManager: NSObject {
    
    static let categoryKey = "Categories"
    
    class func categories() -> [String] {
        var categories = UserDefaults.standard.object(forKey: self.categoryKey) as? [String]
        
        if categories == nil {
            categories = CategoryManager.defaultCategories()
            categories?.sort { $0 < $1 }
            UserDefaults.standard.set(categories, forKey: self.categoryKey)
            UserDefaults.standard.synchronize()
        }
        
        return categories!
    }
    
    class func defaultCategories() -> [String] {
        return ["Groceries", "Rent", "Transportation", "Utilities", "Savings"]
    }
    
    class func addCategory(newCategory: String) {
        var categories = self.categories()
        if categories.index(of: newCategory) == nil {
            categories.append(newCategory)
        }
        categories.sort { $0 < $1 }
        UserDefaults.standard.set(categories, forKey: self.categoryKey)
    }
    
}
