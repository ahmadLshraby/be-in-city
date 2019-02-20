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
    var collectionView: UICollectionView?
    var flowLayout = UICollectionViewFlowLayout()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        configureLocationServices()
        addDoubleTab()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)   // instantiate
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: cellId)  // register cell
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = #colorLiteral(red: 0.9597846866, green: 0.6503693461, blue: 0.1371207833, alpha: 1)
        
        registerForPreviewing(with: self, sourceView: collectionView!)   // add 3D touch
        
        pullUpView.addSubview(collectionView!)
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
        API.instance.cancelAllSession()  // to cancel downloading
        
        pullUpViewHeightCons.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    // MARK: SPINNER IN THE VIEW
    func addSpinner() {
        spinner = UIActivityIndicatorView()   // instatiate it
        // position ( x= half screen width - half spinner (to align it), y= pullUpView/2 = 300/2 = 150)
        spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
        spinner?.style = .whiteLarge
        spinner?.color = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        spinner?.startAnimating()
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner() {
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    // MARK: LABEL IN THE VIEW
    func addProgressLbl() {
        progressLbl = UILabel()   // instatiate
        progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 100, y: 175, width: 200, height: 40)
        progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
        progressLbl?.textColor = #colorLiteral(red: 0.2126879096, green: 0.2239724994, blue: 0.265286684, alpha: 1)
        progressLbl?.textAlignment = .center
        collectionView?.addSubview(progressLbl!)
    }
    
    func removeProgreeLbl() {
        if progressLbl != nil {
            progressLbl?.removeFromSuperview()
        }
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
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotationId)
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
    // to use when user double tab on the screen
    @objc func dropPin(sender: UITapGestureRecognizer) {
        removePin()   // if there was no pin it consider that your current location is a default annotation
        removeSpinner()   // as when we drop a pin it creates another spinner above the old one
        removeProgreeLbl()
        API.instance.cancelAllSession()   // cancel downloading
        
        API.instance.imageUrlArray = []
        API.instance.imageArray = []
        self.collectionView?.reloadData()
        
        animateViewUp()
        addSpinner()
        addProgressLbl()
        addSwipe()
        // after that add the new pin
        // add touchPoint to convert the dropped pin to the exact location
        let touchPoint = sender.location(in: mapView)
        print(touchPoint)   // get locations X, Y of the view
        // convert to real GPS location
        let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        print(touchCoordinate)   // get long, lat
        // instance
        let annotation = DroppablePin(coordinate: touchCoordinate, identifier: annotationId)
        mapView.addAnnotation(annotation)   // show dropped pin on map
        // to center the map on the dropped pin
                    let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        API.instance.getUrl(forAnnotation: annotation) { (success) in
            if success == true {
            API.instance.getImages(forProgressLbl: self.progressLbl!, handler: { (success) in
                if success == true {   // remove the spinner and progressLbl to reload the collectionView and display photos
                    self.removeSpinner()   // hide spinner
                    self.removeProgreeLbl()   // hide label
                    self.collectionView?.reloadData()   // reload collectionView
                }
            })
            }
        }
    }
    
    // To remove the old dropped pin when we drop a new one
    func removePin() {
        for annotation in mapView.annotations {
            mapView.removeAnnotation(annotation)
        }
    }
}


// MARK: LOCATION MANAGER
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

// MARK: COLLECTION VIEW CONFIGURATION
extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return API.instance.imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as? PhotoCell {
            let imageFromArray = API.instance.imageArray[indexPath.row]
            let imageView = UIImageView(image: imageFromArray)
            cell.addSubview(imageView)
            return cell
        }else {
        return UICollectionViewCell()
        }
    }
    // go to PopVC when select an item
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC {
            let imageFromArrayIndex = API.instance.imageArray[indexPath.row]
            popVC.initData(forImage: imageFromArrayIndex)
            present(popVC, animated: true)
    }else {
            return
            
        }
    }

}

//MARK: 3D TOUCH FROM IMAGE
extension MapVC: UIViewControllerPreviewingDelegate {
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        if let indexPath = collectionView?.indexPathForItem(at: location) {
            let cell = collectionView?.cellForItem(at: indexPath)
            
            if let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC {
                let image = API.instance.imageArray[indexPath.row]
                popVC.initData(forImage: image)
                
                previewingContext.sourceRect = (cell?.contentView.frame)!   // size
                return popVC
            }else {
                return nil
            }
        }else {
            return nil
        }
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }
    
    
}
