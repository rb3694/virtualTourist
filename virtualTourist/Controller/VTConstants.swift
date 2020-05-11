//
//  VTConstants.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/24/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation

extension VTClient {
    
    // MARK: Configuration
    
    struct Configuration {
        static let CellLimit = 10
    }
    
    // MARK: Defaults
    
    struct Defaults {
        static let HasLaunched = "HasLaunched"
        static let MapCenterLatitude = "MapCenterLatitude"
        static let MapCenterLongitude = "MapCenterLongitude"
        static let MapLongDelta = "MapLongDelta"
        static let MapLatDelta = "MapLatDelta"
    }
    
    // MARK: HttpMethods
    
    struct HttpMethods {
        static let Get = "GET"
        static let Post = "POST"
        static let Put = "PUT"
        static let Delete = "DELETE"
    }
    
    // MARK: Flickr
    
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        static let SearchBBoxHalfWidth = 1.0
        static let SearchBBoxHalfHeight = 1.0
        static let SearchLatRange = (-90.0, 90.0)
        static let SearchLonRange = (-180.0, 180.0)
    }
    
    // MARK: Flickr Parameter Keys
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let PerPage = "per_page"
    }
    
    // MARK: Flickr Parameter Values
    
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "5b0501b0a8bbf04efc70744ad851bdca"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    
    struct FlickrResponseValues {
        static let OKStatus = "ok"
    }

}
