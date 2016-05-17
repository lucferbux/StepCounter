//
//  WalkViewController.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import UIKit

class WalkViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var progressBarView: ProgressBarView!
    @IBOutlet weak var walkLabel: UILabel!
    @IBOutlet weak var infoTextView: UITextView!
    
    var walk: Walk?
    var distanceUnit = "km"
    var completions: CGFloat = 0.0
    var completionString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let walk = walk {
            image.image = UIImage(named: walk.imageName)
            let formattedString = String(format:"%.2f", walk.goal)
            goalLabel.text = "Goal: \(formattedString)km completed \(completionString) times today"

            
            // progress bar shows color-coded progress towards the next completion
            progressBarView.update(completions.fraction())
            
            walkLabel.text = walk.walkTitle
            infoTextView.text = walk.info
        }
    }
    
}
