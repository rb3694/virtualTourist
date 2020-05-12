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
import CoreData

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    let reuseId = "photoAlbumCell"
    var dataController : DataController!
    var fetchedResultsController: NSFetchedResultsController<VTPhoto>!
    var selectedPin : VTMapPin?
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    // MARK:  CoreData
    
    // Deletes the Photo at the specified index path
    func deletePhoto(at indexPath: IndexPath) {
        if (selectedPin?.photos?[indexPath.row]) != nil {
            selectedPin?.deletePhoto(at: indexPath, viewController: self, dataController: dataController )
        }
    }

    // MARK: - Lifecycle Events
    
    override func viewDidLoad() {
        super.viewDidLoad()
           
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        if let annotation = selectedPin?.annotation() {
            mapView.addAnnotation( annotation )
            mapView.setCenter( annotation.coordinate, animated: true )
            mapView.showAnnotations( [annotation], animated: true )
        }
        VTClient.sharedInstance().collection = self.collectionView;

        let space: CGFloat = 3.0
        let columns: CGFloat = ( collectionView.frame.size.width > collectionView.frame.size.height ) ? 3.0 : 2.0
        let rows: CGFloat = ( collectionView.frame.size.width > collectionView.frame.size.height ) ? 2.0 : 3.0
        let width = (collectionView.frame.size.width - (2*space)) / columns
        let height = (collectionView.frame.size.height - (rows*space)) / rows
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize( width: width, height: height )
        collectionView?.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated )
        VTClient.sharedInstance().collection = nil
    }
    
    // MARK: Actions
    
    @IBAction func newCollectionRequested(_ sender: Any) {
        // Remove all of the photos, then load a new random page of photos
        if let count = selectedPin?.photos?.count {
            var x = count - 1
            while x >= 0 {
                selectedPin?.deletePhoto( at: IndexPath( row: x, section: 0 ), viewController: self, dataController: dataController )
                x -= 1
            }
        }
        selectedPin?.reloadImages( viewController: self, dataController: dataController )
        collectionView.reloadData()
    }
    
    // MARK: UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if let photos = selectedPin?.photos?.count {
            count = photos
        }
        if count < 1 {
            reloadButton.setTitle( "No Images", for: .normal )
        } else {
            reloadButton.setTitle( "New Collection", for: .normal )
        }
        return count
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseId, for: indexPath) as! VTPhotoAlbumCell

        // Configure the cell
        if let photo = (selectedPin?.photos?[indexPath.row]) as? VTPhoto {
            if let imageData = photo.image {
                cell.albumImageView.image = UIImage( data: imageData )
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto( at: indexPath )
        collectionView.reloadData()
    }
    
}
