
import SwiftUI
import MapKit
import UIKit

struct MapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    @EnvironmentObject var sessionViewModel: SessionViewModel
    static let view = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        
        MapView.view.delegate = context.coordinator
        MapView.view.setRegion(sessionViewModel.region, animated: true)
        
        MapView.view.showsUserLocation = true
        MapView.view.userTrackingMode = .followWithHeading
        MapView.view.isUserInteractionEnabled = false
        return MapView.view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if sessionViewModel.status == .running {
            
            MapView.view.removeOverlays(uiView.overlays)
            
            var locations = [CLLocationCoordinate2D]()
            sessionViewModel.session.intervals.forEach { interval in
                locations.append(contentsOf: interval.locations.compactMap { location -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                })
            }
            let polyline = MKPolyline(coordinates: locations, count: locations.count)
            
            MapView.view.addOverlay(polyline)
            
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
