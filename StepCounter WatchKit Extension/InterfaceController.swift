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

    @IBOutlet var walkTable: WKInterfaceTable!
    
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
    
    let data = PedometerData()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        loadTable()
    }
    
    func loadTable() {
        walkTable.setNumberOfRows(walks.count, withRowType: "walkRow")
        for i in 0..<walks.count {
            let controller = walkTable.rowControllerAtIndex(i) as! WalkRowController
            controller.titleLabel.setText(walks[i].walkTitle)
            
            // completions; hide star if < 1
            let completions = data.distance / CGFloat(walks[i].goal)
            controller.starLabel.setHidden(completions < 1.0)
            
            // progress bar
            let fraction = completions.fraction()
            controller.progressGroup.setWidth(fraction * contentFrame.size.width)
            controller.progressGroup.setBackgroundColor(Walk.progressColors[Walk.progressIndex(fraction)])
        }
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        return [walks[rowIndex], data]
    }


}
