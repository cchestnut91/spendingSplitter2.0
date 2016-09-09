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
    
    override init() {
        self.cf = NumberFormatter()
        self.cf.numberStyle = .currency
    }
    
    func currency() -> NumberFormatter {
        return NumberFormatterManger.sharedInstance.cf
    }
    
}
