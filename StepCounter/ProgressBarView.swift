//
//  ProgressBarView.swift
//  StepCounter
//
//  Created by lucas fernández on 09/05/16.
//  Copyright © 2016 lucas fernández. All rights reserved.
//

import UIKit

class ProgressBarView: UIView {

    //Class to controll the progress bar depending on the progress of the distance
    @IBOutlet weak var progressBar: UIView!
    @IBOutlet weak var progressBarRightConstraint: NSLayoutConstraint!
    
    var fraction: CGFloat = 1
    
    override func updateConstraints() {
        super.updateConstraints()
        // move right constraint to correct length
        let width = bounds.width
        progressBarRightConstraint.constant = (1 - fraction) * width
    }
    
    // WalkViewController calls this method
    func update(fraction: CGFloat) {
        self.fraction = fraction
        progressBar.backgroundColor = Walk.progressColors[Walk.progressIndex(fraction: fraction)]
        self.setNeedsUpdateConstraints()
    }
    
}
