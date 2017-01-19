//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/28/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import Foundation

class ParseClient : NSObject {
    
    /* Shared session */
    var session: URLSession
    
    var currentStudentLocation: StudentLocation? = StudentLocation()
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    func taskForGETMethod(_ parameters: [String : AnyObject], completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let mutableParameters = parameters
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation" + ParseClient.escapedParameters(mutableParameters)
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, error as NSError?)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(nil, NSError(domain: "Parse API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not download data"]))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }) 
        
        task.resume()
        
        return task
    }
    
    func taskForPOSTMethod(_ jsonBody: String, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        let urlString = "https://api.parse.com/1/classes/StudentLocation"
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, error as NSError?)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                completionHandler(nil, NSError(domain: "Parse API Error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not post data"]))
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                return
            }
            
            ParseClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
        }) 
        
        task.resume()
        
        return task
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult as AnyObject?, nil)
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    class func sharedInstance() -> ParseClient {
        
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        
        return Singleton.sharedInstance
    }
}
