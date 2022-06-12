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
                        BarMark(
                            x: .value("Frequency", freq.id),
                            y: .value("db", freq.db)
                        )
                    }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
