//
//  AddTransactionController.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
//

import UIKit
import Firebase
import FirebaseDatabase

class AddTransactionController: UIViewController {

    // MARK: -------- Outlets ----------
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var txtFieldTittle: UITextField!
    @IBOutlet weak var txtFieldAmount: UITextField!
    @IBOutlet weak var segmentType: UISegmentedControl!

    // MARK: -------- Propertise ----------
    var viewModel: TransactionViewModel?
    var transactionModel: Transaction?
    var selectType: selectionType = .add
    var onTransactionSaved: (() -> Void)?
    var onTransactionUpdated: ((Transaction) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: -------- Private Methods ----------
    
    private func setupUI() {
        if selectType == .edit, let model = transactionModel {
            lblTittle.text = "Edit Transaction"
            txtFieldTittle.text = model.title
            txtFieldAmount.text = String(model.amount)
            segmentType.selectedSegmentIndex = model.type == .income ? 0 : 1
        } else {
            lblTittle.text = "Add Transaction"
        }
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
           view.addGestureRecognizer(tapGesture)
    }
    
    func submitData() {
        guard let title = txtFieldTittle.text, !title.isEmpty else {
            Common.shared.showNoteActionAlert(tittle: "Error", message: "Please enter title", self: self)
            return
        }

        guard let amountStr = txtFieldAmount.text, let amount = Double(amountStr) else {
            Common.shared.showNoteActionAlert(tittle: "Error", message: "Please enter valid amount", self: self)
            return
        }

        let selectedType = segmentType.selectedSegmentIndex == 0 ? TransactionType.income : .expense
        
        if selectType == .add {
            let newTransaction = Transaction(title: title, amount: amount, type: selectedType, timestamp: Date())
            viewModel?.addTransaction(newTransaction) { success in
                if success {
                    DispatchQueue.main.async {
                        self.onTransactionSaved?()
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    Common.shared.showNoteActionAlert(tittle: "Error Saving", message: "Data Saving Failed", self: self)
                }
            }
        } else {
            guard var updated = transactionModel else { return }
            updated.title = title
            updated.amount = amount
            updated.type = selectedType
            updated.timestamp = Date()

            viewModel?.updateTransaction(updated) { success in
                if success {
                    DispatchQueue.main.async {
                        self.onTransactionUpdated?(updated)
                        self.navigationController?.popViewController(animated: true)
                    }
                }else{
                    Common.shared.showNoteActionAlert(tittle: "Error Editing", message: "Data Editing Failed", self: self)
                }
            }
        }
    }
    
    // MARK: -------- Action Methods ----------
    @IBAction func btnSubmitAction(_ sender: UIButton) {
        self.submitData()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

