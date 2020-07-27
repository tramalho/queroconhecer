//
//  PlacesTableViewController.swift
//  QueroConhecer
//
//  Created by Thiago Antonio Ramalho on 04/07/20.
//  Copyright © 2020 Tramalho. All rights reserved.
//

import UIKit

class PlacesTableViewController: UITableViewController {

    private let PLACE_KEY = "places"
    private var places: [Place] = []
    private let ud = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPlaces()
    }
    
    private func loadPlaces() {
        if let placeData = ud.data(forKey: PLACE_KEY) {
            if let decodedResult = try? JSONDecoder().decode([Place].self, from: placeData) {
                self.places = decodedResult
                tableView.reloadData()
            }
        }
    }
    
    private func savePlaces() {
        if let json = try? JSONEncoder().encode(places) {
            ud.set(json, forKey: PLACE_KEY)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findSegue" {
            let vc = segue.destination as! PlacesFinderViewController
            vc.delegate = self
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let place = places[indexPath.row]
        
        cell.textLabel?.text = place.name
        
        return cell
    }
}

extension PlacesTableViewController: PlaceFinderDelegate {
    func addPlace(_ place: Place) {
        if !places.contains(place) {
            places.append(place)
            savePlaces()
            tableView.reloadData()
        }
    }
}
