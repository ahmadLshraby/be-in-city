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

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()   // instance
    let authorizationStatus = CLLocationManager.authorizationStatus() // to check authorization
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTab()
    }
    
    func addDoubleTab() {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))  // define tap gesture
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self   // confirm to work
        mapView.addGestureRecognizer(doubleTap)   // add to view
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
    
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()   // if there was no pin it consider that your current location is a default annotation
        
        // add touchPoint to convert the dropped pin to the exact location
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)   // get locations X, Y of the view
        // convert to real GPS location
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(touchCoordinate)   // get long, lat
        // instance
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
        mapView.addAnnotation(annotation)   // show dropped pin on map
        // to center the map on the dropped pin
                    let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    // To remove the old dropped pin when we drop a new one
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
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
