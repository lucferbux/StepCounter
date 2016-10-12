//
//  InterfaceController.swift
//  StepCounter WatchKit Extension
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    @IBOutlet var walkTable: WKInterfaceTable!
    
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
    
    let data = PedometerData()
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    
    override func willActivate() {
        loadTable()
    }
    
    func loadTable() {
        walkTable.setNumberOfRows(walks.count, withRowType: "walkRow")
        for i in 0..<walks.count {
            let controller = walkTable.rowController(at: i) as! WalkRowController
            controller.titleLabel.setText(walks[i].walkTitle)
            
            // completions; hide star if < 1
            let completions = data.distance / CGFloat(walks[i].goal)
            controller.starLabel.setHidden(completions < 1.0)
            
            // progress bar
            let fraction = completions.fraction()
            controller.progressGroup.setWidth(fraction * contentFrame.size.width)
            controller.progressGroup.setBackgroundColor(Walk.progressColors[Walk.progressIndex(fraction: fraction)])
        }
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
        return [walks[rowIndex], data]
    }


}
