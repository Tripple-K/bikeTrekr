
import Charts
import SwiftUI



struct BarChart: UIViewRepresentable {
    
    let entries: [BarChartDataEntry]
    let chart = BarChartView()
    
    let indexAxisValues: [String]
    
    func makeUIView(context: Context) -> BarChartView {
        chart.delegate = context.coordinator
        let marker = Marker()
        marker.chartView = chart
        chart.marker = marker
        return chart
    }
    
    func updateUIView(_ uiView: BarChartView, context: Context) {
        let dataSet = BarChartDataSet(entries: entries)
        dataSet.label = nil
        uiView.rightAxis.enabled = false
        uiView.leftAxis.enabled = false
        uiView.setScaleEnabled(false)
        uiView.noDataTextColor = .red
        uiView.data = BarChartData(dataSet: dataSet)
        uiView.legend.enabled = false
        uiView.notifyDataSetChanged()
        uiView.animate(yAxisDuration: 0.5)
        formatDataSet(dataSet: dataSet)
        formatXAxis(xAxis: uiView.xAxis)
        
    }
    
    func formatXAxis(xAxis: XAxis) {
        xAxis.valueFormatter = IndexAxisValueFormatter(values: indexAxisValues)
        xAxis.granularity = 1
        xAxis.drawGridLinesEnabled = false
        xAxis.drawAxisLineEnabled = false
        xAxis.setLabelCount(indexAxisValues.count, force: false)
        xAxis.resetCustomAxisMin()
        xAxis.labelPosition = .bottom
    }
    
    func formatDataSet(dataSet: BarChartDataSet) {
        dataSet.colors = [.red]
        dataSet.drawValuesEnabled = false
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    
    class Coordinator: NSObject, ChartViewDelegate {
        
        var parent: BarChart
        
        init(_ parent: BarChart) {
            self.parent = parent
        }
        
    }
    
    
}



class Marker: MarkerView {
    private var text = String()
    
    private let drawAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.boldSystemFont(ofSize: 18),
        .foregroundColor: UIColor.white,
    ]
    
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        text = String(format: "%.2f", entry.y)
    }
    
    override func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        
        let sizeForDrawing = text.size(withAttributes: drawAttributes)
        bounds.size = CGSize(width: sizeForDrawing.width * 1.5, height: sizeForDrawing.height * 2)
        offset = CGPoint(x: -sizeForDrawing.width * 0.75, y: -sizeForDrawing.height * 2 - 10)
        backgroundColor = .darkGray
        layer.cornerRadius = 7
        let offset = offsetForDrawing(atPoint: point)
        let originPoint = CGPoint(x: point.x + offset.x + sizeForDrawing.width * 0.5, y: point.y + offset.y + sizeForDrawing.height)
        let rectForText = CGRect(origin: originPoint, size: sizeForDrawing)
        drawText(text: text, rect: rectForText, withAttributes: drawAttributes)
    }
    
    private func drawText(text: String, rect: CGRect, withAttributes attributes: [NSAttributedString.Key: Any]? = nil) {
        let size = bounds.size
        let centeredRect = CGRect(
            x: rect.origin.x + (rect.size.width - size.width) / 2,
            y: rect.origin.y + (rect.size.height - size.height) / 2,
            width: size.width,
            height: size.height
        )
        text.draw(in: centeredRect, withAttributes: attributes)
    }
}



struct BarChart_Previews: PreviewProvider {
    @State static var entries: [BarChartDataEntry] = [
        BarChartDataEntry(x: 0, y: 10),
        BarChartDataEntry(x: 1, y: 10),
        BarChartDataEntry(x: 2, y: 10),
        BarChartDataEntry(x: 3, y: 10),
        BarChartDataEntry(x: 4, y: 10),
        BarChartDataEntry(x: 5, y: 10),
        BarChartDataEntry(x: 6, y: 10),
        BarChartDataEntry(x: 7, y: 10),
        BarChartDataEntry(x: 8, y: 10),
        BarChartDataEntry(x: 9, y: 10),
        BarChartDataEntry(x: 10, y: 10),
        BarChartDataEntry(x: 11, y: 10),
    ]
    static var previews: some View {
        BarChart(entries: entries, indexAxisValues: Calendar.current.shortMonthSymbols)
    }
}


