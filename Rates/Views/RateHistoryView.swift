//
//  HistoryRatesView.swift
//  Rates
//
//  Created by Pavel B on 12/15/19.
//  Copyright © 2019 Pavel B. All rights reserved.
//


import SwiftUI
import Combine

struct HistoryRatesView: View {
    
    // MARK: - Private properties
    
    @State var isRefreshing = true
    @State var lines: [CGFloat] = []
    @ObservedObject var rateHistoryViewModel = HistoryRatesViewModel()
    var rateName: String

    // MARK: - SwiftUI support
    
    var body: some View {
        VStack {
            if isRefreshing {
                Text("Refreshing...")
            } else {
                if rateHistoryViewModel.rates != nil {
                    LineChartView(lines: rateHistoryViewModel.rates!.map({ (rateViewItem) -> CGFloat in
                        CGFloat(rateViewItem.value)}))
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                } else {
                    Text("No exchange rate data is available for the selected currency")
                }
            }
        }.onAppear() {
            self.isRefreshing = true
            self.rateHistoryViewModel.updateRates(rate: self.rateName)
        }.onReceive(rateHistoryViewModel.objectWillChange) {
            self.isRefreshing = false
        }
    }
}
