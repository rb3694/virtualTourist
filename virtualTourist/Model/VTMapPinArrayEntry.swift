//
//  VTMapPinArrayEntry.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/24/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import UIKit
import MapKit

public class VTMapPinArrayEntry
{
    var images = [UIImage]()
    var annotation : MKPointAnnotation
    let cellLimit = 10
    var collection : UICollectionView? = nil

    // MARK: Initializers
    
    /*
    // construct a VTMapPinArrayEntry from a dictionary
    init(dictionary: [String:AnyObject]) {
        created = dictionary[VTClient.JSONResponseKeys.LocationCreated] as? String ?? ""
        firstName = dictionary[VTClient.JSONResponseKeys.LocationFirstName] as? String ?? ""
        lastName = dictionary[VTClient.JSONResponseKeys.LocationLastName] as? String ?? ""
        latitude = dictionary[VTClient.JSONResponseKeys.LocationLatitude] as? Double ?? 0.0
        longitude = dictionary[VTClient.JSONResponseKeys.LocationLongitude] as? Double ?? 0.0
        mapString = dictionary[VTClient.JSONResponseKeys.LocationMapString] as? String ?? ""
        mediaURL = dictionary[VTClient.JSONResponseKeys.LocationMediaURL] as? String ?? ""
        objectId = dictionary[VTClient.JSONResponseKeys.LocationObjectID] as? String ?? ""
        uniqueKey = dictionary[VTClient.JSONResponseKeys.LocationUniqueKey] as? String ?? ""
        updated = dictionary[VTClient.JSONResponseKeys.LocationUpdated] as? String ?? ""
    }
    */

    init( latitude : Double, longitude : Double ) {
        self.annotation = MKPointAnnotation()
        self.annotation.coordinate.latitude = latitude
        self.annotation.coordinate.longitude = longitude
        VTClient.sharedInstance().lookUpLocation( self.annotation.coordinate ) { (placemark) in
            var locName = placemark?.locality ?? "unknown";
            if placemark?.administrativeArea != nil
            {
                locName = locName + ", " + (placemark?.administrativeArea)!
            }
            if placemark?.country != nil {
                locName = locName + ", " + (placemark?.country)!
            }
            self.annotation.title = locName
            if let address = placemark?.name {
                self.annotation.subtitle = address
            }
        }
    }
    
    func reloadImages() {
        for index in 0..<images.count {
            images[index] = UIImage( named: "noPhoto" )!
        }
        if let collection = collection {
            collection.reloadData()
        }
        self.loadImages()
    }
    
    func loadImages() {
        VTClient.sharedInstance().retrieveImagesByLocation( latitude: self.annotation.coordinate.latitude, longitude: self.annotation.coordinate.longitude, limit: cellLimit, withPageNumber: nil ) { ( result, error ) in
            guard let result = result else {
                print( "No results returned, error: " + (error?.localizedDescription ?? "nil") )
                return
            }
            guard let photoArray = result[VTClient.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                return
            }
            for photoIndex in 0..<photoArray.count {
                let photoDictionary = photoArray[photoIndex]
                guard let imageUrlString = photoDictionary[VTClient.FlickrResponseKeys.MediumURL] as? String else {
                    print( "Cannot find key '\(VTClient.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                if ( photoIndex >= self.images.count ) {
                    self.images.append( UIImage( named: "noPhoto" )! )
                    if let collection = self.collection {
                        performUIUpdatesOnMain {
                            collection.reloadData()
                        }
                    }
                }

                // if an image exists at the url, set the image and title
                let imageURL = URL(string: imageUrlString)
                if let imageData = try? Data(contentsOf: imageURL!) {
                    self.images[photoIndex] = UIImage( data: imageData )!
                    // print( "Got an image! Index = \(photoIndex), URL = \(imageUrlString)" )
                    performUIUpdatesOnMain {
                        if let collection = self.collection {
                            collection.reloadData()
                        }
                        // self.photoImageView.image = UIImage(data: imageData)
                        // self.photoTitleLabel.text = photoTitle ?? "(Untitled)"
                    }
                } else {
                    print( "Image does not exist at \(String(describing: imageURL))" )
                }
            }
        }
    }
    
}
