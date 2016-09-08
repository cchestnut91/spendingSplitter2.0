//
//  PersonManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/7/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class PersonManager: NSObject {
    
    class func confirm(person: String, fromController: UIViewController, onVerified: @escaping () -> ()) {
        if UserDefaults.standard.value(forKey: "ConfirmedPerson") == nil {
            let confirmPersonAlert = UIAlertController(title: "Are You " + person == Spender.calvin ? "Calvin?" : "Rosie?", message: "If you tap the wrong button or lie here it's very possible that all sorts of stuff will start to break, so be sure.", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.default, handler: { (alert) in
                UserDefaults.standard.setValue(person, forKey: "ConfirmedPerson")
                UserDefaults.standard.synchronize()
                onVerified()
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            confirmPersonAlert.addAction(confirmAction)
            confirmPersonAlert.addAction(cancelAction)
            
            fromController.present(confirmPersonAlert, animated: true, completion: nil)
        } else if UserDefaults.standard.value(forKey: "ConfirmedPerson") as? String == person {
            onVerified()
        } else {
            fromController.present(PersonManager.wrongPersonAlert(), animated: true, completion: nil)
        }
    }
    
    class func wrongPersonAlert() -> UIAlertController {
        let wrongPersonAlert = UIAlertController(title: "Action Not Allowed", message: "You are not allowed to make these changes, have the other person make them instead", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = ErrorManager.okAction()
        wrongPersonAlert.addAction(okAction)
        
        return wrongPersonAlert
    }
    
}
