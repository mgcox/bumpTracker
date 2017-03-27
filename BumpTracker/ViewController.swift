//
//  ViewController.swift
//  BumpTracker
//
//  Created by Garrett Cox on 2/15/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var weekLabel: UILabel!
    
    @IBOutlet weak var weekTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let defaults = UserDefaults.standard
        
        
        
        //Get the date they started using this
        if let start = defaults.value(forKey: "startDate") {
            
        }else{
            weekLabel.isHidden = true
            weekTextField.isHidden = false
          //  weekTextField.becomeFirstResponder()
            
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func takePhotoButtonPressed(_ sender: Any) {
        
        
    }

}

