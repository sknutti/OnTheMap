//
//  ParseConvenience.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/28/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import Foundation

extension ParseClient {
    
    func getStudentLocations(completionHandler: (result: [StudentLocation]?, error: NSError?) -> Void) {
        
        let parameters: [String: AnyObject] = [
            "limit": 100,
//            "skip": 100,
            "order": "-updatedAt"
        ]
        
        taskForGETMethod(parameters) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult["results"] as? [[String : AnyObject]] {
                    let locations = StudentLocation.locationsFromResults(results)
                    completionHandler(result: locations, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    func postLocation(jsonBody: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        taskForPOSTMethod(jsonBody) { JSONResult, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                if let results = JSONResult["objectId"] as? String {
                    completionHandler(result: results, error: nil)
                } else {
                    completionHandler(result: nil, error: NSError(domain: "postLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postLocation response"]))
                }
            }
        }
    }
}