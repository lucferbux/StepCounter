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
    /** Called when all delegate callbacks for the previously selected watch has occurred. The session can be re-activated for the now selected watch using activateSession. */
    @available(iOS 9.3, *)
    public func sessionDidDeactivate(_ session: WCSession) {
        
    }

    /** Called when the session can no longer be used to modify or add any new transfers and, all interactive messages will be cancelled, but delegate callbacks for background transfers can still occur. This will happen when the selected watch is being changed. */
    @available(iOS 9.3, *)
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }

    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(iOS 9.3, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    var session: WCSession?
    
    /** Creates a lazy reference of a Walk array, loading all the Walks of the property list Walks.plist */
    lazy var walks: [Walk] = {
        let path = Bundle.main.path(forResource: "Walks", ofType: "plist")
        let arrayOfDicts = NSArray(contentsOfFile: path!)!
        var array = [Walk]()
        for i in 0..<arrayOfDicts.count {
            let walk = Walk.convertDictToWalk(dict: arrayOfDicts[i] as! [String : AnyObject])
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
            history.insert(SessionData(), at: 0)
            
        }
        loadSavedHistoryData()
        
        /** Activate session *after* loading data, so receiver has somewhere to store data */
        if (WCSession.isSupported()) {
            session = WCSession.default()
            session!.delegate = self;
            session!.activate()
        } else {
            print("Session not supported")
        }
    }
    
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return walks.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WalkCell", for: indexPath as IndexPath)
        let walk = walks[indexPath.row]
        cell.textLabel!.text = walk.walkTitle
        let formattedString = String(format:"%.1f", walk.completions(distance: currentDistance))
        cell.detailTextLabel!.text = "\(Int(walk.goal))km completed \(formattedString) times today"
        
        return cell
    }
    
    // Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWalk" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let walk = walks[indexPath.row]
                let walkController = segue.destination as! WalkViewController
                walkController.title = walk.walkTitle
                walkController.walk = walk
                walkController.distanceUnit = distanceUnit
                walkController.completions = walk.completions(distance: currentDistance)
                walkController.completionString = String(format:"%.1f", walkController.completions)
            }
        }
        
        if segue.identifier == "showHistory" {
            let historyController = segue.destination as! HistoryTableViewController
            historyController.history = history
            historyController.distanceUnit = distanceUnit
        }
    }
    
    
    /** Recives data from the WatchConnectivity session and store it, deppending on the flag,
     "sessionEnded" create a new entry in the array and "saveHistory" saves the record in the property list */
    private func session(session: WCSession, didReceiveUserInfo userInfo: [String : AnyObject]) {
        history[0].steps = userInfo["steps"] as! Int
        history[0].totalSteps = userInfo["totalSteps"] as! Int
        history[0].distance = userInfo["distance"] as! Double
        history[0].totalDistance = userInfo["totalDistance"] as! Double
        if userInfo["sessionEnded"] as! Bool {
            saveHistoryData()
            let sessionData = SessionData(date: NSDate(), steps: 0, distance: 0.0, totalSteps: history[0].totalSteps, totalDistance: history[0].totalDistance)
            
            history.insert(sessionData, at: 0)
        }
        
        if userInfo["saveHistory"] as! Bool {
            saveHistoryData()
        }
        
        saveData()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    
    
    
    /** Saves the path of the data encoded */
    var savedDataPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docPath = paths.first!
        return docPath.NS.appendingPathComponent("SavedData")
    }
    
    /** Load the encoded dat */
    func loadSavedData() -> Bool {
        if let data = NSData(contentsOfFile: savedDataPath) {
            let savedData = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [SessionData]
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
    
    
    /** Saves the data from the property list. */
    func saveHistoryData(){
        
        storedHistoryPlist.add(history[0].convertHistoryToDict())
        
        if let historyPlist = HistoryData(name: "HistoryData"){
            do{
                try historyPlist.addValuesToPlistFile(history: storedHistoryPlist)
            } catch {
                print(error)
            }
        }
    }

}
