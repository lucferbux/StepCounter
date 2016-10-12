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
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }

    
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
            session = WCSession.default()
            session!.delegate = self
            session!.activate()
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
        endOfDay = calendar.startOfNextDay(date: startOfDay)
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
            totalSteps = data.numberOfSteps.intValue
            steps = totalSteps - prevTotalSteps
            if let rawDistance = data.distance?.intValue
                , rawDistance > 0 {
                totalDistance = CGFloat(rawDistance) / 1000.0
                distance = totalDistance - prevTotalDistance
            }
        case .History:  // 2
            steps = data.numberOfSteps.intValue
            totalSteps = steps + prevTotalSteps
            if let rawDistance = data.distance?.intValue
                , rawDistance > 0 {
                distance = CGFloat(rawDistance) / 1000.0
                totalDistance = distance + prevTotalDistance
            } }
    }
    
    /** Start the lives updates, here the "startPedometerUpdatesFromDate(_:)" is called to 
     query the updates from the date given until the moment is called.
     This function checks if it is called in a new Day to stop the lives updates, query the history of the day and send it*/
    func startLiveUpdates() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.startUpdates(from: appStartDate as Date) { data,
            error in
            if let data = data {
                if self.calendar.isDate(date1: data.endDate as NSDate, afterDate: self.endOfDay){
                    self.pedometer.stopUpdates()
                    self.queryHistoryFrom(startDate: self.startOfDay, toDate: self.endOfDay)
                    return
                }
                
                
                self.updatePropertiesFrom(data: data, ofType: .Live)
                self.sendData(sessionEnded: false)
            }
        }
    }
    
    /** Query the history between a selected date and call other class methods to create a new log in the
     historical data, save it and start the live updates.*/
    func queryHistoryFrom(startDate: NSDate, toDate: NSDate) {
        guard CMPedometer.isStepCountingAvailable() else { return }
        pedometer.queryPedometerData(from: startDate as Date, to:
        toDate as Date) { data, error in
            if let data = data {
                self.updatePropertiesFrom(data: data, ofType: .History)
                self.sendData(sessionEnded: true)
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
        let applicationDict = ["saveHistory":false, "sessionEnded":sessionEnded, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance] as [String : Any]
        session.transferUserInfo(applicationDict as [String : Any])
    }
    
    /** Send the data as a dictionary through WatchConnectivity with the flag "saveHistory" enabled and the "sessionEnded" flag disabled*/
    func sendDataHistory() {
        guard let session = session else {
            return
        }
        let applicationDict = ["saveHistory":true, "sessionEnded": false, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance] as [String : Any]
        session.transferUserInfo(applicationDict as [String : Any])
    }
    
    
    /** Data persistance method that saves all the information with the NSUserDefault object*/
    func saveData() {
        UserDefaults.standard.set(appStartDate, forKey: "appStartDate")
        UserDefaults.standard.set(startOfDay, forKey: "startOfDay")
        UserDefaults.standard.set(endOfDay, forKey: "endOfDay")
        UserDefaults.standard.set(prevTotalSteps, forKey: "prevTotalSteps")
        UserDefaults.standard.set(prevTotalDistance, forKey: "prevTotalDistance")
    }
    
    
    /** Data persistance method that loads all the information with the NSUserDefault objects.
     It detects a new day and call the "queriHistoryFrom(_:toDate:)" method */
    func loadSavedData() -> Bool {
        guard let savedAppStartDate = UserDefaults.standard.object(forKey: "appStartDate") as? NSDate else {
            return false
        }
        appStartDate = savedAppStartDate
        let savedStartOfDay = UserDefaults.standard.object(forKey: "startOfDay") as! NSDate
        let savedEndOfDay = UserDefaults.standard.object(forKey: "endOfDay") as! NSDate
        if calendar.isDate(date1: calendar.now, afterDate: savedEndOfDay) {
            // query history to finalize data for missing day
            queryHistoryFrom(startDate: savedStartOfDay, toDate: savedEndOfDay)
        } else {
            prevTotalSteps = UserDefaults.standard.object(forKey: "prevTotalSteps") as! Int
            prevTotalDistance = UserDefaults.standard.object(forKey: "prevTotalDistance") as! CGFloat
            startLiveUpdates()
        }
        
        return true
    }
    
}
