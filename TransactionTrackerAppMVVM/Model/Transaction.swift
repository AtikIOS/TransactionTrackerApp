//
//  Transaction.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
//


import UIKit
import Foundation

enum selectionType {
    case add, edit
}

enum TransactionType: String, Codable {
    case income = "Income"
    case expense = "Expense"
}

struct Transaction: Codable {
    var id: String? = nil
    var title: String = ""
    var amount: Double = 0.0
    var type: TransactionType = .expense
    var timestamp: Date = Date()
}
