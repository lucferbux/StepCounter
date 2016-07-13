//
//  PedometerData.swift
//  StepCounter
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import Foundation
import WatchKit
import WatchConnectivity
import CoreMotion

// WatchConnectivity requires NSObject
class PedometerData: NSObject, WCSessionDelegate {
    
    ///Creates an instance of CMPedometer
    let pedometer = CMPedometer()
    
    var totalSteps = 0
    var totalDistance: CGFloat = 0.0
    
    var steps = 0
    var distance: CGFloat = 0.0
    var prevTotalSteps = 0
    var prevTotalDistance: CGFloat = 0.0
    var distanceUnit = "km"
    
    var appStartDate: NSDate!
    var startOfDay: NSDate!
    var endOfDay: NSDate!
    let calendar = Calendar()
    
    var session: WCSession?

    
    
    override init() {
        super.init()
        
        ///Create a session of WatchConectivity
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session!.delegate = self
            session!.activateSession()
        }
        
        setStartAndEndOfDay()
        if !loadSavedData() {
            appStartDate = startOfDay
            saveData()
            startLiveUpdates()
        }
        
    }
    
    /** Set the start and end of a Day and stores it in two variables */
    func setStartAndEndOfDay() {
        startOfDay = calendar.startOfToday
        endOfDay = calendar.startOfNextDay(startOfDay)
    }
    
    
    enum PedometerDataType {
        case Live
        case History
    }
    
    /** 
    Updates the data of a Walk session, there are two cases:
    - Live: takes the total number of steps and gets the number of today steps by substacting the value of the days before.
    - History: takes the steps from a query and add it the previous steps to get the total steps.
     
    In both cases they gives the distance and total distance 
    
    - Parameter data: The CMPedometerData
    - Parameter ofType: The type of the Pedometer Data
     */
    func updatePropertiesFrom(data: CMPedometerData,
                              ofType type: PedometerDataType) {
        switch type {
        case .Live:  // 1
            totalSteps = data.numberOfSteps.integerValue
            steps = totalSteps - prevTotalSteps
            if let rawDistance = data.distance?.integerValue
                where rawDistance > 0 {
                totalDistance = CGFloat(rawDistance) / 1000.0
                distance = totalDistance - prevTotalDistance
            }
        case .History:  // 2
            steps = data.numberOfSteps.integerValue
            totalSteps = steps + prevTotalSteps
            if let rawDistance = data.distance?.integerValue
                where rawDistance > 0 {
                distance = CGFloat(rawDistance) / 1000.0
                totalDistance = distance + prevTotalDistance
            } }
    }
    
    /** Start the lives updates, here the "startPedometerUpdatesFromDate(_:)" is called to 
     query the updates from the date given until the moment is called.
     This function checks if it is called in a new Day to stop the lives updates, query the history of the day and send it*/
    func startLiveUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.startPedometerUpdatesFromDate(appStartDate) { data,
            error in
            if let data = data {
                if self.calendar.isDate(data.endDate, afterDate: self.endOfDay){
                    self.pedometer.stopPedometerUpdates()
                    self.queryHistoryFrom(self.startOfDay, toDate: self.endOfDay)
                    return
                }
                
                
                self.updatePropertiesFrom(data, ofType: .Live)
                self.sendData(false)
            }
        }
    }
    
    /** Query the history between a selected date and call other class methods to create a new log in the
     historical data, save it and start the live updates.*/
    func queryHistoryFrom(startDate: NSDate, toDate: NSDate) {
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.queryPedometerDataFromDate(startDate, toDate:
        toDate) { data, error in
            if let data = data {
                self.updatePropertiesFrom(data, ofType: .History)
                self.sendData(true)
                self.setStartAndEndOfDay()
                self.prevTotalSteps = self.totalSteps
                self.prevTotalDistance = self.totalDistance
                self.saveData()
                
                self.startLiveUpdates()
            }
        }
    }
    
    // MARK: - Watch Connectivity
    
    /** Send the data as a dictionary through WatchConnectivity with the flag of "saveHistory" disabled */
    func sendData(sessionEnded: Bool) {
        guard let session = session else {
            return
        }
        let applicationDict = ["saveHistory":false, "sessionEnded":sessionEnded, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance]
        session.transferUserInfo(applicationDict as! [String : AnyObject])
    }
    
    /** Send the data as a dictionary through WatchConnectivity with the flag "saveHistory" enabled and the "sessionEnded" flag disabled*/
    func sendDataHistory() {
        guard let session = session else {
            return
        }
        let applicationDict = ["saveHistory":true, "sessionEnded": false, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance]
        session.transferUserInfo(applicationDict as! [String : AnyObject])
    }
    
    
    /** Data persistance method that saves all the information with the NSUserDefault object*/
    func saveData() {
        NSUserDefaults.standardUserDefaults().setObject(appStartDate, forKey: "appStartDate")
        NSUserDefaults.standardUserDefaults().setObject(startOfDay, forKey: "startOfDay")
        NSUserDefaults.standardUserDefaults().setObject(endOfDay, forKey: "endOfDay")
        NSUserDefaults.standardUserDefaults().setObject(prevTotalSteps, forKey: "prevTotalSteps")
        NSUserDefaults.standardUserDefaults().setObject(prevTotalDistance, forKey: "prevTotalDistance")
    }
    
    
    /** Data persistance method that loads all the information with the NSUserDefault objects.
     It detects a new day and call the "queriHistoryFrom(_:toDate:)" method */
    func loadSavedData() -> Bool {
        guard let savedAppStartDate = NSUserDefaults.standardUserDefaults().objectForKey("appStartDate") as? NSDate else {
            return false
        }
        appStartDate = savedAppStartDate
        let savedStartOfDay = NSUserDefaults.standardUserDefaults().objectForKey("startOfDay") as! NSDate
        let savedEndOfDay = NSUserDefaults.standardUserDefaults().objectForKey("endOfDay") as! NSDate
        if calendar.isDate(calendar.now, afterDate: savedEndOfDay) {
            // query history to finalize data for missing day
            queryHistoryFrom(savedStartOfDay, toDate: savedEndOfDay)
        } else {
            prevTotalSteps = NSUserDefaults.standardUserDefaults().objectForKey("prevTotalSteps") as! Int
            prevTotalDistance = NSUserDefaults.standardUserDefaults().objectForKey("prevTotalDistance") as! CGFloat
            startLiveUpdates()
        }
        
        return true
    }
    
}