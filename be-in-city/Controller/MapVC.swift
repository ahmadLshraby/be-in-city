//
//  MapVC.swift
//  be-in-city
//
//  Created by sHiKoOo on 2/19/19.
//  Copyright © 2019 sHiKoOo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()   // instance
    let authorizationStatus = CLLocationManager.authorizationStatus() // to check authorization
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
    }
    
    @IBAction func centerMapBtn(_ sender: UIButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    


}


extension MapVC: MKMapViewDelegate {
    // get the location of user and center it on the view
    func centerMapOnUserLocation() {
        if let coordinate = locationManager.location?.coordinate {
            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
            mapView.setRegion(coordinateRegion, animated: true)
        }else {
            return
        }
    }
}

extension MapVC: CLLocationManagerDelegate {
    // to check if app is authorized to use location
    func configureLocationServices() {
        if authorizationStatus == .notDetermined { // user doesn't choose allow or deny access location
            locationManager.requestAlwaysAuthorization()
        }else {   // may be allowed or denied
            return
        }
    }
    // when allow authorization we center the map
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        centerMapOnUserLocation()
    }
}
