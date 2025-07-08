//
//  FireBaseManager.swift
//  TransactionTrackerAppMVVM
//
//  Created by Atik Hasan on 7/8/25.
// FireBase URL : https://transactiontrackerappmvvm-default-rtdb.firebaseio.com/


import UIKit
import Foundation
import FirebaseDatabase

class FireBaseManager : AnyObject {
    
    static let shared = FireBaseManager()
    private let dbRef = Database.database().reference().child("transactions")
    
    
    // MARK: - Save Transaction
    func addTransactionToFirebase(transaction: Transaction, completion: @escaping (Bool) -> Void) {
        let urlString = "https://transactiontrackerappmvvm-default-rtdb.firebaseio.com/transactions.json"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(transaction)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("POST Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Server error!")
                    completion(false)
                    return
                }
               
                if let data = data {
                    do {
                        if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let name = jsonResponse["name"] as? String {
                            print("Saved with ID: \(name)")
                            completion(true)
                            return
                        }
                    } catch {
                        print("Response parsing error")
                    }
                }
                completion(true)
            }
            task.resume()
        } catch {
            print("Encoding error: \(error.localizedDescription)")
            completion(false)
        }
    }

    
    // MARK: - Fetch Transaction
    func fetchTransactionsFromFirebase(completion: @escaping ([Transaction]) -> Void) {
        let urlString = "https://transactiontrackerappmvvm-default-rtdb.firebaseio.com/transactions.json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }

        let request = URLRequest(url: url)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Fetch Error: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("No data received")
                completion([])
                return
            }

            do {
                let firebaseDict = try decoder.decode([String: Transaction].self, from: data)
                
                // Correct way to mutate structs inside map
                let transactions = firebaseDict.map { (key, transaction) -> Transaction in
                    var mutableTransaction = transaction
                    mutableTransaction.id = key
                    return mutableTransaction
                }
                .sorted { $0.timestamp > $1.timestamp }
                
                completion(transactions)
            } catch {
                if let rawJSON = String(data: data, encoding: .utf8) {
                    print("Raw Firebase JSON:\n\(rawJSON)")
                }
                print("Decoding error: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }


    // MARK: - Delete Transaction
    func deleteTransactionFromFirebase(id: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://transactiontrackerappmvvm-default-rtdb.firebaseio.com/transactions/\(id).json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid DELETE URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("DELETE Error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Server error on DELETE")
                completion(false)
                return
            }
            
            print("Transaction deleted with ID: \(id)")
            completion(true)
        }.resume()
    }

    
    // MARK: - Edit (Update) Transaction
    func updateTransactionInFirebase(transaction: Transaction, completion: @escaping (Bool) -> Void) {
        guard let id = transaction.id else {
            print("Transaction ID is missing")
            completion(false)
            return
        }
        
        let urlString = "https://transactiontrackerappmvvm-default-rtdb.firebaseio.com/transactions/\(id).json"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        do {
            let jsonData = try encoder.encode(transaction)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Update Error: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    print("Server Error on Update")
                    completion(false)
                    return
                }
                
                print("Transaction updated with ID: \(id)")
                completion(true)
            }.resume()
            
        } catch {
            print("Encoding Error: \(error.localizedDescription)")
            completion(false)
        }
    }

}
