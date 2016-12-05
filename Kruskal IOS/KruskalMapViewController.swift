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

struct Edge {
    var weight: Double
    var from: CLLocationCoordinate2D
    var to: CLLocationCoordinate2D
}

class KruskalMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {
    var addBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    private var mapState : MapState = .Normal
    private var selectedAnnotation: MKPointAnnotation?
    private var nodeCoordinates: [CLLocationCoordinate2D] = []
    private var resultNodes: [[CLLocationCoordinate2D]] = []
    private var distances: [Edge] = []
    
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
        map.delegate = self
    }
    
    func mapTapped(gestureReconizer: UITapGestureRecognizer) {
        
        switch mapState {
        case .Normal:
            break
        case .Add:
            let location = gestureReconizer.location(in: map)
            let coordinate = map.convert(location,toCoordinateFrom: map)
            updateDistances(coordinate: coordinate)
            nodeCoordinates.append(coordinate)
            resultNodes.append([coordinate])
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            map.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            selectedAnnotation = view.annotation as? MKPointAnnotation
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .blue
        polylineRenderer.lineWidth = 2
        return polylineRenderer
    }
    
    
    private func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    
        let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "node")
        
        pinAnnotationView.pinTintColor = .purple
        pinAnnotationView.isDraggable = true
        pinAnnotationView.canShowCallout = true
        pinAnnotationView.animatesDrop = true
        
        let deleteButton = UIButton(type: .custom) as UIButton
        deleteButton.frame.size.width = 44
        deleteButton.frame.size.height = 44
        deleteButton.backgroundColor = UIColor.red
        //deleteButton.setImage(UIImage(named: "trash"), forState: .Normal)
        pinAnnotationView.tag = map.annotations.count
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
    @IBAction func deleteButtonClicked(_ sender: Any) {
        
        guard let currentAnnotation = selectedAnnotation else {
            return
        }
        
        nodeCoordinates.forEach {
            node in
            let d = MKMetersBetweenMapPoints(MKMapPointForCoordinate(currentAnnotation.coordinate), MKMapPointForCoordinate(node));
            distances = distances.filter { $0.weight != d }
        }
        
        nodeCoordinates = nodeCoordinates.filter {
            $0.latitude != currentAnnotation.coordinate.latitude &&
            $0.longitude != currentAnnotation.coordinate.longitude
        }
        
        selectedAnnotation = nil
        map.removeAnnotation(currentAnnotation)
        
    }
    
    func updateDistances(coordinate : CLLocationCoordinate2D) {
        
        if nodeCoordinates.count == 0 {
            return
        }
        
        var resultDistances = distances
        nodeCoordinates.forEach {
           distance in
            let d = MKMetersBetweenMapPoints(MKMapPointForCoordinate(coordinate), MKMapPointForCoordinate(distance));
            resultDistances.append(Edge(weight: d, from: coordinate, to: distance))
        }
        
        self.distances = resultDistances
        self.distances.sort { return $0.weight < $1.weight }
    }
    
    @IBAction func playButtonClicked(_ sender: UIBarButtonItem) {
        makeStep()
    }
    
    func makeStep() {
        
        if resultNodes.count < 2 {
            return
        }

        let edge = getMinimumEdge()
        let polyline = MKPolyline(coordinates: [edge.from, edge.to], count: 2)
        self.map.add(polyline)
        distances.remove(at: 0)
    }
    
    func getMinimumEdge() -> Edge {
        for i in 0...distances.count {
            let actEdge = distances[i]
            let firstIndex = resultNodes.index(where: { $0.contains(where: {
                $0.latitude == actEdge.from.latitude &&
                $0.longitude == actEdge.from.longitude
            }) } )
            
            let secondIndex = resultNodes.index(where: { $0.contains(where: {
                $0.latitude == actEdge.to.latitude &&
                $0.longitude == actEdge.to.longitude
            }) } )
            
            if firstIndex != secondIndex {
               resultNodes[firstIndex!].append(contentsOf: resultNodes[secondIndex!])
                resultNodes[secondIndex!] = resultNodes[secondIndex!].filter{ $0.latitude != actEdge.to .latitude && $0.longitude != actEdge.to.longitude }
                resultNodes.remove(at: secondIndex!)
               return actEdge
            }
        }
        
        return distances.last!
    }
}
