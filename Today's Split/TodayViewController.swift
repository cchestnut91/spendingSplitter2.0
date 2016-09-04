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
                if let name = ExpenseManager.whoOwes() {
                    self.amountLabel.text = self.currencyFormatter!.string(from: amount!)
                    self.whoOwesLabel.text = name + " Owes"
                    self.amountLabel.isHidden = false
                    
                } else {
                    self.whoOwesLabel.text = "All Even"
                    self.amountLabel.isHidden = true
                }
                completionHandler(NCUpdateResult.newData)
            }
            
            },  onError: { (error) in
                completionHandler(NCUpdateResult.failed)
        })
    
    }
    
}
