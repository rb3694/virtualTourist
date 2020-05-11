//
//  VTMapPin+Extensions.swift
//  virtualTourist
//
//  Created by Robert Busby on 5/11/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import MapKit

extension VTMapPin {
    
    func annotation() -> MKPointAnnotation {
        let anno = MKPointAnnotation()
        anno.coordinate.latitude = self.latitude
        anno.coordinate.longitude = self.longitude
        if nil == self.placeName {
            VTClient.sharedInstance().lookUpLocation( anno.coordinate ) { (placemark) in
                var locName = placemark?.locality ?? "unknown";
                if placemark?.administrativeArea != nil
                {
                    locName = locName + ", " + (placemark?.administrativeArea)!
                }
                if placemark?.country != nil {
                    locName = locName + ", " + (placemark?.country)!
                }
                self.placeName = locName
                anno.title = locName
                if let address = placemark?.name {
                    self.address = address
                    anno.subtitle = address
                }
            }
        }
        else
        {
            anno.title = self.placeName
            anno.subtitle = self.address
        }
        return anno
    }
    
    func loadImages() {
        /*
        VTClient.sharedInstance().retrieveImagesByLocation( latitude: self.latitude, longitude: self.longitude, limit: VTClient.Configuration.CellLimit, withPageNumber: nil ) { ( result, error ) in
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
 */
    }
    
    func reloadImages() { /*
        for index in 0..<(self.photos?.count ?? 0) {
            let photo = self.photos![index] as! VTPhoto
            photo.image = UIImage( named: "noPhoto" )!.pngData()
        }
        if let collection = collection {
            collection.reloadData()
        }
        self.loadImages()
    */
    }
    

}
