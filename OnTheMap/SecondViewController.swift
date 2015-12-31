//
//  SecondViewController.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/22/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            } else {
                ParseClient.sharedInstance().locations = result!
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @IBAction func logout(sender: AnyObject) {
        UdacityClient.sharedInstance().logout() { (success, errorString) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    let controller = self.storyboard!.instantiateViewControllerWithIdentifier("LoginViewController")
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    if let errorString = errorString {
                        let alert = UIAlertController(title: "Logout Failed", message: errorString, preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                })
            }
        }
    }
    
    @IBAction func addStudentLocation(sender: AnyObject) {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController")
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    @IBAction func refreshData(sender: AnyObject) {
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            } else {
                ParseClient.sharedInstance().locations = result!
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "tableViewCell"
        let location = ParseClient.sharedInstance().locations[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! TableCellViewController!
        
        cell.nameTextLabel!.text = "\(location.firstName!) \(location.lastName!)"
        cell.placeTextLabel!.text = location.mapString!
        cell.urlTextLabel!.text = location.mediaURL!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance().locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        if let toOpen = ParseClient.sharedInstance().locations[indexPath.row].mediaURL {
            app.openURL(NSURL(string: toOpen)!)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}

