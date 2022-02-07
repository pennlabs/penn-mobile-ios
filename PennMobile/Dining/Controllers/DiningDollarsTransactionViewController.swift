//
//  DiningDollarsTransactionViewController.swift
//  PennMobile
//
//  Created by Elizabeth Powell on 11/22/19.
//  Copyright © 2019 PennLabs. All rights reserved.
//

import Foundation

protocol TransactionCellDelegate: AnyObject {
    func userDidSelect()
}

class DiningDollarsTransactionViewController: GenericTableViewController, Requestable, IndicatorEnabled {

    let transactionUrl = "https://api.pennlabs.org/dining/transactions"
    var transactionHistory: [Transaction]?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Transaction History"

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: TransactionTableViewCell.identifier)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showActivity()
        PennCashNetworkManager.instance.getTransactionHistory { data in
            if let data = data, let str = String(bytes: data, encoding: .utf8) {
                UserDefaults.standard.setLastTransactionRequest()
                UserDBManager.shared.saveTransactionData(csvStr: str) {
                    self.fetchTransactionData { (results, _) in
                        DispatchQueue.main.async {
                            self.hideActivity()
                            self.transactionHistory = results
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                self.fetchTransactionData { (results, _) in
                    DispatchQueue.main.async {
                        self.hideActivity()
                        self.transactionHistory = results
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
}

// MARK: - Table View Functions
extension DiningDollarsTransactionViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionHistory?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionTableViewCell.identifier, for: indexPath) as! TransactionTableViewCell
        let transaction: Transaction = transactionHistory![indexPath.item]
        cell.transaction = transaction
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

// MARK: - API Request
extension DiningDollarsTransactionViewController {
    func fetchTransactionData(_ completion: @escaping (_ transactions: [Transaction]?, _ error: Bool) -> Void) {
        getRequestData(url: transactionUrl) { (data, error, _) in
            if error != nil {
                print(error.debugDescription)
            }

            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)

            if let data = data, let transactionAPIResponse = try? decoder.decode(TransactionAPIResponse.self, from: data) {
                completion(transactionAPIResponse.results, false)
            } else {
                completion(nil, true)
            }
        }
    }
}

// MARK: - Transaction + Codable
struct TransactionAPIResponse: Codable {
    let results: [Transaction]
}

struct Transaction: Codable, Equatable {
    let amount: Double
    let balance: Double
    let date: Date
    let description: String
}
