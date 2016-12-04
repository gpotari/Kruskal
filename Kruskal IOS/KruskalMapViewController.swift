//
//  KruskalMapViewController.swift
//  Kruskal IOS
//
//  Created by Potari Gabor on 2016. 12. 04..
//  Copyright © 2016. Potari Gabor. All rights reserved.
//

import UIKit
import MapKit

enum MapState {
    case Normal
    case Add
}

class KruskalMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    private var mapState : MapState = .Normal
    
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Kruskal algorithm"
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        gestureRecognizer.delegate = self
        map.addGestureRecognizer(gestureRecognizer)
        
        addBarButtonItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonClicked))
        
        bottomToolBar.items?[0] = addBarButtonItem
    }
    
    func mapTapped(gestureReconizer: UITapGestureRecognizer) {
        
        switch mapState {
        case .Normal:
            break
        case .Add:
            let location = gestureReconizer.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
    }
    
    private func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
        
        pinAnnotationView.pinTintColor = .purple
        pinAnnotationView.isDraggable = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        
        let deleteButton = UIButton(type: .custom) as UIButton
        deleteButton.frame.size.width = 44
        deleteButton.frame.size.height = 44
        deleteButton.backgroundColor = UIColor.red
        //deleteButton.setImage(UIImage(named: "trash"), forState: .Normal)
        
        pinAnnotationView.leftCalloutAccessoryView = deleteButton
        
        return pinAnnotationView
    }
    
    @IBAction func addButtonClicked(_ sender: Any) {
        
        switch  self.mapState {
        case .Normal:
            addBarButtonItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(addButtonClicked))
            mapState = .Add
            break
        case .Add:
            mapState = .Normal
            addBarButtonItem = UIBarButtonItem( barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(addButtonClicked))
        }
        
        bottomToolBar.items?[0] = addBarButtonItem
    }
}
