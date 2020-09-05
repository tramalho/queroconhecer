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
    private var selectedAnnotation: PlaceAnnotation?
    
    @IBAction func showRoute(_ sender: Any) {
        if CLLocationManager.authorizationStatus() != .authorizedWhenInUse {
            showMessage(type: .authWarning)
            return
        }
        
        if let selected = selectedAnnotation?.coordinate, let actual = locationManager.location?.coordinate {
            let request = MKDirections.Request()
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: selected))
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: actual))
            
            let directions = MKDirections(request: request)
            directions.calculate { (response, error) in
                
                guard error == nil else { self.showMessage(type: .errorRoute); return }
                
                if let route = response?.routes.first {
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addOverlay(route.polyline, level: .aboveRoads)
                    
                    var annotations = self.mapView.annotations.filter({!($0 is PlaceAnnotation)})
                    annotations.append(self.selectedAnnotation!)
                    self.mapView.showAnnotations(annotations, animated: true)
                }
            }
        }
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
        
        var message = "Não foi possível traçar essa rota"
        var title = "Erro"
        let  cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        var  confirmAction: UIAlertAction? = nil
        
        if(.authWarning == type) {
            title = "Aviso"
            message = "Para utilizar os recursos de localização você precisa habilitar a permissão na tela de ajustes"
            
            confirmAction = UIAlertAction(title: "Ir a Ajustes", style: .default) { (action) in
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            }
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(cancelAction)
        
        if let confirmAction = confirmAction {
            alert.addAction(confirmAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func showInfo(annotation: PlaceAnnotation) {
        labelName.text = annotation.title
        labelAddress.text = annotation.address
        InfoSectionView.isHidden = false
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
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if view.annotation is PlaceAnnotation, let coordinate = view.annotation?.coordinate {
            selectedAnnotation = (view.annotation as! PlaceAnnotation)
            let camera = MKMapCamera()
            camera.centerCoordinate = coordinate
            camera.pitch = 80
            camera.altitude = 100
            mapView.setCamera(camera, animated: true)
            showInfo(annotation: selectedAnnotation!)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if overlay is MKPolyline {
            let mkOverlayRenderer = MKPolylineRenderer(overlay: overlay)
            mkOverlayRenderer.strokeColor = UIColor(named: "main")?.withAlphaComponent(0.8)
            mkOverlayRenderer.lineWidth = 4.0
            return mkOverlayRenderer
        }
        
        return MKOverlayRenderer(overlay: overlay)
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

