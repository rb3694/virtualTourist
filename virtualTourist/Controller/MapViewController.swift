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
    
    @IBAction func userTapped(_ sender: Any) {
        print( "\n------------- TAP --------------" )
        let tap = sender as! UITapGestureRecognizer
        print( "TAP: sender.state == \(tap.state.rawValue) " )
        if ( tap.state == .ended ) {
            print( "TAP: state is \"ended\" " )
        }
        print( "TAP: sender.numberOfTouches == \(tap.numberOfTouches) " )
        if ( tap.state == .ended ) {
            let location = tap.location(in: mapView)
            let tapView = mapView.hitTest( location, with: nil )
            print( "Detected tap in view of class " + String( describing: type( of: tapView ) ) )
            if ( tapView is MKMapView )
            {
                print( "TAP: tapView is MKMapView" )
            }
            else if ( tapView is MKPinAnnotationView )
            {
                print( "TAP: tapView is MKPinAnnotationView" )
            }
            else if ( tapView is MKMarkerAnnotationView )
            {
                print( "TAP: tapView is MKMarkerAnnotationView" )
            }
            else if ( tapView is MKScaleView )
            {
                print( "TAP: tapView is MKScaleView" )
            }
            else if ( tapView is MKAnnotationView )
            {
                print( "TAP: tapView is MKAnntotionView" )
            }
            else if ( tapView is MKMapView )
            {
                print( "TAP: tapView is MKMapView" )
            }
            //else if ( tapView is MKAnnotationContainerView )
            //{
            //    print( "TAP:  tapView is MKAnnotationContainerView" )
            //}
            dump( tapView )
            print( "=======" )
            print( "Map view object is " )
            dump( mapView )
            if ( !(tapView is MKAnnotationView ))
            {
                let coordinates = mapView.convert(location, toCoordinateFrom: mapView )
                print( "TAP: sender.location == \(coordinates.latitude), \(coordinates.longitude) ")
                let newPin = VTMapPinArrayEntry( latitude: coordinates.latitude, longitude: coordinates.longitude )
                VTClient.sharedInstance().pins.append( newPin )
                newPin.loadImages()
                mapView.addAnnotation( newPin.annotation )
            } else {
                print( "TAP: tapView is an annotation view" );
            }
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
