//
//  VTConvenience.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/28/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation

extension VTClient {
    
    private func bboxString( latitude: Double, longitude: Double ) -> String {
        let minLat = max( latitude - Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.0 )
        let maxLat = min( latitude + Flickr.SearchBBoxHalfHeight, Flickr.SearchLatRange.1 )
        let minLong = max( longitude - Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.0 )
        let maxLong = min( longitude + Flickr.SearchBBoxHalfWidth, Flickr.SearchLonRange.1 )
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
 
    func retrieveImagesByLocation( latitude: Double, longitude: Double, limit: Int?, withPageNumber: Int?, completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) -> Void {
        var parameters = [
            FlickrParameterKeys.APIKey: FlickrParameterValues.APIKey,
            FlickrParameterKeys.Method: FlickrParameterValues.SearchMethod,
            FlickrParameterKeys.Extras: FlickrParameterValues.MediumURL,
            FlickrParameterKeys.Format: FlickrParameterValues.ResponseFormat,
            FlickrParameterKeys.SafeSearch: FlickrParameterValues.UseSafeSearch,
            FlickrParameterKeys.NoJSONCallback: FlickrParameterValues.DisableJSONCallback,
            FlickrParameterKeys.BoundingBox : bboxString(
            latitude: latitude, longitude: longitude ) ]
        if let limit = limit {
            parameters[FlickrParameterKeys.PerPage] = "\(limit)"
        }
        if let withPageNumber = withPageNumber {
            parameters[FlickrParameterKeys.Page] = "\(withPageNumber)"
            // print( "Retrieving page \(withPageNumber) of images" )
        }
         _ = VTClient.sharedInstance().httpTask(
                HttpMethods.Get,
                parameters: parameters as [ String: AnyObject ],
                headers: nil
             ) {
            (results, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = results?[FlickrResponseKeys.Photos] as? [String:AnyObject] {
                    if withPageNumber == nil {
                        // We pick a random page number and recursively request the results again
                        if let pageCount = results[VTClient.FlickrResponseKeys.Pages] {
                            var pageNumber = pageCount as! Int
                            if pageNumber > 1 {
                                if pageNumber > 40 {
                                    pageNumber = 40
                                    // I think there is a bug in the Flickr API
                                    // if you request a page > 40 you get page 1
                                }
                                pageNumber = Int( arc4random_uniform( UInt32(pageNumber) ) )
                                self.retrieveImagesByLocation(latitude: latitude, longitude: longitude, limit: limit, withPageNumber: pageNumber, completionHandler: completionHandler )
                                return
                            }
                        }
                    }
                    completionHandler( results as AnyObject, nil )
                } else {
                    completionHandler(nil, NSError(domain: "\(FlickrResponseKeys.Photos) parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse \(FlickrResponseKeys.Photos) request response"]))
                }
            }
        }
    }

    /* --------------
 
 
    // Retrieve the most recently updated student locations from the map API
    func getStudentLocations( limit: Int?,  completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) ->    Void) -> Void {
        var returnLimit = 100
        if let limit = limit {
            returnLimit = limit
        }
        let parameters = [ UdacityClient.ParameterKeys.Limit: "\(returnLimit)",
                           UdacityClient.ParameterKeys.Order: "-" + UdacityClient.JSONResponseKeys.LocationUpdated,
                         ]
         _ = UdacityClient.sharedInstance().httpTask(
                UdacityClient.HttpMethods.Get,
                UdacityClient.Methods.StudentLocation,
                parameters: parameters as [ String: AnyObject ],
                headers: nil
             ) {
            (results, error) in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = results?[UdacityClient.JSONResponseKeys.LocationResults] as? [[String:AnyObject]] {
                            UdacityClient.sharedInstance().locations = StudentLocation.studentLocationsFromResults( results );
                    completionHandler( "" as AnyObject, nil )
                } else {
                    completionHandler(nil, NSError(domain: "StudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse StudentLocations request response"]))
                }
            }
        }
    }

    // Add a student location through the map API
    func postUserLocation( location: StudentLocation, completionHandler: @escaping(_ result: AnyObject?, _ error: NSError?) ->    Void) -> Void {
        let parameters = [ UdacityClient.JSONBodyKeys.Userid: location.uniqueKey,
                           UdacityClient.JSONBodyKeys.FirstName: location.firstName,
                           UdacityClient.JSONBodyKeys.LastName: location.lastName,
                           UdacityClient.JSONBodyKeys.MapString: location.mapString,
                           UdacityClient.JSONBodyKeys.MediaURL: location.mediaURL,
                           UdacityClient.JSONBodyKeys.Latitude: location.latitude,
                           UdacityClient.JSONBodyKeys.Longitude: location.longitude
                         ] as [String : Any]
        
        _ = UdacityClient.sharedInstance().httpTask(
                UdacityClient.HttpMethods.Post,
                UdacityClient.Methods.StudentLocation,
                parameters: parameters as [ String: AnyObject ],
                headers: nil
        ) { (results, error) in
            if let error = error {
                completionHandler(nil, error)
            } else if let objectId = results?[UdacityClient.JSONResponseKeys.LocationObjectID]  {
                    completionHandler(objectId as AnyObject?, nil)
            } else if let errString = results?[UdacityClient.JSONResponseKeys.LocationError] {
                completionHandler(nil, NSError( domain: "postUserLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: errString!]))
            } else {
                    completionHandler(nil, NSError(domain: "postUserLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postUserLocation results"]))
            }
        }
    }
 
 ------ */

}
