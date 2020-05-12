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
    
    // Creates an annotation to match pin coordinates
    func annotation() -> MKPointAnnotation {
        let anno = MKPointAnnotation()
        anno.coordinate.latitude = self.latitude
        anno.coordinate.longitude = self.longitude
        if nil == self.placeName {
            /* Look up the name once and store it in the pin so we don't have to
               look it up every time we click on it
             */
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
            /* We've already looked this place up */
            anno.title = self.placeName
            anno.subtitle = self.address
        }
        return anno
    }
    
    // Adds a new Photo to the MapPin
    func addPhoto( viewController: UIViewController, dataController: DataController, index: Int16, imageData: Data, caption: String, url: URL ) -> VTPhoto {
        let photoToAdd = VTPhoto( context: dataController.viewContext )
        photoToAdd.photoIndex = index
        photoToAdd.image = imageData
        photoToAdd.url = url
        photoToAdd.caption = caption
        photoToAdd.mapPin = self
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "CoreData Failure", message: "Unable to insert photo into CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
        return photoToAdd
    }
    
    // Deletes the Photo at the specified index path
    func deletePhoto(at indexPath: IndexPath, viewController: UIViewController, dataController: DataController ) {
        if let photoToDel = self.photos?[indexPath.row] {
            dataController.viewContext.delete(photoToDel as! VTPhoto)
        }
        do {
            try dataController.viewContext.save()
        } catch let error as NSError {
            let alert = UIAlertController(title: "CoreData Failure", message: "Unable to delete photo from CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }

    // Uses Flickr API to load images near the pin's location
    func loadImages( viewController: UIViewController, dataController: DataController ) {
        VTClient.sharedInstance().retrieveImagesByLocation( latitude: self.latitude, longitude: self.longitude, limit: VTClient.Configuration.CellLimit, withPageNumber: nil ) { ( result, error ) in
            guard let result = result else {
                print( "No results returned, error: " + (error?.localizedDescription ?? "nil") )
                return
            }
            guard let photoArray = result[VTClient.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                return
            }
            
            for photoIndex in 0..<photoArray.count {
                // Initialize the VTPhoto with a "noPhoto" placeholder image
                let photoDictionary = photoArray[photoIndex]
                var title = "No Title"
                if let photoTitle = photoDictionary[VTClient.FlickrResponseKeys.Title] as? String {
                    title = photoTitle
                }
                guard let imageUrlString = photoDictionary[VTClient.FlickrResponseKeys.MediumURL] as? String else {
                    print( "Cannot find key '\(VTClient.FlickrResponseKeys.MediumURL)' in \(photoDictionary)")
                    return
                }
                let imageURL = URL(string: imageUrlString)
                if ( photoIndex >= self.photos?.count ?? 0 ) {
                    _ = self.addPhoto( viewController: viewController, dataController: dataController, index: Int16(self.photos!.count), imageData: (UIImage( named: "noPhoto")?.pngData())!, caption: title, url: imageURL! )
                    if let collection = VTClient.sharedInstance().collection {
                        performUIUpdatesOnMain {
                            // Update the GUI to display the "noPhoto" image
                            collection.reloadData()
                        }
                    }
                }
            }

            // Go back through all the photos and load the data from Flickr
            for photoIndex in 0..<photoArray.count {
                if photoIndex < self.photos?.count ?? 0 {
                    if let photo = (self.photos?.object(at: photoIndex ) as? VTPhoto) {
                        // if an image exists at the url, set the image and title
                        if let url = photo.url {
                            if let imageData = try? Data( contentsOf: url ) {
                                // All of these if-lets keep us from crashing
                                // if someone deletes the collection while we
                                // are still loading images
                                photo.image = imageData
                                do {
                                    try dataController.viewContext.save()
                                } catch let error as NSError {
                                    performUIUpdatesOnMain {
                                        let alert = UIAlertController(title: "CoreData Failure", message: "Unable to update photo in CoreData: Error \(error.localizedDescription), \(error.userInfo)", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "CoreData Failed", style: .default, handler: nil))
                                        viewController.present(alert, animated: true, completion: nil)
                                    }
                                }
                                performUIUpdatesOnMain {
                                    if let collection = VTClient.sharedInstance().collection {
                                        // Refresh the collection to display the
                                        // newly downloaded image
                                        collection.reloadData()
                                    }
                                } /* performUIUpdatesOnMain() */
                            } else { /* imageData not retrieved */
                                print( "Image does not exist at \(String(describing: photo.url))" )
                            }
                        } /* url is not nil */
                    } /* photo is not nil */
                }  /* photoIndex is in range */
            } /* for photoIndex in photoArray.count */
            
        }  /* retrieveImagesByLocation completion handler */
    }
    
    // Discard the photos we have and load new ones
    func reloadImages( viewController: UIViewController, dataController: DataController ) {
        for index in 0..<(self.photos?.count ?? 0) {
            let photo = self.photos![index] as! VTPhoto
            photo.image = UIImage( named: "noPhoto" )!.pngData()
        }
        if let collection = VTClient.sharedInstance().collection {
            collection.reloadData()
        }
        self.loadImages( viewController: viewController, dataController: dataController )
    }

}
