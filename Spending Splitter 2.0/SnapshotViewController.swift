//
//  SnapshotViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/30/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit
import CloudKit

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
        
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter!.numberStyle = .currency
        
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        CloudKitManager.sharedInstance.delegate = self
        
        // animate spinner
        
        CloudKitManager.updateExpenses()
    }
    
    @IBAction func addExpenseTapped(_ sender: AnyObject) {
        
        // Show add expense vc
    }
    
    func didFinishTask() {
        // Stop spinner?
        self.infoView.isHidden = false
        self.loadingSpinner.stopAnimating()
        
        let amtOwed = ExpenseManager.amountOwed()!
        
        if let whoOwes = ExpenseManager.whoOwes() {
            self.whoOwesLabel.text = whoOwes + " Owes"
            self.amountOwedLabel.text = self.currencyFormatter!.string(from: amtOwed)
            self.amountOwedLabel.isHidden = false
        } else {
            self.whoOwesLabel.text = "All Even"
            self.amountOwedLabel.isHidden = true
        }
        
    }
    
    func failedWithError(error: Error) {
        self.showError(error: error)
    }
    
    func showError(error:Error) {
        // Shop and show error
        let errorAlert = UIAlertController.init(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
        errorAlert.addAction(okAction)
        print(error.localizedDescription)
        self.present(errorAlert, animated: true, completion: nil)
    }


}

