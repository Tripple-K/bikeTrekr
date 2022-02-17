//
//  MapView.swift
//  Bike Trekr
//
//  Created by Ivan Romancev on 05.10.2021.
//

import SwiftUI
import MapKit
import UIKit

struct MapView: UIViewRepresentable {
    
    typealias UIViewType = MKMapView
    @ObservedObject var manager: LocationManager

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        mapView.delegate = context.coordinator
        mapView.setRegion(manager.region, animated: true)
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        mapView.isUserInteractionEnabled = false
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        if manager.tracking && !manager.paused {
            let polyline = MKPolyline(coordinates: manager.locations2d, count: manager.locations2d.count)
//            uiView.removeOverlays(uiView.overlays)
            uiView.addOverlay(polyline)
        }
        else if manager.finished {
            uiView.removeOverlays(uiView.overlays)
            manager.finished = false
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
