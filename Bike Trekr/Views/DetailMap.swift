import SwiftUI
import MapKit

struct DetailMapView: UIViewRepresentable {
    
    let locations: [Location]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.isUserInteractionEnabled = true
        let range = MKMapView.CameraZoomRange(minCenterCoordinateDistance: 2500, maxCenterCoordinateDistance: 10000)
        mapView.cameraZoomRange = range
        
        let coordinates = locations.sorted(by: {
            $0.timestamp < $1.timestamp
        }).compactMap { location -> CLLocationCoordinate2D in
            return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        }
        
        if let first = coordinates.first {
            mapView.region = MKCoordinateRegion(center: first, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            let start = Point(bounds: MKMapRect(origin: .init(first), size: MKMapSize(width: 20, height: 20)), color: .blue)
            mapView.addOverlay(start, level: .aboveLabels)
        }
        
        if let last = coordinates.last {
            let finish = Point(bounds: MKMapRect(origin: .init(last), size: MKMapSize(width: 20, height: 20)), color: .red)
            mapView.addOverlay(finish, level: .aboveLabels)
        }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        
        mapView.addOverlay(polyline, level: .aboveRoads)
        
        setUpAnnotaions(with: mapView)
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func setUpAnnotaions(with view: MKMapView) {
        let coordinates = locations.sorted(by: {
            $0.timestamp < $1.timestamp
        }).compactMap { location -> CLLocation in
            return CLLocation(latitude: location.latitude, longitude: location.longitude)
        }
        
        
        var distance: Double = 0
        
        guard var prev = coordinates.first else { return }
        
        for coordinate in coordinates {
            distance += prev.distance(from: coordinate) / 1000
            prev = coordinate
            
            if (distance.truncatingRemainder(dividingBy: 1) <= 0.01 || distance.truncatingRemainder(dividingBy: 1) >= 0.99) && distance > 0.01 {
                let annotation = DistanceAnnotation(coordinate: coordinate.coordinate, title: "\(Int(round(distance))) km")
                view.addAnnotation(annotation)
                let point = Point(bounds: MKMapRect(origin: .init(coordinate.coordinate), size: MKMapSize(width: 15, height: 15)), color: .yellow)
                view.addOverlay(point, level: .aboveLabels)
            }
        }
        
    }
    
}

class Coordinator: NSObject, MKMapViewDelegate {
    var parent: DetailMapView
    
    init(_ parent: DetailMapView) {
        self.parent = parent
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 7
            return renderer
        }
        
        if let point = overlay as? Point {
            let circle = MKCircle(center: point.coordinate, radius: point.boundingMapRect.width)
            let renderer = MKCircleRenderer(circle: circle)
            renderer.strokeColor = .gray
            renderer.lineWidth = 3
            renderer.fillColor = point.color
            return renderer
        }
        return MKOverlayRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKAnnotationView()
        guard let annotation = annotation as? DistanceAnnotation else {return nil}
        let identifier = "distance"
        if let dequedView = mapView.dequeueReusableAnnotationView(
            withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            annotationView = dequedView
        } else{
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        let altitudeVw = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        let lblTitle = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
        lblTitle.font = lblTitle.font.withSize(10)
        lblTitle.text = annotation.title
        lblTitle.numberOfLines = 10
        lblTitle.font = UIFont.boldSystemFont(ofSize: 18)
        lblTitle.textAlignment = NSTextAlignment.center
        lblTitle.textColor = UIColor.black
        lblTitle.backgroundColor = UIColor.clear
        altitudeVw.layer.cornerRadius = 6.0
        altitudeVw.backgroundColor = .white
        altitudeVw.addSubview(lblTitle)
        annotationView.addSubview(altitudeVw)
        return annotationView
    }
    
}

class DistanceAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, title:String){
        self.coordinate = coordinate
        self.title = title
    }
}


class Point: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    
    var boundingMapRect: MKMapRect
    
    var color: UIColor
    
    init(bounds: MKMapRect, color: UIColor) {
        boundingMapRect = bounds
        let region = MKCoordinateRegion(bounds)
        coordinate = region.center
        self.color = color
    }
    
}
