//
//  FirstViewController.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/22/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import UIKit
import MapKit

class FirstViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var annotations = [MKPointAnnotation]()
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                StudentLocations.sharedInstance().studentLocations = result!
                for location in result! {
                    let lat = CLLocationDegrees(location.lat!)
                    let long = CLLocationDegrees(location.long!)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = location.firstName!
                    let last = location.lastName!
                    let mediaURL = location.mediaURL
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append(annotation)
                }
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    @IBAction func logout(_ sender: AnyObject) {
        UdacityClient.sharedInstance().logout() { (success, errorString) in
            if success {
                DispatchQueue.main.async(execute: {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "LoginViewController")
                    self.present(controller, animated: true, completion: nil)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    if let errorString = errorString {
                        let alert = UIAlertController(title: "Logout Failed", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func addStudentLocation(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "InformationPostingViewController")
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshData(_ sender: AnyObject) {
        if (mapView.annotations.count > 0) {
            mapView.removeAnnotations( mapView.annotations )
        }
        
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                StudentLocations.sharedInstance().studentLocations = result!
                var annotations = [MKPointAnnotation]()
                for location in result! {
                    let lat = CLLocationDegrees(location.lat!)
                    let long = CLLocationDegrees(location.long!)
                    
                    let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    
                    let first = location.firstName!
                    let last = location.lastName!
                    let mediaURL = location.mediaURL
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = "\(first) \(last)"
                    annotation.subtitle = mediaURL
                    
                    annotations.append(annotation)
                }
                self.mapView.addAnnotations(annotations)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                app.openURL(URL(string: toOpen)!)
            }
        }
    }
}

