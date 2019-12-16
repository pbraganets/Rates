//
//  RatesStorage.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation

protocol RatesStorage {
    func storeRates(_ rates: [(String, Double)], completion: ((_ result: Bool, _ error: Error?) -> Void)?)
}
