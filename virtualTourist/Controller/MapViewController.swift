//
//  MapViewController.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/24/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let segueId = "mapToAlbumSegue"
    let reuseId = "MapPin"
    
    var dataController : DataController!
    var selectedAnnotation : MKPointAnnotation?
    var selectedPin : VTMapPin?
    var fetchedResultsController:NSFetchedResultsController<VTMapPin>!

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK:  CoreData
    
    // Get a list of the user's predefined pins from CoreData
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VTMapPin> = VTMapPin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "virtualTourist" )
        // fetchedResultsController.delegate = self
        do {
            // print( "Performing fetch" )
            try fetchedResultsController.performFetch()
        } catch {
            fatalError( "The fetch could not be performed. \(error.localizedDescription)" )
        }
        
        // Add the pins we just retrieved to the amp
        for pin in fetchedResultsController.fetchedObjects! as [VTMapPin] {
            mapView.addAnnotation( pin.annotation() )
        }
    }

    // Add a new pin to the map and to CoreData
    func addPin( latitude: Double, longitude: Double ) -> VTMapPin {
        let pinToAdd = VTMapPin( context: dataController.viewContext )
        pinToAdd.latitude = latitude
        pinToAdd.longitude = longitude
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "CoreData Failure", message: "Unable to insert pin into CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        // Refetch so new pin will be in fetchedResults
        try? fetchedResultsController.performFetch()
        return pinToAdd
    }
    
    // Delete a pin from the map and from CoreData
    // Note:  we don't have a GUI widget to initiate this!
    func deletePin(at indexPath: IndexPath) {
        // This code hasn't really been tested yet, since there is nothing on the GUI to call it
        let pinToDel = fetchedResultsController.object(at: indexPath )
        mapView.removeAnnotation( pinToDel.annotation() )
        dataController.viewContext.delete(pinToDel)
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "CoreData Failure", message: "Unable to delete pin from CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        // Refetch so deleted pin will be removed from fetchedResults
        try? fetchedResultsController.performFetch()
    }
    
    // MARK:  View LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Get the map center and zoom level from user defaults
        let mapCenter = CLLocationCoordinate2D( latitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLatitude ), longitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLongitude) )
        let mapSpan = MKCoordinateSpan( latitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLatDelta), longitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLongDelta) )
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        
        // Initialize CoreData and load the model
        setupFetchedResultsController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if ( nil == fetchedResultsController )
        {
            setupFetchedResultsController()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool ) {
        // Remember the map center and zoom level - store in user defaults
        UserDefaults.standard.set( mapView.region.center.latitude, forKey: VTClient.Defaults.MapCenterLatitude)
        UserDefaults.standard.set( mapView.region.center.longitude, forKey: VTClient.Defaults.MapCenterLongitude)
        UserDefaults.standard.set( mapView.region.span.latitudeDelta, forKey: VTClient.Defaults.MapLatDelta )
        UserDefaults.standard.set( mapView.region.span.longitudeDelta, forKey: VTClient.Defaults.MapLongDelta )
    }

    // Data source for map pins
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
            
        return pinView
    }

        
    // This delegate method is implemented to respond to taps. It finds the
    // annotation in the pin list, and transitions to the PhotoAlbumView
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            selectedAnnotation = view.annotation as? MKPointAnnotation
            mapView.deselectAnnotation( view.annotation, animated: true )

            // Find the VTMapPin object that corresponds to the GUI pin that was clicked
            for pin in (fetchedResultsController.fetchedObjects ?? []) as [VTMapPin] {
                if pin.latitude == selectedAnnotation?.coordinate.latitude && pin.longitude == selectedAnnotation?.coordinate.longitude {
                    // Found the pin.  Segue and abort search for other matches.
                    selectedPin = pin
                    performSegue( withIdentifier: segueId, sender: self )
                    return
                }
            }
        }
        print( "###### ERROR: Unable to find selected pin!" )
    }
    
    // Handle a long press and release on the map by adding a new pin at that location
    @IBAction func userPressed(_ sender: Any) {
        let press = sender as! UILongPressGestureRecognizer
        if ( press.state == .ended ) {
            let location = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView )
            let newPin = addPin( latitude: coordinates.latitude, longitude: coordinates.longitude )
            newPin.loadImages( viewController: self, dataController: dataController )
            let annot = newPin.annotation()
            mapView.addAnnotation( annot )
        }
    }
    
    // MARK: - Navigation

    // Set up the context to share with the PhotoAlbum view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            let vc = segue.destination as! PhotoAlbumViewController
            vc.dataController = dataController
            vc.selectedPin = selectedPin
        }
    }

}
