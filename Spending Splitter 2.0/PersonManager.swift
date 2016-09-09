//
//  PersonManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/7/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class PersonManager: NSObject {
    
    class func currentPerson() -> String! {
        
        return UserDefaults.standard.value(forKey: "ConfirmedPerson") as! String
    }
    
}
