
import SwiftUI
import MapKit
import UIKit

struct MapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    @EnvironmentObject var sessionViewModel: SessionViewModel
    static let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        
        MapView.mapView.delegate = context.coordinator
        MapView.mapView.setRegion(sessionViewModel.region, animated: true)
        
        MapView.mapView.showsUserLocation = true
        MapView.mapView.userTrackingMode = .followWithHeading
        MapView.mapView.isUserInteractionEnabled = false
        return MapView.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if sessionViewModel.status == .running {
            
            MapView.mapView.removeOverlays(uiView.overlays)
            
            var locations = [CLLocationCoordinate2D]()
            sessionViewModel.session.intervals.forEach { interval in
                locations.append(contentsOf: interval.locations.compactMap { location -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                })
            }
            let polyline = MKPolyline(coordinates: locations, count: locations.count)
            
            MapView.mapView.addOverlay(polyline)
            
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            
            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor.red
                renderer.lineWidth = 5
                return renderer
            }
            
            return MKOverlayRenderer()
        }
    }
    
}
