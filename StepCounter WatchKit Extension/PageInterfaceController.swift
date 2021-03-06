//
//  PageInterfaceController.swift
//  StepCounter
//
//  Created by lucas fernández on 10/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class PageInterfaceController: WKInterfaceController, WCSessionDelegate {
    /** Called when the session has completed activation. If session state is WCSessionActivationStateNotActivated there will be an error with more details. */
    @available(watchOS 2.2, *)
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        
    }


    
    @IBOutlet var topGroup: WKInterfaceGroup!
    @IBOutlet var goalLabel: WKInterfaceLabel!
    @IBOutlet var progressGroup: WKInterfaceGroup!
    @IBOutlet var completionsLabel: WKInterfaceLabel!
    @IBOutlet var totalStepsLabel: WKInterfaceLabel!
    @IBOutlet var totalStepsMsgLabel: WKInterfaceLabel!
    @IBOutlet var totalDistanceLabel: WKInterfaceLabel!
    @IBOutlet var totalDistanceUnitLabel: WKInterfaceLabel!
    @IBOutlet var totalDistanceMsgLabel: WKInterfaceLabel!
    @IBOutlet var stepsLabel: WKInterfaceLabel!
    @IBOutlet var distanceLabel: WKInterfaceLabel!
    
    var data: PedometerData!
    var walk: Walk!
    
    
    @IBAction func sendHistory() {
        
        data.sendDataHistory()
        
    }
    
    let distanceMsgs = ["Ready, set go!",
                        "Good progress!",
                        "Now you're moving!",
                        "You're nearly there!"]
    let stepMsgs = ["It starts with 1 step",
                    "They add up fast!",
                    "Keep on keeping on...",
                    "Give it your all!"]
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let context = context as! [AnyObject]
        walk = context[0] as! Walk
        setTitle(walk.walkTitle)
        data = context[1] as! PedometerData
    }
    
    override func willActivate() {
        super.willActivate()
        updateInterface()
    }
    
    func formattedString(x: CGFloat) -> String {
        return String(format:"%.1f", x)
    }
    
    func updateInterface() {
        topGroup.setBackgroundImage(UIImage(named: walk.imageName))
        stepsLabel.setText("\(data.totalSteps)")
        totalStepsLabel.setText("\(data.steps)")
        
        let goal = CGFloat(walk.goal)
        // distanceUnit-dependant text
        totalDistanceUnitLabel.setText(data.distanceUnit)
        goalLabel.setText(formattedString(x: goal) + " km")
        distanceLabel.setText(formattedString(x: data.totalDistance))
        totalDistanceLabel.setText(formattedString(x: data.distance))

        
        /// completions
        let completions = data.totalDistance / goal
        completionsLabel.setText(formattedString(x: completions))
        let fraction = completions.fraction()
        progressGroup.setWidth(fraction * contentFrame.size.width)
        
        /// progress bar and messages
        let index = Walk.progressIndex(fraction: fraction)
        progressGroup.setBackgroundColor(Walk.progressColors[index])
        totalDistanceMsgLabel.setText(distanceMsgs[index])
        totalStepsMsgLabel.setText(stepMsgs[index])
    }


}
