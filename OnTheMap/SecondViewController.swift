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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                StudentLocations.sharedInstance().studentLocations = result!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
        ParseClient.sharedInstance().getStudentLocations() { (result, error) in
            if error != nil {
                DispatchQueue.main.async(execute: {
                    let alert = UIAlertController(title: "Download Failed", message: "Unable to download list of student locations.", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                })
            } else {
                StudentLocations.sharedInstance().studentLocations = result!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

extension SecondViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "tableViewCell"
        let location = StudentLocations.sharedInstance().studentLocations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! TableCellViewController!
        
        cell?.nameTextLabel!.text = "\(location.firstName!) \(location.lastName!)"
        cell?.placeTextLabel!.text = location.mapString!
        cell?.urlTextLabel!.text = location.mediaURL!
        return cell!
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentLocations.sharedInstance().studentLocations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = StudentLocations.sharedInstance().studentLocations[indexPath.row].mediaURL {
            app.openURL(URL(string: toOpen)!)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

