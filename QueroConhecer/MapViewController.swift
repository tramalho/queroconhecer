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
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func showRoute(_ sender: Any) {
    }
    
    
    @IBAction func showSearchBar(_ sender: Any) {
    }
}
