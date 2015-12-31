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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        activityIndicator.hidden = true
        activityIndicator.hidesWhenStopped = true
        toggleElements(true)
        locationTextView.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextView.delegate = self;
        urlTextView.delegate = self;
        
        dispatch_async(dispatch_get_main_queue(), {
            UdacityClient.sharedInstance().getUserData() { success, error in
                /* successfully retrieved name from Udacity */
            }
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func toggleElements(initial: Bool) {
        text1.hidden = !initial
        text2.hidden = !initial
        text3.hidden = !initial
        button.hidden = !initial
        locationTextView.hidden = !initial
        
        urlTextView.hidden = initial
        map.hidden = initial
        submitButton.hidden = initial
    }
    
    @IBAction func cancelPosting(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func geocodeLocation(sender: AnyObject) {
        /* got this code from http://stackoverflow.com/questions/24706885/how-can-i-plot-addresses-in-swift-converting-address-to-longitude-and-latitude */
        activityIndicator.startAnimating()
        activityIndicator.hidden = false
        
        let address = locationTextView.text
        ParseClient.sharedInstance().currentStudentLocation?.mapString = address
        if address.characters.count < 1 {
            let alert = UIAlertController(title: "Missing Data", message: "You must enter a location to find.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: {(placemarks, error) -> Void in
            if((error) != nil){
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "Error", message: "Error during geocoding", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
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
    
    @IBAction func postLocation(sender: AnyObject) {
        ParseClient.sharedInstance().currentStudentLocation?.mediaURL = urlTextView.text
        
        
        let jsonBody = StudentLocation.toJSONString([ParseClient.sharedInstance().currentStudentLocation!])
        ParseClient.sharedInstance().postLocation(jsonBody) { objectId, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Error", message: "Unable to post the location.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController")
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            }
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor.redColor()
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
}