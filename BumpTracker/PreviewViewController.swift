//
//  PreviewViewController.swift
//  BumpTracker
//
//  Created by Garrett Cox on 4/20/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var previewImageView: UIImageView!
    
    
    var previewImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if previewImage != nil {
            previewImageView.image = previewImage
            previewImageView.startAnimating()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
