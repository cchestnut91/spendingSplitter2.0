//
//  NumberFormatterManger.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/8/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import Foundation

class NumberFormatterManger: NSObject {
    
    static let sharedInstance = NumberFormatterManger()
    
    var cf: NumberFormatter!
    
    var df: DateFormatter!
    
    override init() {
        self.cf = NumberFormatter()
        self.cf.numberStyle = .currency
        
        self.df = DateFormatter()
        self.df.dateStyle = DateFormatter.Style.short
        
        super.init()
    }
    
    func currency() -> NumberFormatter {
        return NumberFormatterManger.sharedInstance.cf
    }
    
}
