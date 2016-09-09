//
//  ErrorManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/1/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class ErrorManager: NSObject {
    
    class func present(error: Error, onViewController: UIViewController) {
        // Shop and show error
        DispatchQueue.main.async {
            let errorAlert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            errorAlert.addAction(okAction)
            print(error.localizedDescription)
            onViewController.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    class func confirm(person: String, fromController: UIViewController, onVerified: @escaping () -> ()) {
        
        if UserDefaults.standard.value(forKey: "ConfirmedPerson") as! String == "" {
            let confirmPersonAlert = UIAlertController(title: "Who Are You?", message: "Before you can get started, we need to know who you are.", preferredStyle: UIAlertControllerStyle.alert)
            let calvinAction = UIAlertAction(title: "Calvin", style: UIAlertActionStyle.default, handler: { (alert) in
                UserDefaults.standard.setValue(Spender.calvin, forKey: "ConfirmedPerson")
                UserDefaults.standard.synchronize()
                if person == Spender.calvin {
                    onVerified()
                }
            })
            let rosieAction = UIAlertAction(title: "Rosie", style: UIAlertActionStyle.default, handler: { (alert) in
                UserDefaults.standard.setValue(Spender.rosie, forKey: "ConfirmedPerson")
                UserDefaults.standard.synchronize()
                if person == Spender.rosie {
                    onVerified()
                }
            })
            confirmPersonAlert.addAction(calvinAction)
            confirmPersonAlert.addAction(rosieAction)
            
            fromController.present(confirmPersonAlert, animated: true, completion: nil)
        } else if UserDefaults.standard.value(forKey: "ConfirmedPerson") as? String == person {
            onVerified()
        } else {
            fromController.present(ErrorManager.wrongPersonAlert(), animated: true, completion: nil)
        }
    }
    
    class func wrongPersonAlert() -> UIAlertController {
        let wrongPersonAlert = UIAlertController(title: "Action Not Allowed", message: "You are not allowed to make these changes, have the other person make them instead", preferredStyle: UIAlertControllerStyle.alert)
        let okAction = ErrorManager.okAction()
        wrongPersonAlert.addAction(okAction)
        
        return wrongPersonAlert
    }
    
    class func okAction() -> UIAlertAction {
        return UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    }
    
    class func cancelAction() -> UIAlertAction {
        return UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    }
    
}
