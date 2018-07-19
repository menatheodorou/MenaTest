//
//  RestaurantListViewController.swift
//  MenaTest
//
//  Created by Mena on 7/19/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit
import CoreLocation
import CoreStore
import Hero

class RestaurantListViewController: BaseViewController {
    
    let locationManager = CLLocationManager()
    var userLocation: CLLocation?
    var isLocationInitialized = false
    var venueItems: [VenueItem] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func setupUI() {
        tableView.register(UINib(nibName: "RestaurantCell", bundle: nil), forCellReuseIdentifier: "RestaurantCell")
        tableView.tableFooterView = UIView()
        
        loadRestaurants()
    }
    
    func loadRestaurants() {
        if let items = CoreStore.fetchAll(From<VenueItem>(), OrderBy<VenueItem>(.ascending("venueName"))) {
            venueItems = items
        }
        tableView.reloadData()
    }
    
    func fetchRestaurants() {
        guard let latitude = userLocation?.coordinate.latitude, let longitude = userLocation?.coordinate.longitude else { return }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        // 40.76336, -73.98287
        VenueDataModel.shared.loadVenues(latitude, longitude) { (error) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            if let error = error {
                print(error)
            } else {
                self.loadRestaurants()
            }
        }
    }
    
}

extension RestaurantListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last,
            CLLocationCoordinate2DIsValid(newLocation.coordinate) else {
                return
        }
        
        self.userLocation = newLocation
        
        if isLocationInitialized == false {
            fetchRestaurants()
            isLocationInitialized = true
        }
    }

}

extension RestaurantListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venueItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell

        cell.nameLabel.text = venueItems[indexPath.row].venueName
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let restaurantDetailVC = storyboard?.instantiateViewController(withIdentifier: "RestaurantDetailVC") as! RestaurantDetailViewController
        restaurantDetailVC.venueItem = venueItems[indexPath.row]
        present(restaurantDetailVC, animated: true, completion: nil)
    }
}
