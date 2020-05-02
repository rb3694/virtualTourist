//
//  PhotoAlbumViewController.swift
//  virtualTourist
//
//  Created by Robert Busby on 4/24/20.
//  Copyright © 2020 AT&T CSO SOS Development. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let reuseId = "photoAlbumCell"
    var selectedAnnotation: MKPointAnnotation?
    var photoAlbum: VTMapPinArrayEntry?
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK: - Lifecycle Events
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        for pin in VTClient.sharedInstance().pins {
            if pin.annotation == selectedAnnotation {
                photoAlbum = pin
            }
        }
        if let annotation = selectedAnnotation {
            mapView.addAnnotation( annotation )
            mapView.setCenter( annotation.coordinate, animated: true )
            mapView.showAnnotations( [annotation], animated: true )
        }

        let space: CGFloat = 3.0
        let columns: CGFloat = ( collectionView.frame.size.width > collectionView.frame.size.height ) ? 3.0 : 2.0
        let rows: CGFloat = ( collectionView.frame.size.width > collectionView.frame.size.height ) ? 2.0 : 3.0
        let width = (collectionView.frame.size.width - (2*space)) / columns
        let height = (collectionView.frame.size.height - (rows*space)) / rows
        
        print( "Setting grid layout to \(rows) rows and \(columns) columns at WxH = \(width) x \(height)" )
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize( width: width, height: height )
        collectionView?.reloadData()
    }

    @IBAction func newCollectionRequested(_ sender: Any) {
    }
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoAlbum!.images.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! VTPhotoAlbumCell

        // Configure the cell
        let image = photoAlbum!.images[(indexPath as NSIndexPath).row]
        cell.albumImageView.image = image
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        
        photoAlbum!.images.remove( at: (indexPath as NSIndexPath).row )
        collectionView.reloadData()
    }
    
    
}
