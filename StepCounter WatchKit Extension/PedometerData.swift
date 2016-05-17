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
    
    //Variables and constants
    // sample pedometer data
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
        
        //Create a session of WatchConectivity
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
    
    // TODO: Change this for a session
    func setStartAndEndOfDay() {
        startOfDay = calendar.startOfToday
        endOfDay = calendar.startOfNextDay(startOfDay)
    }
    
    // TODO: Change the live with the history
    enum PedometerDataType {
        case Live
        case History
    }
    

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
    
    // TODO: Change to when session is finished
    func sendData(sessionEnded: Bool) {
        guard let session = session else {
            return
        }
        let applicationDict = ["saveHistory":false, "sessionEnded":sessionEnded, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance]
        session.transferUserInfo(applicationDict as! [String : AnyObject])
    }
    
    func sendDataHistory() {
        
        guard let session = session else {
            return
        }
        let applicationDict = ["saveHistory":true, "sessionEnded": false, "steps":steps, "distance":distance, "totalSteps": totalSteps, "totalDistance": totalDistance]
        session.transferUserInfo(applicationDict as! [String : AnyObject])
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        NSUserDefaults.standardUserDefaults().setObject(appStartDate, forKey: "appStartDate")
        NSUserDefaults.standardUserDefaults().setObject(startOfDay, forKey: "startOfDay")
        NSUserDefaults.standardUserDefaults().setObject(endOfDay, forKey: "endOfDay")
        NSUserDefaults.standardUserDefaults().setObject(prevTotalSteps, forKey: "prevTotalSteps")
        NSUserDefaults.standardUserDefaults().setObject(prevTotalDistance, forKey: "prevTotalDistance")
    }
    
    
    
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