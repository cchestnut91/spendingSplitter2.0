//
//  AddExpenseViewController.swift
//  Spending Splitter 2.0
//
//  Created by Calvin Chestnut on 8/31/16.
//  Copyright © 2016 Calvin Chestnut. All rights reserved.
//

import UIKit

class AddExpenseViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, CloudKitDelegate {
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var personPicker: UISegmentedControl!
    @IBOutlet weak var amountField: UITextField!
    @IBOutlet weak var memoField: UITextField!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var owedSlider: UISlider!
    @IBOutlet weak var owedLabel: UILabel!
    @IBOutlet weak var intervalPicker: UIPickerView!
    
    var hasEdited: Bool?
    var newExpense: Expense?
    
    var nf: NumberFormatter?
    var currencyFormatter: NumberFormatter?
    
    var savingAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nf = NumberFormatter()
        self.nf!.numberStyle = .percent
        
        self.currencyFormatter = NumberFormatter()
        self.currencyFormatter!.numberStyle = .currency
        
        self.newExpense = Expense()
        self.newExpense?.spender = Spender.calvin
        self.newExpense?.percentageOwed = 0.0 as NSNumber
        self.newExpense?.recurring = false
        
        self.hasEdited = false
        
        self.personPicker.addTarget(self, action: #selector(AddExpenseViewController.selectedPersonChanged), for: UIControlEvents.valueChanged)
        
        self.amountField.delegate = self
        self.memoField.delegate = self
        
        self.categoryPicker.delegate = self
        self.categoryPicker.dataSource = self
        
        self.datePicker.addTarget(self, action: #selector(AddExpenseViewController.dateChanged), for: UIControlEvents.valueChanged)
        
        self.owedSlider.addTarget(self, action: #selector(AddExpenseViewController.owedSliderChanged(sender:)), for: UIControlEvents.valueChanged)
        
        self.owedSliderChanged(sender: self.owedSlider)
        
        self.intervalPicker.delegate = self
        self.intervalPicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func cancelTapped(_ sender: AnyObject) {
        if self.hasEdited! {
            let confirmAlert = UIAlertController.init(title: "Are You Sure?", message: "You will lose whatever you entered on this screen", preferredStyle: UIAlertControllerStyle.alert)
            let confirmAction = UIAlertAction.init(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            })
            let cancelAction = UIAlertAction.init(title: "Continue", style: UIAlertActionStyle.cancel, handler: nil)
            confirmAlert.addAction(confirmAction)
            confirmAlert.addAction(cancelAction)
            self.present(confirmAlert, animated: true, completion: nil)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func selectedPersonChanged() {
        // Anything else to change in the UI?
        self.hasEdited = true
        if self.personPicker.selectedSegmentIndex == 0 {
            self.newExpense?.spender = Spender.calvin
        } else {
            self.newExpense?.spender = Spender.rosie
        }
    }
    
    func dateChanged() {
        self.hasEdited = true
        self.newExpense?.date = self.datePicker.date as NSDate
    }
    
    func owedSliderChanged(sender: UISlider?) {
        if sender != nil {
            self.hasEdited = true
        }
        self.newExpense?.percentageOwed = self.owedSlider.value as NSNumber
        self.owedLabel.text = nf?.string(from: (self.newExpense?.percentageOwed)!)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.categoryPicker {
            return CategoryManager.categories().count + 2
        } else if pickerView == self.intervalPicker {
            return IntervalManager.intervals().count + 1
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.categoryPicker {
            if row == 0 {
                return "Select Category"
            } else if row == CategoryManager.categories().count + 1 {
                return "New Category"
            } else {
                return CategoryManager.categories()[row - 1]
            }
        } else if pickerView == self.intervalPicker {
            if row == 0 {
                return "Not Recurring"
            } else {
                return IntervalManager.intervals()[row - 1]
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.hasEdited = true
        if pickerView == self.categoryPicker {
            if row == 0 {
                self.newExpense?.category = nil
            } else if row == CategoryManager.categories().count + 1 {
                let newCatAlert = UIAlertController.init(title: "New Category", message: "Enter the category title", preferredStyle: UIAlertControllerStyle.alert)
                let confirmAction = UIAlertAction.init(title: "Done", style: UIAlertActionStyle.default, handler: { (action) in
                    let text = newCatAlert.textFields?.first?.text
                    if text?.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines) == "" {
                        newCatAlert.title = "Invalid Category Name"
                        self.present(newCatAlert, animated: true, completion: nil)
                    } else {
                        CategoryManager.addCategory(newCategory: text!)
                        self.categoryPicker.reloadAllComponents()
                        self.categoryPicker.selectRow(CategoryManager.categories().index(of: text!)! + 1, inComponent: 0, animated: true)
                    }
                })
                let cancelAction = UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
                    self.categoryPicker.selectRow(0, inComponent: 0, animated: true)
                })
                newCatAlert.addTextField(configurationHandler: { (textField) in
                    textField.placeholder = "New Category"
                    textField.autocorrectionType = UITextAutocorrectionType.yes
                    textField.autocapitalizationType = UITextAutocapitalizationType.words
                })
                newCatAlert.addAction(confirmAction)
                newCatAlert.addAction(cancelAction)
                
                self.present(newCatAlert, animated: true, completion: nil)
                
            } else {
                self.newExpense?.category = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            }
        } else if pickerView == self.intervalPicker {
            self.newExpense?.recurring = row != 0
            if (self.newExpense?.recurring!)! {
                self.newExpense?.interval = self.pickerView(pickerView, titleForRow: row, forComponent: component)
            } else {
                self.newExpense?.interval = nil
            }
            
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.hasEdited = true
        if textField == self.amountField {
            if (textField.text?.hasPrefix("$"))! {
                textField.text = textField.text?.replacingOccurrences(of: "$", with: "")
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.amountField {
            if let doubleValue = Double.init(textField.text!) {
                self.newExpense?.amount = NSNumber.init(value: doubleValue)
                textField.text = self.currencyFormatter?.string(from: (self.newExpense?.amount)!)
            }
            
        } else if textField == self.memoField {
            self.newExpense?.memo = textField.text!
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        // if expense if populated
        self.savingAlert = UIAlertController.init(title: "Please Wait", message: "Saving expense...", preferredStyle: UIAlertControllerStyle.alert)
        self.present(self.savingAlert!, animated: true, completion: nil)
        CloudKitManager.sharedInstance.delegate = self
        CloudKitManager.add(expense: self.newExpense!)
    }
    
    func didFinishTask() {
        self.savingAlert?.dismiss(animated: true, completion: { 
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    func failedWithError(error: Error) {
        ErrorManager.present(error: error, onViewController: self)
    }
    
}
