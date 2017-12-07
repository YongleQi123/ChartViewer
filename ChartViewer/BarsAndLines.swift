//
//  BarsAndLines.swift
//  ChartViewer
//
//  Created by 齐永乐 on 2017/12/1.
//  Copyright © 2017年 Apple Inc. All rights reserved.
//

import UIKit
import SwiftCharts

class BarsAndLines: UIViewController {
    
    fileprivate var chart: Chart?
    
    override func viewDidLoad() {
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        var readFormatter = DateFormatter()
        readFormatter.dateFormat = "dd.MM"
        
        var displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM"
        
        let date = {(str: String) -> Date in
            return readFormatter.date(from: str)!
        }
        
        let calendar = Calendar.current
        
        let dateWithComponents = {(day: Int, month: Int, year: Int) -> Date in
            var components = DateComponents()
            components.day = day
            components.month = month
            components.year = year
            return calendar.date(from: components)!
        }
        
        
        
       let barsData: [(title: String, min: Double, max: Double)] = [
            ("A", 0, 40),
            ("B", 0, 50),
            ("C", 0, 35),
            ("D", 0, 40),
            ("E", 0, 30),
            ("F", 0, 47),
            ("G", 0, 60),
            ("H", 0, 48)
        ]
        
/*        let lineData: [(title: String, val: Double)] = [
            ("A", 15),
            ("B", 23),
            ("C", 20),
            ("D", 17),
            ("E", 28),
            ("F", 23),
            ("G", 19),
            ("H", 45)
        ]*/
        
        let alpha: CGFloat = 0.8
        let posColor = UIColor.red.withAlphaComponent(alpha)
        //let negColor = UIColor.red.withAlphaComponent(alpha)
        let zero = ChartAxisValueDouble(0)
        let bars: [ChartBarModel] = barsData.enumerated().flatMap {index, tuple in
            [
                ChartBarModel(constant: ChartAxisValueDouble(index), axisValue1: zero, axisValue2: ChartAxisValueDouble(tuple.max), bgColor: posColor)
            ]
        }
        
/*         let xModel = ChartAxisModel(firstModelValue: 0.5, lastModelValue: 7.5, axisTitleLabels: [ChartAxisLabel(text: "Date", settings: labelSettings)], axisValuesGenerator: xGenerator, labelsGenerator: labelsGenerator)
         let yModel = ChartAxisModel(firstModelValue: 0, lastModelValue: 1, axisTitleLabels: [ChartAxisLabel(text: "Progess", settings: labelSettings.defaultVertical())], axisValuesGenerator: yGenerator, labelsGenerator: labelsGenerator
        
        let xGenerator = ChartAxisGeneratorMultiplier(1)
        let yGenerator = ChartAxisGeneratorMultiplier(10)
        let labelsGenerator = ChartAxisLabelsGeneratorFunc {scalar in
            return ChartAxisLabel(text: "\(scalar)", settings: labelSettings)
        }
        */
       let xValues = [
            createDateAxisValue("01.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("02.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("03.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("04.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("05.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("06.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("07.10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("08.10", readFormatter: readFormatter, displayFormatter: displayFormatter)
        ]
        let yValues = stride(from: 0, through: 100, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        
        
        let xModel = ChartAxisModel(axisValues:xValues, axisTitleLabels: [ChartAxisLabel(text: "Date", settings: labelSettings)])
        let yModel = ChartAxisModel(axisValues:yValues, axisTitleLabels: [ChartAxisLabel(text: "Progress", settings: labelSettings.defaultVertical())] )

        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        
        // Bars layer
        
        let myBars = [createBar(dateStr: "01.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "02.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "03.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "04.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "05.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "06.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "07.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
                      createBar(dateStr: "08.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter)
                      ]
        let barViewSettings = ChartBarViewSettings(animDuration: 0.5)
        let barsLayer = ChartBarsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, bars: myBars, horizontal: false, barWidth: Env.iPad ? 40 : 25, settings: barViewSettings)
        
        /*
         Labels layer.
         Create chartpoints for the top and bottom of the bars, where we will show the labels.
         There are multiple ways to do this. Here we represent the labels with chartpoints at the top/bottom of the bars. We set some space using domain coordinates, in order for this to be updated properly during zoom / pan. Note that with this the spacing is also zoomed, meaning the labels will move away from the edges of the bars when we scale up, which maybe it's not wanted. More elaborate approaches involve passing a custom transform closure to the layer, or using GroupedBarsCompanionsLayer (currently only for stacked/grouped bars, though any bar chart can be represented with this).
         */
        let labelToBarSpace: Double = 1 // domain units
        let labelChartPoints = bars.map {bar in
            ChartPoint(x: bar.constant, y: bar.axisValue2.copy(bar.axisValue2.scalar + (bar.axisValue2.scalar > 0 ? labelToBarSpace : -labelToBarSpace)))
        }
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let labelsLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: labelChartPoints, viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let label = HandlingLabel()
            
            let pos = chartPointModel.chartPoint.y.scalar > 0
            
            label.text = "\(formatter.string(from: NSNumber(value: chartPointModel.chartPoint.y.scalar - labelToBarSpace))!)%"
            label.font = ExamplesDefaults.labelFont
            label.sizeToFit()
            label.center = CGPoint(x: chartPointModel.screenLoc.x, y: pos ? innerFrame.origin.y : innerFrame.origin.y + innerFrame.size.height)
            label.alpha = 0
            
            label.movedToSuperViewHandler = {[weak label] in
                UIView.animate(withDuration: 3, animations: {
                    label?.alpha = 1
                    label?.center.y = chartPointModel.screenLoc.y
                })
            }
            return label
            
        }, displayDelay: 2, mode: .translate) // show after bars animation
        
        // NOTE: If you need the labels from labelsLayer to stay at the same distance from the bars during zooming, i.e. that the space between them and the bars is not scaled, use mode: .custom and pass a custom transform block, in which you update manually the position. Similar to how it's done in e.g. NotificationsExample for the notifications views.
        
        // line layer
 //       let lineChartPoints = lineData.enumerated().map {index, tuple in ChartPoint(x: ChartAxisValueDouble(index), y: ChartAxisValueDouble(tuple.val))}
        let myLineChartPoints = [
            createChartPoint(dateStr: "01.10", percent: 15, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "02.10", percent: 23, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "03.10", percent: 20, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "04.10", percent: 17, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "05.10", percent: 28, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "06.10", percent: 23, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "07.10", percent: 19, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "08.10", percent: 45, readFormatter: readFormatter, displayFormatter: displayFormatter),
        ]
        let lineModel = ChartLineModel(chartPoints: myLineChartPoints, lineColor: UIColor.black, lineWidth: 2, animDuration: 2, animDelay: 2)
        let lineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel])
        
        // circles layer
        
        /*let circleViewGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            let color = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1)
            let circleView = ChartPointEllipseView(center: chartPointModel.screenLoc, diameter: 6)
            circleView.animDuration = 0.5
            circleView.fillColor = color
            return circleView
        }
        let lineCirclesLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: lineChartPoints, viewGenerator: circleViewGenerator, displayDelay: 1.5, delayBetweenItems: 0.05, mode: .translate)
        */
        
        // show a gap between positive and negative bar
        /*let dummyZeroYChartPoint = ChartPoint(x: ChartAxisValueDouble(0), y: ChartAxisValueDouble(0))
        let yZeroGapLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: [dummyZeroYChartPoint], viewGenerator: {(chartPointModel, layer, chart) -> UIView? in
            let height: CGFloat = 2
            let v = UIView(frame: CGRect(x: chart.contentView.frame.origin.x + 2, y: chartPointModel.screenLoc.y - height / 2, width: chart.contentView.frame.origin.x + chart.contentView.frame.height, height: height))
            v.backgroundColor = UIColor.white
            return v
        })*/
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                lineLayer,
                barsLayer,
                labelsLayer
                //yZeroGapLayer,
                //lineCirclesLayer
            ]
        )
        
        view.addSubview(chart.view)
        self.chart = chart
    }
    
    func createChartPoint(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
    }
    
    func createBar(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartBarModel {
        return ChartBarModel(constant: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter),axisValue1: ChartAxisValueDouble(0), axisValue2: ChartAxisValuePercent(percent), bgColor: UIColor.red.withAlphaComponent(0.8))
    }
    
    func createDateAxisValue(_ dateStr: String, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartAxisValue {
        let date = readFormatter.date(from: dateStr)!
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 45, rotationKeep: .top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    class ChartAxisValuePercent: ChartAxisValueDouble {
        override var description: String {
            return "\(formatter.string(from: NSNumber(value: scalar))!)%"
        }
    }
    
}
