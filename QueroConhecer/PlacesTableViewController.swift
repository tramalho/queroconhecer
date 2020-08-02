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
    private var lbNoPlaces: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lbNoPlaces = UILabel()
        lbNoPlaces?.text = "Cadastre um novo local \nclicando no botão +"
        lbNoPlaces?.textAlignment = .center
        lbNoPlaces?.numberOfLines = 0
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
    
    @objc private func showAll() {
        performSegue(withIdentifier: "mapSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "findSegue" {
            let vc = segue.destination as! PlacesFinderViewController
            vc.delegate = self
        } else {
            let vc = segue.destination as! MapViewController
        
            if let place = sender as? Place {
                vc.places = [place]
            } else {
                vc.places = places
            }
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        navigationItem.leftBarButtonItem = nil
        tableView.backgroundView = lbNoPlaces
        
        if places.count > 0 {
            let btnAll = UIBarButtonItem(title: "Mostrar Todos", style: .plain, target: self, action: #selector(showAll))
            navigationItem.leftBarButtonItem = btnAll
            tableView.backgroundView = nil
        }
        
        return places.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let place = places[indexPath.row]
        
        cell.textLabel?.text = place.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        performSegue(withIdentifier: "mapSegue", sender: place)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            places.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            savePlaces()
        }
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
