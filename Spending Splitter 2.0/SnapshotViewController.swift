//
//  SnapshotViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/30/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit
import CloudKit
import UserNotifications

class SnapshotViewController: UIViewController {
    
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var loadingSpinner: UIActivityIndicatorView!

    @IBOutlet weak var whoOwesLabel: UILabel!
    @IBOutlet weak var amountOwedLabel: UILabel!
    @IBOutlet weak var calvinBudgetStatusLabel: UILabel!
    @IBOutlet weak var rosieBudgetStatusLabel: UILabel!
    
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var budgetButton: UIButton!
    
    var currencyFormatter: NumberFormatter?
    
    override func viewDidLoad() {
        
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter!.numberStyle = .currency
        
        super.viewDidLoad()
        
        CloudKitManager.updateExpenses(onSuccess: { 
            self.infoView.isHidden = false
            self.loadingSpinner.stopAnimating()
            
            self.reloadLabels()
            self.loadSubscriptions()
            
            }, onError: {(error) in
                ErrorManager.present(error: error, onViewController: self)
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadLabels()
    }
    
    func loadSubscriptions() {
        
        CloudKitManager.sharedInstance.publicDB.fetchAllSubscriptions { (subscriptions, error) in
            if error == nil {
                if subscriptions?.count == 0 {
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
                    { (granted, reqError) in
                        if granted == true{
                            CloudKitManager.registerSubscriptions(onSuccess: {
                                NSLog("Success")
                                }, onError: { (registerError) in
                                    ErrorManager.present(error: registerError, onViewController: self)
                            })
                        }
                        if let reqestError = reqError {
                            ErrorManager.present(error: reqestError, onViewController: self)
                        }
                    }
                }
            } else {
                ErrorManager.present(error: error!, onViewController: self)
            }
        }
    }
    
    func didFinishTask() {
        // Stop spinner?
        self.infoView.isHidden = false
        self.loadingSpinner.stopAnimating()
        
        reloadLabels()
    }
    
    func failedWithError(error: Error) {
        ErrorManager.present(error: error, onViewController: self)
    }
    
    func reloadLabels() {
        
        DispatchQueue.main.async {
            let amtOwed = ExpenseManager.amountOwedToDisplay()!
            
            if let whoOwes = ExpenseManager.whoOwes() {
                self.whoOwesLabel.text = whoOwes + " Owes"
                self.amountOwedLabel.text = self.currencyFormatter!.string(from: amtOwed)
                self.amountOwedLabel.isHidden = false
            } else {
                self.whoOwesLabel.text = "All Even"
                self.amountOwedLabel.isHidden = true
            }
        }
    }

}

