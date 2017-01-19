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
    func authenticate(_ username: String, password: String, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        getSessionID(username, password: password) { (success, sessionID, userID, errorString) in
            self.sessionID = sessionID
            self.userID = userID
            
            completionHandler(success, "Wrong email or password")
        }
    }
    
    func authenticateWithViewController(_ hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        loginWithToken(hostViewController) { (success, sessionID, userID, errorString) in
            self.sessionID = sessionID
            self.userID = userID
            self.authenticatedWithFacebook = true
            
            completionHandler(success, "Unable to retrieve session")
        }
    }
    
    func getUserData(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/users/\(self.userID!)")!)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
//                let newData = data!.subdata(in: NSRange(location: 5, length: data!.count - 5)) /* subset response data! */
//                
//                UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
//                    ParseClient.sharedInstance().currentStudentLocation?.uniqueKey = String(UdacityClient.sharedInstance().userID!)
//                    ParseClient.sharedInstance().currentStudentLocation?.firstName = JSONResult.object(forKey: "user")!["first_name"] as? String
//                    ParseClient.sharedInstance().currentStudentLocation?.lastName = JSONResult.object(forKey: "user")!["last_name"] as? String
//                    completionHandler(success: true, errorString: nil)
//                }
            }
        })
        task.resume()
    }
    
    func getSessionID(_ username: String, password: String, completionHandler: @escaping (_ success: Bool, _ sessionId: String?, _ userId: Int?, _ errorString: String?) -> Void) {
        
        var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            if error == nil {
//                let responseData = String(data: data!, encoding: .utf8)
                let newData = data//.subdata(in: NSRange(location: 5, length: data!.count - 5)) /* subset response data! */
                
                UdacityClient.parseJSONWithCompletionHandler(newData!) { (JSONResult, errorString) in
//                    let success = JSONResult.objectForKey("account")
//                    if (success != nil) {
//                        let sessionId = JSONResult.objectForKey("session")!["id"] as? String
//                        let userId = JSONResult.objectForKey("account")!["key"] as? String
//                        completionHandler(success: true, sessionId: sessionId, userId: Int(userId!), errorString: nil)
//                    } else {
//                        print("Could not find correct values in \(JSONResult)")
//                        completionHandler(success: false, sessionId: nil, userId: nil,  errorString: "Login Failed.")
//                    }
                }
            }
        }) 
        task.resume()
    }
    
    func loginWithToken(_ hostViewController: UIViewController, completionHandler: @escaping (_ success: Bool, _ sessionId: String?, _ userId: Int?, _ errorString: String?) -> Void) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile"], from: hostViewController, handler: { (result, error) -> Void in
            if (error == nil){
                if((FBSDKAccessToken.current()) != nil){
                    var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
                    request.httpMethod = "POST"
                    request.addValue("application/json", forHTTPHeaderField: "Accept")
                    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = "{\"facebook_mobile\": {\"access_token\": \"\(FBSDKAccessToken.current().tokenString)\"}}".data(using: String.Encoding.utf8)
                    let session = URLSession.shared
                    let task = session.dataTask(with: request, completionHandler: { data, response, error in
                        if error != nil {
                            // Handle error...
                            return
                        }
//                        let newData = data!.subdata(in: NSMakeRange(5, data!.count - 5)) /* subset response data! */
//                        
//                        UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
//                            let sessionId = JSONResult.object(forKey: "session")!["id"] as? String
//                            let userId = JSONResult.object(forKey: "account")!["key"] as? String
//                            let success = (sessionId!.characters.count > 0 && userId!.characters.count > 0)
//                            
//                            if success {
//                                completionHandler(success: true, sessionId: sessionId, userId: Int(userId!), errorString: nil)
//                            } else {
//                                print("Could not find correct values in \(JSONResult)")
//                                completionHandler(success: false, sessionId: nil, userId: nil,  errorString: "Login Failed.")
//                            }
//                        }
                    })
                    task.resume()
                }
            }
        })
    }
    
    func logout(_ completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        if ((self.authenticatedWithFacebook) != nil) {
            let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
            fbLoginManager.logOut()
            
            completionHandler(true, nil)
        } else {
            var request = URLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
            request.httpMethod = "DELETE"
            var xsrfCookie: HTTPCookie? = nil
            let sharedCookieStorage = HTTPCookieStorage.shared
            for cookie in sharedCookieStorage.cookies! {
                if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
            }
            if let xsrfCookie = xsrfCookie {
                request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
            }
            let session = URLSession.shared
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil {
//                    let newData = data!.subdata(in: NSRange(location: 5, length: data!.count - 5))
//                    UdacityClient.parseJSONWithCompletionHandler(newData) { (JSONResult, errorString) in
//                        if (JSONResult.object(forKey: "account") == nil) {
//                            completionHandler(success: true, errorString: nil)
//                        } else {
//                            print("Could not find correct values in \(JSONResult)")
//                            completionHandler(success: false, errorString: "Logout Failed.")
//                        }
//                    }
                }
            }) 
            task.resume()
        }
        self.sessionID = nil
        self.userID = nil
    }
}
