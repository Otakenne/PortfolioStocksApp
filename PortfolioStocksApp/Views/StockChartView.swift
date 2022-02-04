//
//  StockChartView.swift
//  PortfolioStocksApp
//
//  Created by Otakenne on 31/01/2022.
//

import Charts
import UIKit

struct StockChartViewViewModel {
    let data: [Double]
    let showLegend: Bool
    let showAxis: Bool
    let fillColor: UIColor
}

class StockChartView: UIView {
    
    let chartView: LineChartView = {
        let chartView = LineChartView()
        chartView.pinchZoomEnabled = false
        chartView.setScaleEnabled(true)
        chartView.xAxis.enabled = false
        chartView.drawGridBackgroundEnabled = false
        chartView.leftAxis.enabled = false
        chartView.rightAxis.enabled = false
        chartView.legend.enabled = false
        return chartView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(chartView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chartView.frame = bounds
    }
    
    func reset() {
        chartView.data = nil
    }
    
    func configure(with viewModel: StockChartViewViewModel) {
        var entries = [ChartDataEntry]()
        
        for (index, value) in viewModel.data.enumerated() {
            entries.append(ChartDataEntry(x: Double(index), y: value))
        }
        
        chartView.leftAxis.enabled = viewModel.showAxis
        chartView.legend.enabled = viewModel.showLegend
        
        let dataset = LineChartDataSet(entries: entries, label: "")
        dataset.fillColor = viewModel.fillColor
        dataset.lineWidth = 0.2
        dataset.label = nil
        dataset.drawFilledEnabled = true
        dataset.drawIconsEnabled = false
        dataset.drawValuesEnabled = false
        dataset.drawCirclesEnabled = false
        let data = LineChartData(dataSet: dataset)
        chartView.data = data
    }
}
