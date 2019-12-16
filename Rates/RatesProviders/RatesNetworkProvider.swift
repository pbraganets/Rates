//
//  RatesNetworkProvider.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation

class RatesNetworkProvider: RatesProvider, HistoryRatesProvider {
    
    // MARK: - Private properties
    
    static let ratesUrl = URL(string:"https://api.exchangeratesapi.io/latest?base=USD")!
    static let historyRatesString = "https://api.exchangeratesapi.io/history?start_at=%@&end_at=%@&base=USD&symbols=%@"
    static let ratesError = NSError(domain: "RatesNetworkProvider", code: 0, userInfo: nil)
    
    // MARK: - RatesProvider protocol implementation
    
    func ratesList(completion: @escaping ([(String, Double)]?, Error?) -> Void) {
        URLSession.shared.dataTask(with: RatesNetworkProvider.ratesUrl) {(data, response, error) in
            if error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let rates = json["rates"] as? [String: Double],
                rates.count > 0
            {
                completion(rates.map({ (key, value) -> (String, Double) in
                    return (key, value)
                }), nil)
            } else {
                completion(nil, RatesNetworkProvider.ratesError)
            }
        }.resume()
    }
    
    // MARK: - HistoryRatesProvider protocol implementation
    
    func historyRatesList(name: String, completion: @escaping (_ rates: [(String, Double)]?, _ error: Error?) -> Void) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDateString = dateFormatter.string(from: Date())
        let sevenDaysAgoString = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: -10, to: Date())!)
        let ratesHistoryUrlString = String(format: RatesNetworkProvider.historyRatesString, sevenDaysAgoString, currentDateString, name)
        let ratesHistoryUrl = URL(string: ratesHistoryUrlString)!
        
        URLSession.shared.dataTask(with: ratesHistoryUrl) {(data, response, error) in
            if error == nil,
                let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                let rates = json["rates"] as? [String: [String: Double]],
                rates.count > 0
            {
                var result = Array<(String, Double)>()
                for value in rates.values {
                    result.append((value.keys.first!, value[value.keys.first!]!))
                }
                completion(result, nil)
            } else {
                completion(nil, RatesNetworkProvider.ratesError)
            }
        }.resume()
    }
}
