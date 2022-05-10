
import SwiftUI
import MapKit
import UIKit

struct MapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    @EnvironmentObject var manager: SessionViewModel
    static let mapView = MKMapView()

    func makeUIView(context: Context) -> MKMapView {
        
        MapView.mapView.delegate = context.coordinator
        MapView.mapView.setRegion(manager.region, animated: true)
        
        MapView.mapView.showsUserLocation = true
        MapView.mapView.userTrackingMode = .followWithHeading
        MapView.mapView.isUserInteractionEnabled = false
        return MapView.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if manager.status == .running {
            let polyline = MKPolyline(coordinates: manager.session.locations.compactMap { location -> CLLocationCoordinate2D in
                return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            }, count: manager.session.locations.count)
            uiView.addOverlay(polyline)
        }
        else if manager.status == .stop {
            uiView.removeOverlays(uiView.overlays)
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
                renderer.lineWidth = 7
                return renderer
            }
            
            return MKOverlayRenderer()
        }
    }
    
}
