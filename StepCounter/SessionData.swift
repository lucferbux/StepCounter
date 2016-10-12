//
//  SessionData.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation

//Main class, it stores the session of a Workout Day, both as a Dictionary and NSCode data for persistance

final class SessionData: NSObject {
    var date = NSDate()
    var steps = 0
    var distance = 0.0
    var totalSteps = 0
    var totalDistance = 0.0
    
    convenience init(date: NSDate, steps: Int, distance: Double, totalSteps: Int, totalDistance: Double) {
        self.init()
        self.date = date
        self.steps = steps
        self.distance = distance
        self.totalSteps = totalSteps
        self.totalDistance = totalDistance
    }
}

//Creates an extension with the coding Keys assigned to the attributes
extension SessionData: NSCoding {
    public func encode(with aCoder: NSCoder) {
        
    }

    private struct CodingKeys {
        static let date = "date"
        static let steps = "steps"
        static let distance = "distance"
        static let totalSteps = "totalSteps"
        static let totalDistance = "totalDistance"
    }

//A convenience init setting the attributes with values extracted of persistent data
    convenience init(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObject(forKey: CodingKeys.date) as! NSDate
        let steps = aDecoder.decodeInteger(forKey: CodingKeys.steps)
        let distance = aDecoder.decodeDouble(forKey: CodingKeys.distance)
        let totalSteps = aDecoder.decodeInteger(forKey: CodingKeys.totalSteps)
        let totalDistance = aDecoder.decodeDouble(forKey: CodingKeys.totalDistance)
        self.init(date: date, steps: steps, distance: distance, totalSteps: totalSteps, totalDistance: totalDistance)
    }
    

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encode(date, forKey: CodingKeys.date)
        encoder.encode(steps, forKey: CodingKeys.steps)
        encoder.encode(distance, forKey: CodingKeys.distance)
        encoder.encode(totalSteps, forKey: CodingKeys.totalSteps)
        encoder.encode(totalDistance, forKey: CodingKeys.totalDistance)
    }
  
//This function convert a dictionary to an object, in order to get the items from the property list
    class func convertDictToHistory(dict: [String: AnyObject]) -> SessionData {
        let date = dict["date"] as! NSDate
        let steps = dict["steps"] as! Int
        let distance = dict["distance"] as! Double
        let totalSteps = dict["totalSteps"] as! Int
        let totalDistance = dict["totalDistance"] as! Double
        return SessionData(date: date, steps: steps, distance: distance, totalSteps: totalSteps, totalDistance: totalDistance)
    }
//Function which converts a SessionData object into a Dictionary in order to store it
    func convertHistoryToDict() -> [String: AnyObject] {
        let dictionary = ["date":self.date, "steps": self.steps, "distance": self.distance, "totalSteps": self.totalSteps, "totalDistance": self.totalDistance] as [String : Any]
        return dictionary as [String : AnyObject]
    }
    
}
