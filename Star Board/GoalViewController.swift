//
//  GoalViewController.swift
//  Star Board
//
//  Created by Greg Wu on 3/22/20.
//  Copyright © 2020 Greg Wu. All rights reserved.
//

import UIKit

class GoalViewController: UIViewController {
    
    var goal: String?
    
    @IBOutlet var goalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        goalLabel.text = goal
    }
    
    @IBAction func okButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

