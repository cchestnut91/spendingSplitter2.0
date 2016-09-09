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

    @IBOutlet weak var whoOwesLabel: UILabel!
    @IBOutlet weak var amountOwedLabel: UILabel!
    @IBOutlet weak var calvinBudgetStatusLabel: UILabel!
    @IBOutlet weak var rosieBudgetStatusLabel: UILabel!
    
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var budgetButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkPerson()
    }
    
    func checkPerson() {
        if UserDefaults.standard.value(forKey: "ConfirmedPerson") as! String == "" {
            ErrorManager.confirm(person: Spender.calvin, fromController: self, onVerified: { 
                self.loadData()
            })
        } else {
            loadData()
        }
    }
    
    func loadData() {
        
        LoadingAlertManager.showLoadingAlertWith(title: "Calculating Expenses & Budget", message: "Please wait" , from: self)
        
        CloudKitManager.updateExpenses(onSuccess: {
            
            self.reloadLabels()
            self.loadSubscriptions()
            
            if QuickActionManager.sharedInstance.shortcut != nil {
                self.handle(shortcut: QuickActionManager.sharedInstance.shortcut!)
                QuickActionManager.sharedInstance.shortcut = nil
            }
            
            }, onError: {(error) in
                LoadingAlertManager.removeLoadingView(withCompletion: {
                    ErrorManager.present(error: error, onViewController: self)
                })
        })
    }
    
    
    func handle(shortcut: UIApplicationShortcutItem) {
        if shortcut.type == QuickActionManager.addExpenseShortcutType {
            self.performSegue(withIdentifier: "addExpenseSegue", sender: self)
            
        } else {
            // other actions?
        }
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
    
    func failedWithError(error: Error) {
        ErrorManager.present(error: error, onViewController: self)
    }
    
    func reloadLabels() {
        
        DispatchQueue.main.async {
            LoadingAlertManager.removeLoadingView(withCompletion: {
                self.infoView.isHidden = false
                let amtOwed = ExpenseManager.amountOwedToDisplay()!
                
                if let whoOwes = ExpenseManager.whoOwes() {
                    self.whoOwesLabel.text = whoOwes + " Owes"
                    self.amountOwedLabel.text = NumberFormatterManger.sharedInstance.cf.string(from: amtOwed)
                    self.amountOwedLabel.isHidden = false
                } else {
                    self.whoOwesLabel.text = "All Even"
                    self.amountOwedLabel.isHidden = true
                }
            })
        }
    }

}

