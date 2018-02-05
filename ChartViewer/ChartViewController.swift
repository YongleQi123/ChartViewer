import UIKit
import SwiftCharts
import PieCharts

class ChartViewController: UIViewController ,PieChartDelegate {
    func onSelected(slice: PieSlice, selected: Bool) {
        print("Selected: \(selected), slice: \(slice)")
    }
    
    
    fileprivate var chart: Chart? // arc

    let pieChartView: PieChart = PieChart(frame: CGRect(x: 0, y: -200, width: (UIScreen.main.bounds.width), height: (UIScreen.main.bounds.height)))
    fileprivate static let pieAlpha: CGFloat = 0.5
    let colors = [
        UIColor.yellow.withAlphaComponent(pieAlpha),
        UIColor.green.withAlphaComponent(pieAlpha),
        UIColor.purple.withAlphaComponent(pieAlpha),
        UIColor.cyan.withAlphaComponent(pieAlpha),
        UIColor.darkGray.withAlphaComponent(pieAlpha),
        UIColor.red.withAlphaComponent(pieAlpha),
        UIColor.magenta.withAlphaComponent(pieAlpha),
        UIColor.orange.withAlphaComponent(pieAlpha),
        UIColor.brown.withAlphaComponent(pieAlpha),
        UIColor.lightGray.withAlphaComponent(pieAlpha),
        UIColor.gray.withAlphaComponent(pieAlpha),
        ]
    fileprivate var currentColorIndex = 0
    
