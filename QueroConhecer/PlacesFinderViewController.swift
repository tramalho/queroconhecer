//
//  PlacesFinderViewController.swift
//  QueroConhecer
//
//  Created by Thiago Antonio Ramalho on 04/07/20.
//  Copyright © 2020 Tramalho. All rights reserved.
//

import UIKit
import MapKit

class PlacesFinderViewController: UIViewController {

    @IBOutlet weak var textfieldCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewLoading: UIView!
    @IBOutlet weak var activeIndicatorLoading: UIActivityIndicatorView!
    
    private var place: Place? = nil
    
    private enum PlaceFinderMessageType {
        case confirmation(String)
        case error(String)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        if let address = textfieldCity.text {
            textfieldCity.resignFirstResponder()
            loading(show: true)
            let geo = CLGeocoder()
            geo.geocodeAddressString(address) { (placemarks, error) in
                self.loading(show: false)
                
                if error != nil {
                    self.showMessage(type: .error("Erro ao realizar a busca"))
                    return
                }
                
                if !self.savePlace(with: placemarks?.first) {
                    self.showMessage(type: .error("Local não encontrado"))
                }
            }
        }
    }

    private func savePlace(with placemark: CLPlacemark?) -> Bool {
        
        guard let placemark = placemark, let coord = placemark.location?.coordinate else {
            return false
        }

        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        
        place = Place(name: name, latitude: coord.latitude, longitude: coord.longitude, address: address)
        let region = MKCoordinateRegion(center: coord, latitudinalMeters: 200, longitudinalMeters: 200)
        mapView.setRegion(region, animated: true)
        
        showMessage(type: .confirmation(name))
        
        return true
    }
    
    private func showMessage(type: PlaceFinderMessageType) {
        let title: String, message: String
        var confirmation = false
        switch type {
        case .confirmation(let name):
            title = "Local Encontrado"
            message = "Deseja adicionar \(name)?"
            confirmation = true
        case .error(let errorMessage):
            title = "Erro"
            message = errorMessage
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let  cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        let actionAction = UIAlertAction(title: "OK", style: .default) { (action) in
            
        }
        
        alert.addAction(cancelAction)
        
        if confirmation {
            alert.addAction(actionAction)
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    private func loading(show: Bool) {
    
        self.viewLoading.isHidden = !show
        
        if(show) {
            self.activeIndicatorLoading.startAnimating()
        } else {
            self.activeIndicatorLoading.stopAnimating()
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
