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
        let errorAlert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        errorAlert.addAction(okAction)
        print(error.localizedDescription)
        onViewController.present(errorAlert, animated: true, completion: nil)
    }
    
    class func okAction() -> UIAlertAction {
        return UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    }
    
    class func cancelAction() -> UIAlertAction {
        return UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
    }
    
}