    @IBOutlet weak var myLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myLabel.text = "Hello World!"
        //MARK: Define label setings and date format
        
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont)
        
        let readFormatter = DateFormatter()
        readFormatter.dateFormat = "dd.MM.yyyy"
        
        let displayFormatter = DateFormatter()
        displayFormatter.dateFormat = "dd.MM"
        
        //MARK: The following part seems to be useless
        
        /*let date = {(str: String) -> Date in
            return readFormatter.date(from: str)!
        }
        
        let dateWithComponents = {(day: Int, month: Int, year: Int) -> Date in
            var components = DateComponents()
            components.day = day
            components.month = month
            components.year = year
            return calendar.date(from: components)!
        }
        
       func filler(_ date: Date) -> ChartAxisValueDate {
            let filler = ChartAxisValueDate(date: date, formatter: displayFormatter)
            filler.hidden = true
            return filler
        }*/
        
        //MARK: Give values to start date and end date in the defined format
        
        
        let calendar = Calendar.current
        let startStr = "01.12.2017"
        var startDate = readFormatter.date(from: startStr) // Should be connected to calendar
        let endStr = "20.02.2018"
        let endDate = readFormatter.date(from: endStr) // Shoule be connected to calendar
        var thisDate = Date()
        let currentStr = readFormatter.string(from: thisDate)
        let currentDate = readFormatter.date(from: currentStr)
        
        //MARK: Calculate data for target line and actual line
        
        let components = calendar.dateComponents([.day], from: startDate!, to: endDate!)
        let days = components.day
        let pastcomponents = calendar.dateComponents([.day], from: startDate!, to: currentDate!)
        let pastdays = pastcomponents.day! + 1
        let status = [Int](repeating:0, count: days!)
        var pastStatus = [Int](repeating:0, count:pastdays)
        var dateStr = [String]()
        
        var thisStr: String
        
        for i in 0...pastStatus.count-1 {
            if ( i % 7 != 0) && (i != 0) {
                pastStatus[i] = 1
            }
            thisDate = startDate!
            thisStr = readFormatter.string(from: thisDate)
            dateStr.append(thisStr)
            startDate = calendar.date(byAdding: .day, value: 1, to: startDate!)!
        } // Here only an example, should be connecte to the database
        
        var pastprogress = [Double](repeating:0, count: pastdays)
        
        var thisProgress: Double = 0
        var actualPoints=[ChartPoint]()
        var thisPoint: ChartPoint
        for i in 0...pastprogress.count-1 {
            thisProgress = 0
            for j in 0...i {
                thisProgress = Double(pastStatus[j])/Double(status.count)*Double(100) + thisProgress
            }
            pastprogress[i] = thisProgress
            thisPoint = createChartPoint(dateStr: dateStr[i], percent: pastprogress[i], readFormatter: readFormatter, displayFormatter: displayFormatter)
            actualPoints.append(thisPoint)
        }

        let targetPoints = [createChartPoint(dateStr: startStr, percent: 0, readFormatter: readFormatter, displayFormatter: displayFormatter),createChartPoint(dateStr: endStr, percent: 100,readFormatter: readFormatter, displayFormatter: displayFormatter)
        ]
        
        let currentPoint =  createChartPoint(dateStr: currentStr, percent: 0, readFormatter: readFormatter, displayFormatter: displayFormatter)
        
        let yValues = stride(from: 0, through: 100, by: 10).map {ChartAxisValuePercent($0, labelSettings: labelSettings)}
        let xValues = [createDateAxisValue(startStr, readFormatter: readFormatter, displayFormatter: displayFormatter),createDateAxisValue(currentStr, readFormatter: readFormatter, displayFormatter: displayFormatter),createDateAxisValue(endStr, readFormatter: readFormatter, displayFormatter: displayFormatter)]
        let currentValues = [createDateAxisValue(startStr, readFormatter: readFormatter, displayFormatter: displayFormatter),createDateAxisValue(currentStr, readFormatter: readFormatter, displayFormatter: displayFormatter)]
        
        let xModel = ChartAxisModel(axisValues: xValues)
        let yModel = ChartAxisModel(axisValues: yValues)
        let currentModel = ChartAxisModel(axisValues: currentValues)
        
        let chartFrame = ExamplesDefaults.chartFrame(view.bounds)
        var chartSettings = ExamplesDefaults.chartSettingsWithPanZoom

        // Set a fixed (horizontal) scrollable area 2x than the original width, with zooming disabled.
        
        chartSettings.zoomPan.maxZoomX = 1
        chartSettings.zoomPan.minZoomX = 1
        chartSettings.zoomPan.minZoomY = 1
        chartSettings.zoomPan.maxZoomY = 1
 
        //MARK: Create coordinate and chart space
        
        let coordsSpace = ChartCoordsSpaceLeftBottomSingleAxis(chartSettings: chartSettings, chartFrame: chartFrame, xModel: xModel, yModel: yModel)
        
        let myCoordsSpaceInitializer = ChartCoordsSpace(chartSettings: chartSettings, chartSize: chartFrame.size, yLowModels: [yModel], xLowModels: [currentModel])
        let myAxisLayer = myCoordsSpaceInitializer.xLowAxesLayers[0]
        
        let (xAxisLayer, yAxisLayer, innerFrame) = (coordsSpace.xAxisLayer, coordsSpace.yAxisLayer, coordsSpace.chartInnerFrame)
        
        let lineModel1 = ChartLineModel(chartPoints: targetPoints, lineColor: UIColor.blue, lineWidth: 1, animDuration: 1, animDelay: 0)
        let lineModel2 = ChartLineModel(chartPoints: actualPoints, lineColor: UIColor.red, lineWidth: 3, animDuration: 1, animDelay: 0)
       
    
        // Create layer for current point
        let targetGenerator = {(chartPointModel: ChartPointLayerModel, layer: ChartPointsLayer, chart: Chart) -> UIView? in
            if chartPointModel.index != actualPoints.count - 1 {
                return nil
            }
            return ChartPointTargetingView(chartPoint: chartPointModel.chartPoint, screenLoc: chartPointModel.screenLoc, animDuration: 0.5, animDelay: 5, layer: layer, chart: chart)
        }
        
        let currentPointLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: actualPoints, viewGenerator: targetGenerator)
        let targetPointLayer = ChartPointsViewsLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: targetPoints, viewGenerator: targetGenerator)
        
        //MARK: Create line layer and area layers
        
        let chartPointsLineLayer = ChartPointsLineLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, lineModels: [lineModel1,lineModel2], pathGenerator: CatmullPathGenerator()) //
        // CatmullPathGenerator()
        
        // Create the layer for target filled area and actual filled area
        let c1 = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.6)
        let c2 = UIColor(red: 0.9, green: 0.1, blue: 0.1, alpha: 0.4)
        let targetAreaLayer = ChartPointsAreaLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: targetPoints, areaColors: [c1], animDuration: 1, animDelay: 0, addContainerPoints: true, pathGenerator: chartPointsLineLayer.pathGenerator)
        // Need extra points to fulfill the background
        var myPoints = actualPoints
        myPoints.append(currentPoint)
        let generator = StraightLinePathGenerator()
        let actualAreaLayer = ChartPointsAreaLayer(xAxis: xAxisLayer.axis, yAxis: yAxisLayer.axis, chartPoints: myPoints, areaColors: [c2], animDuration: 1, animDelay: 0, addContainerPoints: true,pathGenerator: generator)
        
        let chart = Chart(
            frame: chartFrame,
            innerFrame: innerFrame,
            settings: chartSettings,
            layers: [
                xAxisLayer,
                yAxisLayer,
                chartPointsLineLayer,
                targetAreaLayer,
                actualAreaLayer,
                currentPointLayer,
                targetPointLayer
                ]
        )
        
        
        
        view.addSubview(chart.view)
        view.addSubview(pieChartView)
        self.chart = chart
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //  chartView.layers = [createCustomViewsLayer(), createTextLayer()]
        pieChartView.delegate = self
        pieChartView.models = createModels() // order is important - models have to be set at the end
    }
    
    
    // MARK: - Models
    
    fileprivate func createModels() -> [PieSliceModel] {
        
        let models = [
            PieSliceModel(value: 10, color: colors[3]),
            PieSliceModel(value: 3, color: colors[4])
        ]
        
        currentColorIndex = models.count
        return models
    }
    
    
    func createChartPoint(dateStr: String, percent: Double, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartPoint {
        return ChartPoint(x: createDateAxisValue(dateStr, readFormatter: readFormatter, displayFormatter: displayFormatter), y: ChartAxisValuePercent(percent))
    }
    
    
    func createDateAxisValue(_ dateStr: String, readFormatter: DateFormatter, displayFormatter: DateFormatter) -> ChartAxisValue {
        let date = readFormatter.date(from: dateStr)!
        let labelSettings = ChartLabelSettings(font: ExamplesDefaults.labelFont, rotation: 0, rotationKeep: .top)
        return ChartAxisValueDate(date: date, formatter: displayFormatter, labelSettings: labelSettings)
    }
    
    class ChartAxisValuePercent: ChartAxisValueDouble {
        override var description: String {
            return "\(formatter.string(from: NSNumber(value: scalar))!)%"
        }
    }
    
    class Dates{
        static func printDatesBetweenInterval(_ startDate: Date, _ endDate: Date) {
            var startDate = startDate
            let calendar = Calendar.current
            
            let fmt = DateFormatter()
            fmt.dateFormat = "dd.MM.yyyy"
            
            while startDate <= endDate {
                print(fmt.string(from: startDate))
                startDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
            }
        }
        
        static func dateFromString(_ dateString: String) -> Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            return dateFormatter.date(from: dateString)!
        }
    }
   
}
