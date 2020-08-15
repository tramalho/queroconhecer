//
//  MapViewController.swift
//  QueroConhecer
//
//  Created by Thiago Antonio Ramalho on 07/07/20.
//  Copyright © 2020 Tramalho. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var InfoSectionView: UIView!
    
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addToMap()
    }
    
    func addToMap() {
        
        searchBar.isHidden = true
        InfoSectionView.isHidden = true
        
        for place in places {
            let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
            annotation.address = place.address
            annotation.title = place.name
            mapView.addAnnotation(annotation)
        }
        
        title = "Meus Lugares"
        
        if places.count == 1 {
            title = places[0].name
        }
        
        mapView.showAnnotations(mapView.annotations, animated: true)
    }

    @IBAction func showRoute(_ sender: Any) {
    }
    
    
    @IBAction func showSearchBar(_ sender: Any) {
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard annotation is PlaceAnnotation else { return nil }
        
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        
        if annotationView == nil  {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph") : UIImage(named: "poiGlyph")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
}
