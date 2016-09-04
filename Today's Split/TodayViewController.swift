//
//  TodayViewController.swift
//  Today's Split
//
//  Created by Calvin Chestnut on 9/3/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var whoOwesLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var currencyFormatter: NumberFormatter?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view from its nib.
        
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter!.numberStyle = .currency
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: ((NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        CloudKitManager.updateExpenses(onSuccess: {
            DispatchQueue.main.async {
                let amount = ExpenseManager.amountOwedToDisplay()
                self.whoOwesLabel.isHidden = false
                var amountText: String
                var whoOwesText: String
                var amountHiddenState: Bool
                if let name = ExpenseManager.whoOwes() {
                    amountText = self.currencyFormatter!.string(from: amount!)!
                    whoOwesText = name + " Owes"
                    amountHiddenState = false
                    
                } else {
                    whoOwesText = "All Even"
                    amountText = ""
                    amountHiddenState = true
                }
                
                if let pastValue = UserDefaults.standard.value(forKey: "pastValue") as? NSNumber {
                    
                    if pastValue == ExpenseManager.amountOwed() {
                        self.amountLabel.text = amountText
                        self.whoOwesLabel.text = whoOwesText
                        self.amountLabel.isHidden = amountHiddenState
                        completionHandler(NCUpdateResult.noData)
                    } else {
                        self.amountLabel.text = amountText
                        self.whoOwesLabel.text = whoOwesText
                        self.amountLabel.isHidden = amountHiddenState
                        UserDefaults.standard.setValue(ExpenseManager.amountOwed(), forKey: "pastValue")
                        UserDefaults.standard.synchronize()
                        completionHandler(NCUpdateResult.newData)
                    }
                    
                } else {
                    self.amountLabel.text = amountText
                    self.whoOwesLabel.text = whoOwesText
                    self.amountLabel.isHidden = amountHiddenState
                    UserDefaults.standard.setValue(ExpenseManager.amountOwed(), forKey: "pastValue")
                    UserDefaults.standard.synchronize()
                    completionHandler(NCUpdateResult.newData)
                }
            }
            
            },  onError: { (error) in
                completionHandler(NCUpdateResult.failed)
        })
    
    }
    
}
