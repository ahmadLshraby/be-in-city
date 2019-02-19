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

    @IBOutlet weak var pullUpView: UIView!
    @IBOutlet weak var pullUpViewHeightCons: NSLayoutConstraint!
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()   // instance
    let authorizationStatus = CLLocationManager.authorizationStatus() // to check authorization
    let regionRadius: Double = 1000
    
    var screenSize = UIScreen.main.bounds   // to use it to define the spinner position
    var spinner: UIActivityIndicatorView?   // can instatiate it when we want in a func
    var progressLbl: UILabel?
    
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
    
    // to  pullUpView the UIView pf the photos that is hidden , we call it when we drop a pin
    func animateViewUp() {
        pullUpViewHeightCons.constant = 300   // update constrains
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()   // redraw the screen with the changes
        }
    }
    
    // to dismiss pullUpView when swip down
    func addSwipe() {
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down
        pullUpView.addGestureRecognizer(swipe)
    }
    @objc func animateViewDown() {
        pullUpViewHeightCons.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func addSpinner() {
        spinner = UIActivityIndicatorView()   // instatiate it
        // position ( x= half screen width - half spinner (to align it), y= pullUpView/2 = 300/2 = 150)
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.9597846866, green: 0.6503693461, blue: 0.1371207833, alpha: 1)
        spinner?.startAnimating()
        pullUpView.addSubview(spinner!)
    }
    
    
    @IBAction func centerMapBtn(_ sender: UIButton) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            centerMapOnUserLocation()
        }
    }
    


}




extension MapVC: MKMapViewDelegate {
    // to change pin color
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {   // to not change our location pin
            return nil
        }
        
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9597846866, green: 0.6503693461, blue: 0.1371207833, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    
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
        animateViewUp()
        addSpinner()
        addSwipe()
        
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
