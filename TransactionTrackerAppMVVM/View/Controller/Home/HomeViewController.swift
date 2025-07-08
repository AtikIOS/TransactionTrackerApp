//
//  HomeViewController.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
//

import UIKit

class HomeViewController: UIViewController {

    // MARK: -------- Outlets ----------
    @IBOutlet weak var transactionList: UITableView!

    // MARK: -------- Propertise ----------
    private var viewModel = TransactionViewModel()

    // MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        viewModel.fetchTransactions()
    }

    // MARK: -------- Private Methods ----------
    
    private func setupUI() {
        self.transactionList.delegate = self
        self.transactionList.dataSource = self
        self.transactionList.register(TransactionCell.nib(), forCellReuseIdentifier: TransactionCell.identifier)
        self.transactionList.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
    }

    private func bindViewModel() {
        viewModel.onDataUpdated = {
            self.transactionList.reloadData()
        }

        viewModel.onError = { message in
            Common.shared.showNoteActionAlert(tittle: "Error", message: message, self: self)
        }
    }
    
    private func showDeleteConfirmation(id: String, at indexPath: IndexPath, tableView: UITableView) {
        let alert = UIAlertController(
            title: "Delete Transaction",
            message: "Are you sure you want to delete this transaction?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.viewModel.deleteTransaction(id: id, at: indexPath.row) { success in
                DispatchQueue.main.async {
                    if success {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    } else {
                        Common.shared.showNoteActionAlert(
                            tittle: "Error",
                            message: "Failed to delete transaction.",
                            self: self
                        )
                    }
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func gotoTransactionVC() {
        let storyboard = UIStoryboard(name: "AddTransactionController", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddTransactionController") as? AddTransactionController {
            vc.selectType = .add
            vc.viewModel = self.viewModel
            vc.onTransactionSaved = {
                self.viewModel.fetchTransactions()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: -------- Action Methods ----------
    
    @IBAction func btnAddTransactionAction(_ sender: UIButton) {
        self.gotoTransactionVC()
    }

}

// MARK: -------- TableView DateSource & Delegate ----------
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = viewModel.transactions[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as! TransactionCell
        cell.selectionStyle = .none
        cell.configure(with: transaction)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let transaction = viewModel.transactions[indexPath.row]
        let storyboard = UIStoryboard(name: "AddTransactionController", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "AddTransactionController") as? AddTransactionController {
            vc.selectType = .edit
            vc.transactionModel = transaction
            vc.viewModel = self.viewModel
            vc.onTransactionUpdated = { updated in
                self.viewModel.transactions[indexPath.row] = updated
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let transaction = viewModel.transactions[indexPath.row]
            guard let id = transaction.id else { return }
            showDeleteConfirmation(id: id, at: indexPath, tableView: tableView)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
}
