//
//  VTClient.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/24/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import MapKit

class VTClient : NSObject {

    // MARK: Properties

    // shared session
    var session = URLSession.shared
    var collection : UICollectionView?
    lazy var geocoder = CLGeocoder()

    // MARK: httpTask
    
    func httpTask( _ httpMethod: String,
                   parameters: [String:AnyObject]?,
                   headers: [String:String]?,
                   completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void
                 ) -> URLSessionDataTask {
        var request: NSMutableURLRequest
        
        /* 1/2/3. Set the parameters, Build the URL, Configure the request */
        if ( httpMethod == HttpMethods.Get )
        {
            // Encode the parameters as CGI in the URL string
            request = NSMutableURLRequest(url: flickrURLFromParameters(parameters ?? [:] ))
        }
        else
        {
            // Encode the parameters as JSON in the request body
            request = NSMutableURLRequest( url: flickrURL() )
            if let parameters = parameters {
                let jsonData = try? JSONSerialization.data( withJSONObject: parameters )
                request.httpBody = jsonData
            }
            request.httpMethod = httpMethod
            request.addValue( "application/json", forHTTPHeaderField: "Accept" )
            request.addValue( "application/json", forHTTPHeaderField: "Content-Type" )
        }
        if let headers = headers {
            for key in headers.keys {
                request.addValue( headers[key] ?? "", forHTTPHeaderField: key )
            }
        }
        
        // DEBUG CODE - Remove before release
        // print( request.httpMethod + " " + (request.url?.absoluteString ?? "") )
        // print( request.allHTTPHeaderFields ?? "" )
        // if let theBody = request.httpBody {
        // print( NSString( data: theBody, encoding: String.Encoding.utf8.rawValue )! )
        // }
        // print( "" )
        // END DEBUG CODE - Remove prior to release
       
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandler(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                sendError( "Unable to examine return status code" )
                return
            }
            if statusCode == 403 {
                sendError( "Your credentials were not accepted." )
                return
            }
            if statusCode < 200 || statusCode > 299 {
                sendError( "Your request returned a non-OK status code of \(statusCode)" )
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            // DEBUG CODE - Remove prior to release
            // print( String(data: data, encoding: .utf8)! )
            // print( "" )
            // END DEBUG CODE - Remove prior to release

            self.convertDataWithCompletionHandler( data, completionHandlerForConvertData: completionHandler )
        }

        /* 7. Start the request */
        task.resume()
        
        return task
    }
    
    // given raw JSON, return a usable Foundation object
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    // create a URL without query parameters
    private func flickrURL(_ withPathExtension: String? = nil ) -> URL {
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath + (withPathExtension ?? "")
        
        return components.url!
    }
    
    // create a URL from parameters
    private func flickrURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        var components = URLComponents()
        components.scheme = Flickr.APIScheme
        components.host = Flickr.APIHost
        components.path = Flickr.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for ( key, value ) in parameters {
            let queryItem = URLQueryItem( name: key, value: "\(value)" )
            components.queryItems!.append( queryItem )
        }
        
        return components.url!
    }
    
    // MARK: - Geocoding
    
    func lookUpLocation(_ place: CLLocationCoordinate2D, completionHandler: @escaping (CLPlacemark?)
                    -> Void ) {
                
        // Look up the location and pass it to the completion handler
        geocoder.reverseGeocodeLocation( CLLocation( latitude: place.latitude, longitude: place.longitude ), completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                 // An error occurred during geocoding.
                    completionHandler(nil)
                }
            }
        )
    }


    // MARK: Shared Instance
    
    class func sharedInstance() -> VTClient {
        struct Singleton {
            static var sharedInstance = VTClient()
        }
        return Singleton.sharedInstance
    }

}
