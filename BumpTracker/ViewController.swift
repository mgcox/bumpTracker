//
//  ViewController.swift
//  BumpTracker
//
//  Created by Garrett Cox on 2/15/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreGraphics
import ImageIO
import MobileCoreServices
import Photos

class ViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var photoListTableView: UITableView!
    
    
    var photoshoots = [PhotoShoot]()
    var selectedPhotoShoot : PhotoShoot?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let defaults = UserDefaults.standard
        
//        let opencv = OpenCVWrapper()
//        opencv.processPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPhotoshoots()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPhotoshoots(){
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoShoot")
        
        // Execute Fetch Request
        do {
            let result = try self.context.fetch(fetchRequest)
            
            photoshoots = result as! [PhotoShoot]
            
            //Reload Table
            DispatchQueue.main.async(execute: { () -> Void in
                self.photoListTableView.reloadData()
            })
  
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = photoListTableView.dequeueReusableCell(withIdentifier: "photoCell") as! PhotosTableViewCell
        
        
        let shoot = photoshoots[indexPath.row]
        
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"

        
        let week = shoot.week
        
        //Set date for photo
        cell.dateLabel.text = String("Week " + String(week) + " (" + dateFormatter.string(from: shoot.date! as Date) + ")")
        
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //Return the number of photo objects we have
        return photoshoots.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPhotoShoot = photoshoots[indexPath.row]
    
        self.performSegue(withIdentifier: "viewPhoto", sender: self)
    }
    

    func savePhotoShoot(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "PhotoShoot",
                                       in: managedContext)!
        
        let shoot = NSManagedObject(entity: entity,
                                    insertInto: managedContext)
        
        // 3
        shoot.setValue(Date(), forKeyPath: "Date")
        
        shoot.setValue(UInt16(1), forKeyPath: "week")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.delete
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
                if editingStyle == .delete {
                    print("delete")
                    selectedPhotoShoot = photoshoots[indexPath.row]
                    self.deleteShoot(shoot: selectedPhotoShoot!, row: indexPath.row)
                    self.photoListTableView.reloadData()
                }
    }
    
  
    func deleteShoot(shoot: PhotoShoot, row: Int){
        context.delete(shoot)
        photoshoots.remove(at: row)
        do {
            try context.save()
        } catch _ {
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            let destVC = segue.destination as! PhotoshootViewerVC
            destVC.shoot = selectedPhotoShoot
            
        }
    }
    
    @IBAction func createGifButtonPressed(_ sender: Any) {
        
        var images = [UIImage]()
        
        for photo in photoshoots{
            let image = UIImage(data: photo.photoData! as Data)
           images.append(image!)
        }
        
        createGIF(with: images, frameDelay: 0.2) { (location, error) in
            if error == nil {
                
                PHPhotoLibrary.shared().performChanges({ 
                    PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: location! as URL)
                }, completionHandler: { (success, error) in
                    if error == nil {
                        if success == true {
                            print("saved")
                        }
                    }
                })
                
            
                
            }
        }
        
        
    }
    
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    
    func createGIF(with images: [UIImage], loopCount: Int = 0, frameDelay: Double, callback: (_ dataURL: NSURL?, _ error: NSError?) -> ()) {
        let fileProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFLoopCount as String: loopCount]]
        let frameProperties = [kCGImagePropertyGIFDictionary as String: [kCGImagePropertyGIFDelayTime as String: frameDelay]]
        
        let documentsDirectory = NSTemporaryDirectory()
        let url = NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent("animated.gif")
        
        let destination = CGImageDestinationCreateWithURL(url! as CFURL, kUTTypeGIF, Int(images.count), nil)
        CGImageDestinationSetProperties(destination!, fileProperties as CFDictionary)
        
        for i in 0..<images.count {
            CGImageDestinationAddImage(destination!, images[i].cgImage!, frameProperties as CFDictionary)
        }
        
        if CGImageDestinationFinalize(destination!) {
            callback(url! as NSURL, nil)
        } else {
            callback(nil, NSError(domain: "createGIF", code: 0, userInfo: nil))
        }
    }
    
    
    
    
}

