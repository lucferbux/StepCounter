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
    private struct CodingKeys {
        static let date = "date"
        static let steps = "steps"
        static let distance = "distance"
        static let totalSteps = "totalSteps"
        static let totalDistance = "totalDistance"
    }

//A convenience init setting the attributes with values extracted of persistent data
    convenience init(coder aDecoder: NSCoder) {
        let date = aDecoder.decodeObjectForKey(CodingKeys.date) as! NSDate
        let steps = aDecoder.decodeIntegerForKey(CodingKeys.steps)
        let distance = aDecoder.decodeDoubleForKey(CodingKeys.distance)
        let totalSteps = aDecoder.decodeIntegerForKey(CodingKeys.totalSteps)
        let totalDistance = aDecoder.decodeDoubleForKey(CodingKeys.totalDistance)
        self.init(date: date, steps: steps, distance: distance, totalSteps: totalSteps, totalDistance: totalDistance)
    }
    

    func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(date, forKey: CodingKeys.date)
        encoder.encodeInteger(steps, forKey: CodingKeys.steps)
        encoder.encodeDouble(distance, forKey: CodingKeys.distance)
        encoder.encodeInteger(totalSteps, forKey: CodingKeys.totalSteps)
        encoder.encodeDouble(totalDistance, forKey: CodingKeys.totalDistance)
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
        let dictionary = ["date":self.date, "steps": self.steps, "distance": self.distance, "totalSteps": self.totalSteps, "totalDistance": self.totalDistance]
        return dictionary
    }
    
}