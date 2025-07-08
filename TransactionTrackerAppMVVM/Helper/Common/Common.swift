//
//  Common.swift
//  Transaction_Tracker_App
//
//  Created by Atik Hasan on 7/8/25.
//

import UIKit
import Foundation

class Common : AnyObject{
    
    static let shared = Common()
    
    func showNoteActionAlert(tittle : String, message : String, self : UIViewController) {
            let alert = UIAlertController(
                title: tittle,
                message: message,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            self.present(alert, animated: true)
    }
    
    func formatDateString(from date: Date,
                              toFormat: String = "dd MMM yyyy, h:mm a",
                              localeIdentifier: String = "en_US") -> String {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = toFormat
            outputFormatter.locale = Locale(identifier: localeIdentifier)
            return outputFormatter.string(from: date)
        }
}
