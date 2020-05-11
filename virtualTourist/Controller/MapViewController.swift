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
    var fetchedResultsController:NSFetchedResultsController<VTMapPin>!

    @IBOutlet weak var mapView: MKMapView!
    
    // MARK:  CoreData
    
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
        return pinToAdd
    }
    
    func deletePin(at indexPath: IndexPath) {
        let pinToDel = fetchedResultsController.object(at: indexPath )
        dataController.viewContext.delete(pinToDel)
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "CoreData Failure", message: "Unable to delete pin from CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<VTMapPin> = VTMapPin.fetchRequest()
        //let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        //fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "virtualTourist" )
        // fetchedResultsController.delegate = self
        do {
            print( "Performing fetch" )
            try fetchedResultsController.performFetch()
            
        } catch {
            fatalError( "The fetch could not be performed. \(error.localizedDescription)" )
        }
        
        for pin in fetchedResultsController.fetchedObjects! as [VTMapPin] {
            mapView.addAnnotation( pin.annotation() )
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapCenter = CLLocationCoordinate2D( latitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLatitude ), longitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLongitude) )
        let mapSpan = MKCoordinateSpan( latitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLatDelta), longitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLongDelta) )
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        
        let t = type( of: self )
        print( "\(t) viewDidLoad" )
        print( "viewDidLoad: setting up fetchedResultsController" )
        setupFetchedResultsController()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let t = type( of: self )
        print( "\(t) viewWillAppear" )
        if ( nil == fetchedResultsController )
        {
            print( "viewWillAppear: Setting up fetchedResultsController" )
            setupFetchedResultsController()
        }

        for pin in fetchedResultsController.fetchedObjects! as [VTMapPin] {
            mapView.addAnnotation( pin.annotation() )
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let t = type( of: self )
        print( "\(t) viewDidDisappear. Tearing down fetchedResultsController" )
        fetchedResultsController = nil
    }

    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool ) {
        UserDefaults.standard.set( mapView.region.center.latitude, forKey: VTClient.Defaults.MapCenterLatitude)
        UserDefaults.standard.set( mapView.region.center.longitude, forKey: VTClient.Defaults.MapCenterLongitude)
        UserDefaults.standard.set( mapView.region.span.latitudeDelta, forKey: VTClient.Defaults.MapLatDelta )
        UserDefaults.standard.set( mapView.region.span.longitudeDelta, forKey: VTClient.Defaults.MapLongDelta )
    }

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
            performSegue( withIdentifier: segueId, sender: self )
        }
    }
    
    @IBAction func userPressed(_ sender: Any) {
        let press = sender as! UILongPressGestureRecognizer
        if ( press.state == .ended ) {
            let location = press.location(in: mapView)
            let coordinates = mapView.convert(location, toCoordinateFrom: mapView )
            let newPin = addPin( latitude: coordinates.latitude, longitude: coordinates.longitude )
            newPin.loadImages()
            mapView.addAnnotation( newPin.annotation() )
        }
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == segueId {
            let vc = segue.destination as! PhotoAlbumViewController
            vc.selectedAnnotation = selectedAnnotation
        }
    }

}
