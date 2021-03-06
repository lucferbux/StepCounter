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
    
    let dateFormatter = DateFormatter()
    
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
            mail.addAttachmentData(fileData as Data, mimeType: "xml", fileName: "historicData.xml")
            }
            present(mail, animated: true, completion: nil)
        } else {
            // show failure alert
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateFormatter.dateStyle = .long
    }
    
    // Table view Data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if history != nil {
            return history!.count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath as IndexPath)
        
        if let history = history {
            let dayData = history[indexPath.row]
            cell.textLabel!.text = dateFormatter.string(from: dayData.date as Date)
            let formattedString = String(format:"%.2f", dayData.distance)
            cell.detailTextLabel!.text = "\(dayData.steps) steps \(formattedString)km"
            
        }
        
        return cell
    }

    
}
