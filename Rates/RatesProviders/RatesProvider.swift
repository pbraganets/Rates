//
//  RatesProvider.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import Foundation

protocol RatesProvider {
    func ratesList(completion: @escaping (_ rates: [(String, Double)]?, _ error: Error?) -> Void);
}
