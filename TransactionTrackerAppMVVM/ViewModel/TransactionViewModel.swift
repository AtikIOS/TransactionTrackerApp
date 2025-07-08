//
//  TransactionViewModel.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
//

import Foundation

class TransactionViewModel {
    
    var transactions: [Transaction] = []

    var onDataUpdated: (() -> Void)?
    var onError: ((String) -> Void)?

    func addTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        FireBaseManager.shared.addTransactionToFirebase(transaction: transaction) { success in
            completion(success)
        }
    }

    func fetchTransactions() {
        FireBaseManager.shared.fetchTransactionsFromFirebase { [weak self] result in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.transactions = result
                self.onDataUpdated?()
            }
        }
    }

    func updateTransaction(_ transaction: Transaction, completion: @escaping (Bool) -> Void) {
        FireBaseManager.shared.updateTransactionInFirebase(transaction: transaction) { success in
            completion(success)
        }
    }

    func deleteTransaction(id: String, at index: Int, completion: @escaping (Bool) -> Void) {
        FireBaseManager.shared.deleteTransactionFromFirebase(id: id) { [weak self] success in
            guard let self = self else {return}
            if success {
                self.transactions.remove(at: index)
            }
            completion(success)
        }
    }
}
