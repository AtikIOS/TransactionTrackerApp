//
//  TransactionCell.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
//

import UIKit

class TransactionCell: UITableViewCell {
    
    // MARK: -------- Outlets ----------
    @IBOutlet weak var lblTittle : UILabel!
    @IBOutlet weak var lblType : UILabel!
    @IBOutlet weak var lblAmount : UILabel!
    @IBOutlet weak var lblDate : UILabel!
    
    // MARK: -------- Properties ----------
    static let identifier : String = "TransactionCell"
    static func nib() -> UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: -------- Private Methods ----------
    func configure(with transaction: Transaction) {
        self.lblTittle.text = transaction.title
        self.lblAmount.text = "৳ \(String(transaction.amount))"
        
        self.lblType.text = transaction.type == .expense ? "Expense" : "Income"
        self.lblType.textColor = transaction.type == .expense ? .red : .blue
        self.lblDate.text = Common.shared.formatDateString(from: transaction.timestamp)
    }
}
