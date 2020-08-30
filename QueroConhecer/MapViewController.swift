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
    
    enum MapMessageType {
        case errorRoute
        case authWarning
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var InfoSectionView: UIView!
    
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place] = []
    private var poi: [MKAnnotation] = []
    private lazy var locationManager: CLLocationManager = CLLocationManager()
    
    @IBAction func showRoute(_ sender: Any) {
    }
    
    @IBAction func showSearchBar(_ sender: Any) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        requestUserLocacationAuth()
    }
    
    func setup() {
        locationManager.delegate = self
        mapView.delegate = self
        searchBar.delegate = self
        searchBar.isHidden = true
        InfoSectionView.isHidden = true
        mapView.mapType = .mutedStandard
        
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
    
    private func requestUserLocacationAuth() {
        guard CLLocationManager.locationServicesEnabled() else { return }
        
        switch CLLocationManager.authorizationStatus() {
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.addSubview(locationButton())
            break
        case .denied:
            showMessage(type: .authWarning)
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        default:
            break
        }
    }
    
    private func locationButton() -> MKUserTrackingButton {
        let button = MKUserTrackingButton(mapView: mapView)
        button.frame.origin.x = 10
        button.frame.origin.y = 10
        button.layer.borderColor = UIColor(named: "main")?.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.backgroundColor = .white
        
        return button
    }
    
    private func showMessage(type: MapMessageType) {
        
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

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            
            guard let response = response else {
                self.loading.stopAnimating()
                return
            }
            self.addNewPoi(response: response)
            self.loading.stopAnimating()
        }
    }
    
    private func addNewPoi(response: MKLocalSearch.Response) {
        self.mapView.removeAnnotations(self.poi)
        self.poi.removeAll()
        for item in response.mapItems {
            let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
            annotation.title = item.name
            annotation.subtitle = item.phoneNumber
            annotation.address = Place.getFormattedAddress(with: item.placemark)
            self.poi.append(annotation)
        }
        self.mapView.addAnnotations(self.poi)
        self.mapView.showAnnotations(self.poi, animated: true)
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            mapView.showsUserLocation = true
            mapView.addSubview(locationButton())
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last ?? "without location")
    }
}

