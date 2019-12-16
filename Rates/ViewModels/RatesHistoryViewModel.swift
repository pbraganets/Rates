//
//  RatesHistoryViewModel.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation
import Combine

class HistoryRatesViewModel: ObservableObject {
    
    // MARK: - Private properties
    
    @Published var rates: [RateViewItem]?
    let ratesNetworkProvider = RatesNetworkProvider()
    
    // MARK: - Public functions
    
    func updateRates(rate: String) {
        ratesNetworkProvider.historyRatesList(name: rate) { (rateTuples, error) in
            if let rateTuples = rateTuples {
                DispatchQueue.main.async {
                    self.rates = rateTuples.map {RateViewItem(id: $0.0, name: $0.0, value: $0.1)}
                }
            } else {
                DispatchQueue.main.async {
                    self.rates = nil
                }
            }
        }
    }
}
