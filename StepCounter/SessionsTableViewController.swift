//
//  SessionsTableViewController.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import UIKit
import MapKit
import WatchConnectivity

//Estension which casts an string to an NSSTring
extension String {
    var NS: NSString { return (self as NSString) }
}

class SessionsTableViewController: UITableViewController, WCSessionDelegate {

    var session: WCSession?
    
    /** Creates a lazy reference of a Walk array, loading all the Walks of the property list Walks.plist */
    lazy var walks: [Walk] = {
        let path = NSBundle.mainBundle().pathForResource("Walks", ofType: "plist")
        let arrayOfDicts = NSArray(contentsOfFile: path!)!
        var array = [Walk]()
        for i in 0..<arrayOfDicts.count {
            let walk = Walk.convertDictToWalk(arrayOfDicts[i] as! [String : AnyObject])
            array.append(walk)
        }
        return array as Array
    }()
    
    /** Store the History data in a mutable Array to wirte it after in a property list*/
    var storedHistoryPlist = NSMutableArray()
    
    var history = [SessionData]()
    var currentDistance: CGFloat {
        return CGFloat(history[0].distance)
    }
    
    let distanceUnit = "km"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //If there is no previous session a new SessionData instance is inserted in the history array
        if !loadSavedData() {
            history.insert(SessionData(), atIndex: 0)
            
        }
        loadSavedHistoryData()
        
        /** Activate session *after* loading data, so receiver has somewhere to store data */
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session!.delegate = self;
            session!.activateSession()
        } else {
            print("Session not supported")
        }
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walks.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("WalkCell", forIndexPath: indexPath)
        let walk = walks[indexPath.row]
        cell.textLabel!.text = walk.walkTitle
        let formattedString = String(format:"%.1f", walk.completions(currentDistance))
        cell.detailTextLabel!.text = "\(Int(walk.goal))km completed \(formattedString) times today"
        
        return cell
    }
    
    // Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWalk" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let walk = walks[indexPath.row]
                let walkController = segue.destinationViewController as! WalkViewController
                walkController.title = walk.walkTitle
                walkController.walk = walk
                walkController.distanceUnit = distanceUnit
                walkController.completions = walk.completions(currentDistance)
                walkController.completionString = String(format:"%.1f", walkController.completions)
            }
        }
        
        if segue.identifier == "showHistory" {
            let historyController = segue.destinationViewController as! HistoryTableViewController
            historyController.history = history
            historyController.distanceUnit = distanceUnit
        }
    }
    
    
    /** Recives data from the WatchConnectivity session and store it, deppending on the flag,
     "sessionEnded" create a new entry in the array and "saveHistory" saves the record in the property list */
    func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        history[0].steps = userInfo["steps"] as! Int
        history[0].totalSteps = userInfo["totalSteps"] as! Int
        history[0].distance = userInfo["distance"] as! Double
        history[0].totalDistance = userInfo["totalDistance"] as! Double
        if userInfo["sessionEnded"] as! Bool {
            saveHistoryData()
            let sessionData = SessionData(date: NSDate(), steps: 0, distance: 0.0, totalSteps: history[0].totalSteps, totalDistance: history[0].totalDistance)
            
            history.insert(sessionData, atIndex: 0)
        }
        
        if userInfo["saveHistory"] as! Bool {
            saveHistoryData()
        }
        
        saveData()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
        }
    }
    
    
    
    
    /** Saves the path of the data encoded */
    var savedDataPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = paths.first!
        return docPath.NS.stringByAppendingPathComponent("SavedData")
    }
    
    /** Load the encoded dat */
    func loadSavedData() -> Bool {
        if let data = NSData(contentsOfFile: savedDataPath) {
            let savedData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [SessionData]
            history = savedData
            return true
        } else {
            return false
        }
    }
    
    /** Saves the data enconded*/
    func saveData() {
        if NSKeyedArchiver.archiveRootObject(history, toFile: savedDataPath) {
            print("data archived")
        } else {
            print("data not archived")
        }
    }
    
    /** Load the data from the property list */
    func loadSavedHistoryData() -> Bool {
        if let historyPlist = HistoryData(name: "HistoryData"){
            storedHistoryPlist = historyPlist.getMutablePlistFile()!
            return true
        }else{
            return false
        }
    }
    
    
    /** Saves the data from the property list */
    func saveHistoryData(){
        
        storedHistoryPlist.addObject(history[0].convertHistoryToDict())
        
        if let historyPlist = HistoryData(name: "HistoryData"){
            do{
                try historyPlist.addValuesToPlistFile(storedHistoryPlist)
            } catch {
                print(error)
            }
        }
    }

}
