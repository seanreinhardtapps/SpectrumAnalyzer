//
//  ContentView.swift
//  SpectrumAnalyzerSwiftUI
//
//  Created by Sean Reinhardt on 6/12/22.
//

import SwiftUI
import Charts
import Combine

struct ContentView: View {
    @StateObject private var viewModel:ChartViewModel = ChartViewModel()
    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.data) { freq in
//                        BarMark(
//                            x: .value("Frequency", freq.id),
//                            y: .value("db", freq.db)
//                        )
                    LineMark(
                        x: .value("Frequency", freq.hz),
                        y: .value("db", freq.db)
                    )
                }
            }
            //.chartYScale(domain: 0...60)
            .chartXScale(domain: 0...12000)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
