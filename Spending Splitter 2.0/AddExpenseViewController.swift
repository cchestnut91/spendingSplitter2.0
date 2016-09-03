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
    @IBOutlet weak var owedPicker: UISegmentedControl!
    @IBOutlet weak var intervalPicker: UIPickerView!
    
    @IBOutlet weak var categoryExpandButton: UIButton!
    @IBOutlet weak var dateExpandButton: UIButton!
    @IBOutlet weak var intervalExpandButton: UIButton!
    
    @IBOutlet weak var categoryPickerHeight: NSLayoutConstraint!
    @IBOutlet weak var datePickerHeight: NSLayoutConstraint!
    @IBOutlet weak var intervalPickerHeight: NSLayoutConstraint!
    
    var hasEdited: Bool?
    var newExpense: Expense?
    
    var nf: NumberFormatter?
    var currencyFormatter: NumberFormatter?
    
    var savingAlert: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName:#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)]
        
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
        
        self.intervalPicker.delegate = self
        self.intervalPicker.dataSource = self
        
        let toolbar = UIToolbar.init(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: UIScreen.main.bounds.size.width, height: 44.0)))
        let space = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem.init(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(AddExpenseViewController.doneTapped))
        
        toolbar.setItems([space, done], animated: true)
        
        self.amountField.inputAccessoryView = toolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func doneTapped() {
        self.resizePicker(name: nil)
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
    
    @IBAction func categoryExpandTapped(_ sender: AnyObject) {
        self.resizePicker(name: "Category")
    }
    
    @IBAction func dateExpandTapped(_ sender: AnyObject) {
        self.resizePicker(name: "Date")
    }
    
    @IBAction func intervalExpandTapped(_ sender: AnyObject) {
        self.resizePicker(name: "Interval")
    }
    
    func resizePicker(name: String?) {
        
        if name == "Category" {
            self.categoryExpandButton.isHidden = true
            self.categoryPickerHeight.constant = 155
        } else {
            self.categoryExpandButton.isHidden = false
            self.categoryPickerHeight.constant = 55
        }
        if name == "Date" {
            self.dateExpandButton.isHidden = true
            self.datePickerHeight.constant = 155
        } else {
            self.dateExpandButton.isHidden = false
            self.datePickerHeight.constant = 55
        }
        if name == "Interval" {
            self.intervalExpandButton.isHidden = true
            self.intervalPickerHeight.constant = 155
        } else {
            self.intervalExpandButton.isHidden = false
            self.intervalPickerHeight.constant = 55
        }
        
        if name != "Amount" {
            self.amountField.resignFirstResponder()
        }
        if name != "Memo" {
            self.memoField.resignFirstResponder()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }

    func selectedPersonChanged() {
        // Anything else to change in the UI?
        self.hasEdited = true
        self.resizePicker(name: nil)
        if self.personPicker.selectedSegmentIndex == 0 {
            self.newExpense?.spender = Spender.calvin
        } else {
            self.newExpense?.spender = Spender.rosie
        }
    }
    
    func dateChanged() {
        self.hasEdited = true
        self.resizePicker(name: "Date")
        self.newExpense?.date = self.datePicker.date as NSDate
    }
    
    @IBAction func owedControlTapped(_ sender: AnyObject) {
        self.hasEdited = true;
        self.resizePicker(name: nil)
        let initial = 0.25
        let multiply = Double(self.owedPicker.selectedSegmentIndex)
        let product = initial * multiply
        let value = NSNumber.init(value: product)
        if value.doubleValue > 1.0 {
            self.showOwedAlert()
        } else {
            self.newExpense?.percentageOwed = value
        }
    }
    
    func showOwedAlert() {
        let percentageAlert = UIAlertController.init(title: "Amount Owed", message: "How would you like to enter the amount owed", preferredStyle: UIAlertControllerStyle.alert)
        let percentAction = UIAlertAction.init(title: "Percentage", style: UIAlertActionStyle.default) { (action) in
            let percentAlert = UIAlertController.init(title: "Percentage", message: "Enter the percentage you are owed", preferredStyle: UIAlertControllerStyle.alert)
            percentAlert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .numberPad
                textField.placeholder = "Percentage Owed"
            })
            let saveAction = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: { (action) in
                var errorText: String?
                let text = percentAlert.textFields?.first?.text
                if let doubleValue = Double(text!) {
                    if doubleValue > 100 || doubleValue < 0 {
                        errorText = "Invalid Value"
                    } else {
                        let numValue = NSNumber.init(value: ( doubleValue / 100.0))
                        self.newExpense?.percentageOwed = numValue
                    }
                } else {
                    errorText = "Invalid Value"
                }
                if errorText != nil {
                    self.showError(text: errorText!)
                }
            })
            percentAlert.addAction(saveAction)
            percentAlert.addAction(ErrorManager.cancelAction())
            self.present(percentAlert, animated: true, completion: nil)
        }
        let valueAction = UIAlertAction.init(title: "Amount", style: UIAlertActionStyle.default) { (action) in
            let valueAlert = UIAlertController.init(title: "Value", message: "Enter the amount you are owed", preferredStyle: UIAlertControllerStyle.alert)
            valueAlert.addTextField(configurationHandler: { (textField) in
                textField.keyboardType = .decimalPad
                textField.placeholder = "Amount Owed"
            })
            let saveAction = UIAlertAction.init(title: "Save", style: UIAlertActionStyle.default, handler: { (action) in
                var errorText: String?
                let text = valueAlert.textFields?.first?.text
                if let doubleValue = Double(text!) {
                    if doubleValue < 0.0 {
                        errorText = "Invalid Value"
                    } else {
                        self.newExpense?.amountOwed = doubleValue
                    }
                } else {
                    errorText = "Invalid Value"
                }
                if errorText != nil {
                    self.showError(text: errorText!)
                }
            })
            valueAlert.addAction(saveAction)
            valueAlert.addAction(ErrorManager.cancelAction())
            self.present(valueAlert, animated: true, completion: nil)
        }
        
        percentageAlert.addAction(percentAction)
        percentageAlert.addAction(valueAction)
        percentageAlert.addAction(ErrorManager.cancelAction())
        
        self.present(percentageAlert, animated: true, completion: nil)
    }
    
    func showError(text: String) {
        
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
            self.resizePicker(name: "Category")
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
            self.resizePicker(name: "Interval")
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
            self.resizePicker(name: "Amount")
            if (textField.text?.hasPrefix("$"))! {
                textField.text = textField.text?.replacingOccurrences(of: "$", with: "")
            }
        } else if textField == self.memoField {
            self.resizePicker(name: "Memo")
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
    
    func validateExpense() -> String? {
        
        return self.newExpense?.validate()
    }
    
    @IBAction func saveTapped(_ sender: AnyObject) {
        
        if let error = self.validateExpense() {
            let errorAlert = UIAlertController.init(title: "Error Adding Expense", message: error, preferredStyle: UIAlertControllerStyle.alert)
            errorAlert.addAction(ErrorManager.okAction())
            self.present(errorAlert, animated: true, completion: nil)
        } else {
            self.savingAlert = UIAlertController.init(title: "Please Wait", message: "Saving expense...", preferredStyle: UIAlertControllerStyle.alert)
            self.present(self.savingAlert!, animated: true, completion: nil)
            CloudKitManager.sharedInstance.delegate = self
            CloudKitManager.add(expense: self.newExpense!)
        }
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
