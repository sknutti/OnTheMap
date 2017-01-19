//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/28/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudentLocations(_ completionHandler: @escaping (_ result: [StudentLocation]?, _ error: NSError?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            "limit": 100 as AnyObject,
//            "skip": 100,
            "order": "-updatedAt" as AnyObject
        ]
        
        _ = taskForGETMethod(parameters) { JSONResult, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = JSONResult?["results"] as? [[String : AnyObject]] {
                    let locations = StudentLocation.locationsFromResults(results)
                    completionHandler(locations, nil)
                } else {
                    completionHandler(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    func postLocation(_ jsonBody: String, completionHandler: @escaping (_ result: String?, _ error: NSError?) -> Void) {
        _ = taskForPOSTMethod(jsonBody) { JSONResult, error in
            if let error = error {
                completionHandler(nil, error)
            } else {
                if let results = JSONResult?["objectId"] as? String {
                    completionHandler(results, nil)
                } else {
                    completionHandler(nil, NSError(domain: "postLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postLocation response"]))
                }
            }
        }
    }
}
