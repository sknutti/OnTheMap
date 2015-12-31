//
//  StudentLocations.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/30/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

import Foundation

class StudentLocations {
    class func sharedInstance() -> StudentLocations {
        
        struct Singleton {
            static var sharedInstance = StudentLocations()
        }
        
        return Singleton.sharedInstance
    }
    
    var studentLocations:[StudentLocation] = [StudentLocation]()
}