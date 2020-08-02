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
        addToMap()
    }
    
    func addToMap() {
        
        searchBar.isHidden = true
        InfoSectionView.isHidden = true
        
        for place in places {
            let annotation = MKPointAnnotation()
            annotation.coordinate = place.coordinate
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
