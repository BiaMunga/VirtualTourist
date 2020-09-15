//
//  PhotoViewController.swift
//  VirtualTourist
//
//  Created by Henry Mungalsingh on 08/09/2020.
//  Copyright © 2020 Spared. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class PhotoViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {
    
    var dataController: DataController!
    
    var collectionView: UICollectionView!
    
    var flowLayout: UICollectionViewFlowLayout!
    
    var mapView: MKMapView!
    
    var button: UIButton!
    
    var latitude: Double!
    
    var longitude: Double!
    
    var pinPlaced: Pins!
    
    var coordinate: CLLocationCoordinate2D!
    
    var fetchedResultContoller: NSFetchedResultsController<PhotoAlbum>!
    
    
    override func viewDidLoad() {
           super.viewDidLoad()
        
        navigationItem.title = "Virtual Tourist"
        
        self.mapView = setUpMapView()
        mapView.delegate = self
        

        self.flowLayout = setUpFlowLayout()
        
     
        self.collectionView = setUpCollectionView()


        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "collectionCell")

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = false
        
        self.button = setUpButton()
        
        self.setPin()
        self.setupFetchedResultsController()
        self.getFlickrPhotos(latitude: self.latitude, longitude: self.longitude)
        
    
       }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        fetchedResultContoller = nil
    }
    
    func setPin() {
        let newPin = MKPointAnnotation()
        newPin.coordinate = coordinate
        
        self.pinPlaced = Pins(context: dataController.viewContext)
        pinPlaced.latitude = self.latitude
        pinPlaced.longitude = self.longitude
        
        mapView.addAnnotation(newPin)
    }
    
    
    func getFlickrPhotos(latitude: Double, longitude: Double) {
        
        self.showSpinner(onView: self.collectionView)
        self.button.isEnabled = false
        
        FlickrApi.getPhotos(latitude: latitude, longitude: longitude, completion: self.handleGetPhotos(photos:error:))
    
        
    }

    func setUpMapView() -> MKMapView {
    
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.mapType = MKMapType.standard
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        
        self.view.addSubview(mapView)
        
        NSLayoutConstraint.activate([
        mapView.topAnchor.constraint(equalTo: view.topAnchor),
        mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),
        mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
        let centerCoordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        let spanCoordinate = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
            
        mapView.setRegion(region, animated: true)
        mapView.reloadInputViews()
        
        return mapView
        
    }
    
    func setUpCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .secondarySystemBackground
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
        collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
                
        return collectionView
    }
    
    func setUpButton() -> UIButton {
        
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.setTitle("New Collection", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.black, for: .disabled)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 25)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        self.view.addSubview(button)
        
        NSLayoutConstraint.activate([
        button.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        button.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        
        return button
        
    }
    
    func setUpFlowLayout() -> UICollectionViewFlowLayout {
        
        let flowLayout = UICollectionViewFlowLayout()
        let space:CGFloat = 2.0
        let space2:CGFloat = 2.0
        let dimension = (view.frame.size.width - (3 * space)) / 4.0
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space2
        flowLayout.scrollDirection = .vertical
        return flowLayout
    }
    
    @objc func didTapButton() {
        
        let alertController = UIAlertController(title: "Confirm Refresh", message: "Are you sure you want to download new photos?", preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (alertAction) in
                
                if let albums = self.fetchedResultContoller.fetchedObjects {
                    
                    for album in albums {
                        self.dataController.viewContext.performAndWait {
                            self.removePhoto(album: album)
                        }
                    }
                }
                
                self.collectionView.reloadData()
                self.collectionView.numberOfItems(inSection: 0)
                // Load new collections
                self.getFlickrPhotos(latitude: self.latitude, longitude: self.longitude)

               }))
               alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
               present(alertController, animated: true, completion: nil)
        
    }
    
    func removePhoto(album: PhotoAlbum) {
        dataController.viewContext.delete(album)
        do {
            try dataController.viewContext.save()
        } catch {
            print(error)
        }
    }
    
    func handleGetPhotos(photos: PhotoResponse?, error: Error?) {
    
        var photoURLs: [String] = []
        
        
     if let photos = photos {
    
        
        for photo in photos.photos.photo {
            let farmID = photo.farm
            let ID = photo.id
            let secret = photo.secret
            let serverID = photo.server
            
            let currentPhotoURL = "https://farm\(farmID).staticflickr.com/\(serverID)/\(ID)_\(secret).jpg"
            photoURLs.append(currentPhotoURL)
        }
        
        DispatchQueue.main.async {
            self.downloadPhotos(photos: photoURLs)
        }
        
        }
        
    }
    
    func downloadPhotos(photos: [String]) {

        if pinPlaced.pinPhoto?.count == 0 {
            
        for photoURL in photos {
        let album = PhotoAlbum(context: self.dataController.viewContext)
            FlickrApi.downloadPhotos(photoUrl: photoURL) { (imageData, error) in

            album.photo = imageData

            album.pinsForPhoto = self.pinPlaced

            try? self.dataController.viewContext.save()
                
            DispatchQueue.main.async {
                self.removeSpinner()
                self.button.isEnabled = true
                self.collectionView.reloadData()
            }
            }
        }
        }
        
    }
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<PhotoAlbum> = PhotoAlbum.fetchRequest()
        let predicate = NSPredicate(format: "pinsForPhoto == %@", pinPlaced)
        fetchRequest.sortDescriptors = []
        fetchRequest.predicate = predicate
        fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultContoller.delegate = self
        
        do {
            try fetchedResultContoller.performFetch()
        } catch {
            fatalError("The fetch could not be performed")
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultContoller.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! CollectionViewCell
        
        let currentPhoto = fetchedResultContoller.object(at: indexPath)

        DispatchQueue.main.async {
            if let imageData = currentPhoto.photo {
                cell.imageView.image = UIImage(data: imageData)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photoSelected = fetchedResultContoller.object(at: indexPath)
        dataController.viewContext.delete(photoSelected)
    }

    
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


}

extension PhotoViewController:NSFetchedResultsControllerDelegate{
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [newIndexPath!])
        case .move:
            collectionView.moveItem(at: indexPath!, to: newIndexPath!)
        @unknown default:
            fatalError("")
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: collectionView.insertSections(indexSet)
        case .delete: collectionView.deleteSections(indexSet)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        @unknown default:
            fatalError("")
        }
    }
}

