//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Scott Knutti on 12/28/15.
//  Copyright © 2015 Scott Knutti. All rights reserved.
//

struct StudentLocation {
    
    var objectId: String? = "none"
    var uniqueKey: String?
    var firstName: String? = nil
    var lastName: String? = nil
    var mapString: String? = nil
    var mediaURL: String? = "No url set"
    var lat: Double?
    var long: Double?
    
    var jsonRepresentation : String {
        return "{\"uniqueKey\":\"\(uniqueKey!)\",\"firstName\":\"\(firstName!)\",\"lastName\":\"\(lastName!)\",\"mapString\":\"\(mapString!)\",\"mediaURL\":\"\(mediaURL!)\",\"latitude\":\(lat!),\"longitude\":\(long!)}"
    }
    
    init() {
        
    }
    
    init(dictionary: [String : AnyObject]) {
        
        objectId = dictionary["objectId"] as? String
        uniqueKey = String(describing: UdacityClient.sharedInstance().userID)
        firstName = dictionary["firstName"] as? String
        lastName = dictionary["lastName"] as? String
        mapString = dictionary["mapString"] as? String
        mediaURL = dictionary["mediaURL"] as? String
        
        lat = dictionary["latitude"] as? Double
        long = dictionary["longitude"] as? Double
    }
    
    static func toJSONString(_ array : [StudentLocation]) -> String {
        return array.map {$0.jsonRepresentation}.joined(separator: ",")
    }
    
    static func locationsFromResults(_ results: [[String : AnyObject]]) -> [StudentLocation] {
        var locations = [StudentLocation]()
        
        for result in results {
            locations.append(StudentLocation(dictionary: result))
        }
        
        return locations
    }
}
