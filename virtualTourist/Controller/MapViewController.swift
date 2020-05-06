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

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let segueId = "mapToAlbumSegue"
    let reuseId = "MapPin"
    var selectedAnnotation : MKPointAnnotation?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let mapCenter = CLLocationCoordinate2D( latitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLatitude ), longitude: UserDefaults.standard.double(forKey: VTClient.Defaults.MapCenterLongitude) )
        let mapSpan = MKCoordinateSpan( latitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLatDelta), longitudeDelta: UserDefaults.standard.double(forKey: VTClient.Defaults.MapLongDelta) )
        let mapRegion = MKCoordinateRegion(center: mapCenter, span: mapSpan)
        mapView.setRegion(mapRegion, animated: true)
        let mapLatDelta = mapView.region.span.latitudeDelta
        let mapLongDelta = mapView.region.span.longitudeDelta
        print( "MapView.span.latitudeDelta = \(mapLatDelta)" )
        print( "MapView.span.longitudeDelta = \(mapLongDelta)" )
        print( "MapViewController: viewDidLoad()" )
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
            let newPin = VTMapPinArrayEntry( latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude )
            VTClient.sharedInstance().pins.append( newPin )
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
            let newPin = VTMapPinArrayEntry( latitude: coordinates.latitude, longitude: coordinates.longitude )
            VTClient.sharedInstance().pins.append( newPin )
            newPin.loadImages()
            mapView.addAnnotation( newPin.annotation )
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
