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
                guard let place = placemarks?.first else {return}
                print(Place.getFormattedAddress(with: place))
            }
        }
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
