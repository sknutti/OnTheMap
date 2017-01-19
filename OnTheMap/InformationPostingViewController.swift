//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/29/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class InformationPostingViewController: UIViewController, MKMapViewDelegate, UITextViewDelegate {
    
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var text1: UILabel!
    @IBOutlet weak var text2: UILabel!
    @IBOutlet weak var text3: UILabel!
    @IBOutlet weak var button: UIButton!
    
    @IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var studentLocation: StudentLocation? = nil
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.isHidden = true
        activityIndicator.hidesWhenStopped = true
        toggleElements(true)
        locationTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self;
        urlTextView.delegate = self;
        
        DispatchQueue.main.async(execute: {
            UdacityClient.sharedInstance().getUserData() { success, error in
                /* successfully retrieved name from Udacity */
            }
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func toggleElements(_ initial: Bool) {
        text1.isHidden = !initial
        text2.isHidden = !initial
        text3.isHidden = !initial
        button.isHidden = !initial
        locationTextView.isHidden = !initial
        
        urlTextView.isHidden = initial
        map.isHidden = initial
        submitButton.isHidden = initial
    }
    
    @IBAction func cancelPosting(_ sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func geocodeLocation(_ sender: AnyObject) {
        /* got this code from http://stackoverflow.com/questions/24706885/how-can-i-plot-addresses-in-swift-converting-address-to-longitude-and-latitude */
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        
        let address = locationTextView.text
        ParseClient.sharedInstance().currentStudentLocation?.mapString = address
        if (address?.characters.count)! < 1 {
            let alert = UIAlertController(title: "Missing Data", message: "You must enter a location to find.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address!, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Error during geocoding", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            if let placemark = placemarks?.first {
                if let coordinates:CLLocationCoordinate2D = placemark.location!.coordinate {
                    ParseClient.sharedInstance().currentStudentLocation?.lat = coordinates.latitude
                    ParseClient.sharedInstance().currentStudentLocation?.long = coordinates.longitude
                    let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                    let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    
                    var annotations = [MKPointAnnotation]()
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotations.append(annotation)
                    self.map.addAnnotations(annotations)
                    
                    self.map.setRegion(region, animated: true)
                    
                    self.toggleElements(false)
                    self.activityIndicator.stopAnimating()
                } else {
                    
                }
            }
        })
        urlTextView.becomeFirstResponder()
    }
    
    @IBAction func postLocation(_ sender: AnyObject) {
        ParseClient.sharedInstance().currentStudentLocation?.mediaURL = urlTextView.text
        
        
        let jsonBody = StudentLocation.toJSONString([ParseClient.sharedInstance().currentStudentLocation!])
        ParseClient.sharedInstance().postLocation(jsonBody) { objectId, error in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Error", message: "Unable to post the location.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                DispatchQueue.main.async(execute: {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController")
                    self.present(controller, animated: true, completion: nil)
                })
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
}
