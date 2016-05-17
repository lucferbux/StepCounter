//
//  HistoryTableViewController.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import UIKit
import MessageUI

class HistoryTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    var history: [SessionData]?
    var distanceUnit = "km"
    let historicalData = HistoryData(name: "HistoryData")
    
    let dateFormatter = NSDateFormatter()
    
    @IBAction func sendHistoryData(sender: AnyObject) {
        sendEmail()
    }
    
    /** Compose a mail, delegating the MFMailComposeView into the main View, it takes the file of the historical data
    and attach it as an XML file */
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            mail.setToRecipients(["lucasfernandezaragon@gmail.com"])
            mail.setMessageBody("<p>The historical data!</p>", isHTML: true)
            if let fileData = historicalData?.getPlist(){
            mail.addAttachmentData(fileData, mimeType: "xml", fileName: "historicData.xml")
            }
            presentViewController(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .LongStyle
    }
    
    // Table view Data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if history != nil {
            return history!.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath)
        
        if let history = history {
            let dayData = history[indexPath.row]
            cell.textLabel!.text = dateFormatter.stringFromDate(dayData.date)
            let formattedString = String(format:"%.2f", dayData.distance)
            cell.detailTextLabel!.text = "\(dayData.steps) steps \(formattedString)km"
            
        }
        
        return cell
    }

    
}
