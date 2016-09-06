//
//  LoadingAlertManager.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 9/6/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class LoadingAlertManager: NSObject {
    
    var loadingAlert: UIAlertController?
    
    static let sharedInstance = LoadingAlertManager()
    
    override init() {
        super.init()
    }
    
    class func showLoadingAlertWith(title: String, message: String, from: UIViewController) {
        LoadingAlertManager.sharedInstance.loadingAlert = UIAlertController.init(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        from.present(LoadingAlertManager.sharedInstance.loadingAlert!, animated: true, completion: nil)
    }
    
    class func removeLoadingView(withCompletion: @escaping () -> ()) {
        if LoadingAlertManager.sharedInstance.loadingAlert != nil {
            LoadingAlertManager.sharedInstance.loadingAlert!.dismiss(animated: true) {
                LoadingAlertManager.sharedInstance.loadingAlert = nil
                DispatchQueue.main.async(execute: { 
                    withCompletion()
                })
            }
        } else {
            withCompletion()
        }
    }
}
