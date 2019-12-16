//
//  RatesClusterProvider.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation

class RatesClasterProvider: RatesProvider {
    
    // MARK: - Private properties
    
    private let lastStoreDateKey = "lastStoreDateKey"
    private let ratesNetworkProvider = RatesNetworkProvider()
    private let ratesCoreDataProvider = RatesCoreDataProvider()
    private var lastStoreDate: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastStoreDateKey) as? Date
        }
        set {
            UserDefaults.standard.set(newValue, forKey:lastStoreDateKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    // MARK: - RatesProvider protocol implementation
    
    func ratesList(completion: @escaping ([(String, Double)]?, Error?) -> Void) {
        if shouldRequestRatesFromNetwork() {
            ratesNetworkProvider.ratesList { (rat, error) in
                completion(rat, error)
                
                if let rat = rat {
                    self.ratesCoreDataProvider.storeRates(rat) { (success, error) in
                        if success {
                            self.lastStoreDate = Date()
                        }
                    }
                }
            }
        } else {
            ratesCoreDataProvider.ratesList { (rat, error) in
                completion(rat, error)
            }
        }
    }
    
    // MARK: - Private functions
    
    private func shouldRequestRatesFromNetwork() -> Bool {
        if let lastSaveDate = lastStoreDate {
            return Date().timeIntervalSince(lastSaveDate) > 10 * 60
        } else {
            return true
        }
    }
}
