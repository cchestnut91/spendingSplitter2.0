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

class SnapshotViewController: UIViewController, CloudKitDelegate {
    
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
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)]
        
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter!.numberStyle = .currency
        
        super.viewDidLoad()
        
        CloudKitManager.sharedInstance.delegate = self
        
        CloudKitManager.updateExpenses()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadLabels()
    }
    
    func didFinishTask() {
        // Stop spinner?
        self.infoView.isHidden = false
        self.loadingSpinner.stopAnimating()
        
        reloadLabels()
        
        if CloudKitManager.hasRegisteredSubscriptions() == false {
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            { (granted, error) in
                if granted == true{
                    CloudKitManager.registerSubscriptions()
                }
                if let error = error {
                    ErrorManager.present(error: error, onViewController: self)
                }
            }
            
        }
        
    }
    
    func failedWithError(error: Error) {
        ErrorManager.present(error: error, onViewController: self)
    }
    
    func reloadLabels() {
        
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

