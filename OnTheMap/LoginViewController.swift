//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/22/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var debugTextLabel: UILabel!
    
    var session: URLSession!
    var reachability: Reachability?
    var online: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = URLSession.shared
        
        setupReachability("google.com", useClosures: true)
        startNotifier()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.debugTextLabel.text = ""
    }
    
    func completeLogin() {
        DispatchQueue.main.async(execute: {
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
            self.present(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(_ errorString: String?) {
        DispatchQueue.main.async(execute: {
            if let errorString = errorString {
                let alert = UIAlertController(title: "Login Failed", message: errorString, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func loginToUdacity(_ sender: AnyObject) {
        if online {
            UdacityClient.sharedInstance().authenticate(emailTextField.text!, password: passwordTextField.text!) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    @IBAction func signUp(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "https://www.google.com/url?q=https://www.udacity.com/account/auth%23!/signin&sa=D&usg=AFQjCNHOjlXo3QS15TqT0Bp_TKoR9Dvypw")!)
    }
    
    @IBAction func loginWithFacebook(_ sender: AnyObject) {
        if online {
            UdacityClient.sharedInstance().authenticateWithViewController(self) { (success, errorString) in
                if success {
                    self.completeLogin()
                } else {
                    self.displayError(errorString)
                }
            }
        }
    }
    
    func notifyOffline() {
        let alert = UIAlertController(title: "Network Failure", message: "No network connectivity", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setupReachability(_ hostName: String?, useClosures: Bool) {
        let reachability = hostName == nil ? Reachability() : Reachability(hostname: hostName!)
        self.reachability = reachability
        
        if useClosures {
            reachability?.whenReachable = { reachability in
                DispatchQueue.main.async {
                    self.online = true
                }
            }
            reachability?.whenUnreachable = { reachability in
                DispatchQueue.main.async {
                    self.notifyOffline()
                }
            }
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged(_:)), name: ReachabilityChangedNotification, object: reachability)
        }
    }
    
    func startNotifier() {
        do {
            try reachability?.startNotifier()
        } catch {
            return
        }
    }
    
    func stopNotifier() {
        reachability?.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: ReachabilityChangedNotification, object: nil)
        reachability = nil
    }
    
    func reachabilityChanged(_ note: Notification) {
        let reachability = note.object as! Reachability
        
        if reachability.isReachable {
            online = true
        } else {
            notifyOffline()
        }
    }
    
    deinit {
        stopNotifier()
    }
}
