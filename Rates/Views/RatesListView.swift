//
//  RatesListView.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//

import SwiftUI
import Combine

struct RatesListView: View {
    
    // MARK: - Private properties
    
    @State var isRefreshing = false
    @ObservedObject var ratesViewModel = RatesViewModel()
    
    // MARK: - SwiftUI support
    
    var body: some View {
        NavigationView {
            if isRefreshing {
                Text("Refreshing...")
            } else {
                if ratesViewModel.rates != nil {
                    List(ratesViewModel.rates!) { rate in
                        NavigationLink(destination: HistoryRatesView(rateName: rate.name)) {
                        HStack () {
                            Text(rate.name)
                            Text(String(format: "%.2f", rate.value))
                                .font(.system(size: 11))
                                .foregroundColor(Color.gray)
                        }
                        }
                    }.navigationBarTitle(Text("Rates"))
                } else {
                    Text("No exchange rate data is available")
                }
            }
        }.onAppear() {
            self.isRefreshing = true
            self.ratesViewModel.updateRates()
        }.onReceive(ratesViewModel.objectWillChange) {
            self.isRefreshing = false
        }
    }
}
