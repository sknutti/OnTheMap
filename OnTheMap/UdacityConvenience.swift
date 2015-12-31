//
//  UdacityConvenience.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/23/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import UIKit
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit

extension UdacityClient {
    func authenticate(username: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        getSessionID(username, password: password) { (success, sessionID, userID, errorString) in
            self.sessionID = sessionID
            self.userID = userID
            
            completionHandler(success: success, errorString: "Wrong email or password")
        }
    }
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandler: (success: Bool, errorString: String?) -> Void) {
        loginWithToken(hostViewController) { (success, sessionID, userID, errorString) in
            self.sessionID = sessionID
            self.userID = userID
            self.authenticatedWithFacebook = true
            
            completionHandler(success: success, errorString: "Unable to retrieve session")
        }
    }
    
    func getUserData(completionHandler: (success: Bool, errorString: String?) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(self.userID!)")!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error == nil {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
                    ParseClient.sharedInstance().currentStudentLocation?.uniqueKey = String(UdacityClient.sharedInstance().userID!)
                    ParseClient.sharedInstance().currentStudentLocation?.firstName = JSONResult.objectForKey("user")!["first_name"] as? String
                    ParseClient.sharedInstance().currentStudentLocation?.lastName = JSONResult.objectForKey("user")!["last_name"] as? String
                    completionHandler(success: true, errorString: nil)
                }
            }
        }
        task.resume()
    }
    
    func getSessionID(username: String, password: String, completionHandler: (success: Bool, sessionId: String?, userId: Int?, errorString: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error == nil {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                
                UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
                    let success = JSONResult.objectForKey("account")
                    
                    if (success != nil) {
                        let sessionId = JSONResult.objectForKey("session")!["id"] as? String
                        let userId = JSONResult.objectForKey("account")!["key"] as? String
                        completionHandler(success: true, sessionId: sessionId, userId: Int(userId!), errorString: nil)
                    } else {
                        print("Could not find correct values in \(JSONResult)")
                        completionHandler(success: false, sessionId: nil, userId: nil,  errorString: "Login Failed.")
                    }
                }
            }
        }
        task.resume()
    }
    
    func loginWithToken(hostViewController: UIViewController, completionHandler: (success: Bool, sessionId: String?, userId: Int?, errorString: String?) -> Void) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logInWithReadPermissions(["public_profile"], fromViewController: hostViewController, handler: { (result, error) -> Void in
            if (error == nil){
                if((FBSDKAccessToken.currentAccessToken()) != nil){
                    let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
                    request.HTTPMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(FBSDKAccessToken.currentAccessToken().tokenString)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
                    let session = NSURLSession.sharedSession()
                    let task = session.dataTaskWithRequest(request) { data, response, error in
                        if error != nil {
                            // Handle error...
                            return
                        }
                        let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                        
                        UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
                            let sessionId = JSONResult.objectForKey("session")!["id"] as? String
                            let userId = JSONResult.objectForKey("account")!["key"] as? String
                            let success = (sessionId!.characters.count > 0 && userId!.characters.count > 0)
                            
                            if success {
                                completionHandler(success: true, sessionId: sessionId, userId: Int(userId!), errorString: nil)
                            } else {
                                print("Could not find correct values in \(JSONResult)")
                                completionHandler(success: false, sessionId: nil, userId: nil,  errorString: "Login Failed.")
                            }
                        }
                    }
                    task.resume()
                }
            }
        })
    }
    
    func logout(completionHandler: (success: Bool, errorString: String?) -> Void) {
        if ((self.authenticatedWithFacebook) != nil) {
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            
            completionHandler(success: true, errorString: nil)
        } else {
            let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
            request.HTTPMethod = "DELETE"
            var xsrfCookie: NSHTTPCookie? = nil
            let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithRequest(request) { data, response, error in
                if error == nil {
                    let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))                     
                    UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
                        if (JSONResult.objectForKey("account") == nil) {
                            completionHandler(success: true, errorString: nil)
                        } else {
                            print("Could not find correct values in \(JSONResult)")
                            completionHandler(success: false, errorString: "Logout Failed.")
                        }
                    }
                }
            }
            task.resume()
        }
        self.sessionID = nil
        self.userID = nil
    }
}