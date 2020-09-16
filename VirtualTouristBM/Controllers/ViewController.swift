//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Henry Mungalsingh on 08/09/2020.
//  Copyright © 2020 Spared. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class ViewController: UIViewController {
    
    var dataController:DataController!
    
    let photoViewSegue: String = "photoView"
    
    var pinsPlaced: [Pins] = []
    
    var pinChosen: Pins!
    
    var fetchedResultContoller: NSFetchedResultsController<Pins>!
    
    let mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        return mapView
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.delegate = self
        setUpMapView()
        
        self.navigationItem.title = "Virtual Tourist"
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.mapLongPress(_:)))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        
        self.fetchPins()
        setupFetchedResultsController()
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultContoller = nil
    }
    
    
    fileprivate func fetchPins() {
    
            
        let request: NSFetchRequest<Pins> = Pins.fetchRequest()


        if let pinsFetched = try? dataController.viewContext.fetch(request) {

        self.pinsPlaced = pinsFetched

            DispatchQueue.main.async {
                self.updateMap(pins: self.pinsPlaced)
            }

        }
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pins> = Pins.fetchRequest()
        fetchRequest.sortDescriptors = []
        fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultContoller.performFetch()
        } catch {
            fatalError("The fetch could not be performed")
        }
    }
    
    func updateMap(pins: [Pins]) {
        mapView.removeAnnotations(mapView.annotations)
        for pin in pins {
            
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate =
                CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude), CLLocationDegrees(pin.longitude))
            self.mapView.addAnnotation(pointAnnotation)
        }
    }
    
    
    func setUpMapView() {
        
        view.addSubview(mapView)
        
         NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
        
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "AppLaunchedBefore") {
            let centerLatitude  = defaults.double(forKey: "Latitude")
            let centerLongitude = defaults.double(forKey: "Longitude")
            let latitudeDelta   = defaults.double(forKey: "LatitudeDelta")
            let longitudeDelta  = defaults.double(forKey: "LongitudeDelta")
            
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
            let spanCoordinate = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
            
            self.mapView.setRegion(region, animated: true)
            self.mapView.reloadInputViews()
        } else {
            defaults.set(true, forKey: "AppLaunchedBefore")
        }
                
    }
    
    
    @objc func mapLongPress(_ recognizer: UIGestureRecognizer) {

        
        

          let touchedAt = recognizer.location(in: self.mapView)
          let touchedAtCoordinate : CLLocationCoordinate2D = mapView.convert(touchedAt, toCoordinateFrom: self.mapView)
         
        if recognizer.state == .began {
        let annotation = MKPointAnnotation()
        annotation.coordinate = touchedAtCoordinate
        
        // Update the map with pin
        mapView.addAnnotation(annotation)
        } else if recognizer.state == .ended {
        
        let newPin = Pins(context: dataController.viewContext)
        newPin.latitude = touchedAtCoordinate.latitude
        newPin.longitude = touchedAtCoordinate.longitude
        
        pinsPlaced.append(newPin)
      
        
        do {
            try dataController.viewContext.save()
        }
        catch {
            
        }
      }
    }
    
}

extension ViewController: MKMapViewDelegate {


    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
         
         let reuseId = "pin"
         
         var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

         if pinView == nil {
             pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
             pinView!.canShowCallout = true
             pinView!.pinTintColor = .red
             pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
         }
         else {
             pinView!.annotation = annotation
         }
         
         return pinView
     }

    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let userDefaults = UserDefaults.standard
        userDefaults.set(mapView.region.center.latitude, forKey: "Latitude")
        userDefaults.set(mapView.region.center.longitude, forKey: "Longitude")
        userDefaults.set(mapView.region.span.latitudeDelta, forKey: "LatitudeDelta")
        userDefaults.set(mapView.region.span.longitudeDelta, forKey: "LongitudeDelta")
        
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
//        if let latitude = view.annotation?.coordinate.latitude {
//            print(latitude)
//            self.pinChosen.latitude = latitude
//        }
//
//        if let longitude = view.annotation?.coordinate.longitude {
//            print(longitude)
//            self.pinChosen.longitude = longitude
//        }
        
      let photoViewController = PhotoViewController()
        photoViewController.coordinate = view.annotation?.coordinate
        photoViewController.latitude = view.annotation?.coordinate.latitude
        photoViewController.longitude = view.annotation?.coordinate.longitude
        photoViewController.dataController  = dataController
//        photoViewController.pinPlaced = pinChosen
        self.navigationController?.pushViewController(photoViewController, animated: true)
        
        mapView.deselectAnnotation(view.annotation, animated: false)
    }

}

