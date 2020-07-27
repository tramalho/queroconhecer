//
//  Place.swift
//  QueroConhecer
//
//  Created by Thiago Antonio Ramalho on 09/07/20.
//  Copyright © 2020 Tramalho. All rights reserved.
//

import Foundation
import CoreLocation

struct Place: Codable {
    
    let name: String
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let address: String
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static func getFormattedAddress(with placemark: CLPlacemark) -> String {
        var address = ""
        
        if let street = placemark.thoroughfare {
            address += street
        }
        if let number = placemark.subThoroughfare {
            address += " \(number)"
        }
        if let neighborhood = placemark.subLocality {
            address += ", \(neighborhood)"
        }
        if let city = placemark.locality {
            address += "\n\(city)"
        }
        if let state = placemark.administrativeArea {
            address += " - \(state)"
        }
        if let postalCode = placemark.postalCode {
            address += "\nCEP:\(postalCode)"
        }
        if let country = placemark.country {
            address += "\n\(country)"
        }
        
        return address
    }
    
}

extension Place: Equatable {
    public static func == (lhs: Place, rhs: Place) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
