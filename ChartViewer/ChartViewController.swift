import UIKit
import SwiftCharts

class ChartViewController: UIViewController {
    
    fileprivate var chart: Chart? // arc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        var readFormatter = DateFormatter()
        readFormatter.dateFormat = "dd"
        
        var displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd"
        
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
        
   /*     func filler(_ date: Date) -> ChartAxisValueDate {
            let filler = ChartAxisValueDate(date: date, formatter: displayFormatter)
            filler.hidden = true
            return filler
        } */
        
        let chartPoints1 = [
            createChartPoint(dateStr: "01", percent: 0, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "02", percent: 10, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "03", percent: 20, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "04", percent: 30, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "05", percent: 40, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "06", percent: 50, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "07", percent: 60, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "08", percent: 70, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "09", percent: 80, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "10", percent: 90, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "11", percent: 100, readFormatter: readFormatter, displayFormatter: displayFormatter)
            
        ]
        
        let chartPoints2 = [
            createChartPoint(dateStr: "01", percent: 0, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "02", percent: 10, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "03", percent: 10, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "04", percent: 20, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "05", percent: 20, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "06", percent: 30, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "07", percent: 30, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "08", percent: 30, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "09", percent: 40, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "10", percent: 50, readFormatter: readFormatter, displayFormatter: displayFormatter),
            createChartPoint(dateStr: "11", percent: 60, readFormatter: readFormatter, displayFormatter: displayFormatter)
        ]
        
        let yValues = stride(from: 0, through: 100, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        
        let xValues = [
            createDateAxisValue("01", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("02", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("03", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("04", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("05", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("06", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("07", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("08", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("09", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("10", readFormatter: readFormatter, displayFormatter: displayFormatter),
            createDateAxisValue("11", readFormatter: readFormatter, displayFormatter: displayFormatter)
        ]
        
        let xModel = ChartAxisModel(axisValues: xValues)
        //let yModel = ChartAxisModel(axisValues: yValues, axisTitleLabel: ChartAxisLabel(text: "Progress", settings: labelSettings.defaultVertical()))
        let yModel = ChartAxisModel(axisValues: yValues)
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        //chartSettings.trailing = 20
        
        /*
        let chartraFrame = ExamplesDefaults.chartFrame(view.bounds)
        
        let chartSettings = ExamplesDefaults.chartSettingsWithPanZoom
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
         */
        
        // Set a fixed (horizontal) scrollable area 2x than the original width, with zooming disabled.
        /*
        chartSettings.zoomPan.maxZoomX = 1
        chartSettings.zoomPan.minZoomX = 1
        chartSettings.zoomPan.minZoomY = 0.5
        chartSettings.zoomPan.maxZoomY = 2
 */
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel1 = ChartLineModel(chartPoints: chartPoints1, lineColor: UIColor.blue, lineWidth: 1, animDuration: 5, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: chartPoints2, lineColor: UIColor.red, lineWidth: 3, animDuration: 5, animDelay: 0)

        // delayInit parameter is needed by some layers for initial zoom level to work correctly. Setting it to true allows to trigger drawing of layer manually (in this case, after the chart is initialized). This obviously needs improvement. For now it's necessary.
        
        // let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel1,lineModel2], delayInit: true)
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel1,lineModel2], pathGenerator: CatmullPathGenerator()) // || CubicLinePathGenerator
        
        //let guidelinesLayerSettings = ChartGuideLinesLayerSettings(linesColor: UIColor.black, linesWidth: 0.3)
        //let guidelinesLayer = ChartGuideLinesLayer(xAxisLayer: xAxisLayer, yAxisLayer: yAxisLayer, settings: guidelinesLayerSettings)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                //guidelinesLayer,
                chartPointsLineLayer]
        )
        
        view.addSubview(chart.view)
        
        
        // Set scrollable area 2x than the original width, with zooming enabled. This can also be combined with e.g. minZoomX to allow only larger zooming levels.
            chart.zoom(scaleX: 1, scaleY: 1, centerX: 0, centerY: 0)
        
        // Now that the chart is zoomed (either with minZoom setting or programmatic zooming), trigger drawing of the line layer. Important: This requires delayInit paramter in line layer to be set to true.
        chartPointsLineLayer.initScreenLines(chart)
        
        
        self.chart = chart
    }
    
    func createChartPoint(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
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
