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
    
    @IBOutlet weak var weekLabel: UILabel!
    
    var photoshoots = [PhotoShoot]()
    var selectedPhotoShoot : PhotoShoot?
    
    var previousShoot : UIImage?
    var gif : UIImage?
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let defaults = UserDefaults.standard
        
        if let start = defaults.value(forKey: "startDate") {
            
            let calendar = NSCalendar.current
            
            // Replace the hour (time) of both dates with 00:00
            
            
            
            let date1 = calendar.startOfDay(for: start as! Date)

            let date2 = calendar.startOfDay(for: Date())
            
            let flags = NSCalendar.Unit.day

            let components = calendar.dateComponents([Calendar.Component.day], from: date1, to: date2)
            
            weekLabel.text = String(components.day!/7)
            // This will return the number of day(s) between dates
            
            
        }else{
            
            //New User, get the current week
            let alertController = UIAlertController(title: "Welcome to Bump Tracker!", message: "Please Enter Your Current Gestational Week", preferredStyle: .alert)
            
            let saveAction = UIAlertAction(title: "Save", style: .default, handler: {
                alert -> Void in
                
                let weekTextField = alertController.textFields![0] as UITextField
                let weeks = Double(weekTextField.text!)
                let now = Date()
                let dateXWeeksAgo = now.addingTimeInterval(-weeks!*24*60*60)
                
                self.weekLabel.text = String(Int(weeks!))
                
                defaults.setValue(dateXWeeksAgo, forKeyPath: "startDate")
                
            })
            
//            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: {
//                (action : UIAlertAction!) -> Void in
//                
//            })
            
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "4"
                textField.keyboardType = UIKeyboardType.numberPad
            }
            
            alertController.addAction(saveAction)
           // alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        
        
        
//        let opencv = OpenCVWrapper()
//        opencv.processPhoto()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchPhotoshoots()
        
        var nav = self.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white,  NSFontAttributeName: UIFont(name: "Banaue", size: 36)!]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchPhotoshoots(){

        let sectionSortDescriptor = NSSortDescriptor(key: "date", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "PhotoShoot")
         fetchRequest.sortDescriptors = sortDescriptors
        // Execute Fetch Request
        do {
            let result = try self.context.fetch(fetchRequest)
            
            photoshoots = result as! [PhotoShoot]
            if photoshoots.count > 0 {
                if let shoot = photoshoots[0].photoData {
                    self.previousShoot = UIImage(data: shoot as Data)
                    
                }
            }

            
            
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
            
        }else if segue.identifier == "takePhoto" {
            let destVC = segue.destination as! CameraViewController
            if previousShoot != nil {
                destVC.previousPhoto = previousShoot!
            }
            
        }else if segue.identifier == "previewGif" {
            let destVC = segue.destination as! PreviewViewController
            destVC.previewImage = gif
        }
    }
    
    @IBAction func createGifButtonPressed(_ sender: Any) {
        
        var images = [UIImage]()
        
        for photo in photoshoots.reversed(){
            let image = UIImage(data: photo.photoData! as Data)

            let fixed = image?.fixOrientation()
           images.append(fixed!)
        }
        
        createGIF(with: images, frameDelay: 0.2) { (location, error) in
            if error == nil {
                PHPhotoLibrary.shared().performChanges({ 
                    PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: location! as URL)
                }, completionHandler: { (success, error) in
                    if error == nil {
                        if success == true {
                            print("saved")
                            
                            
                            do {
                              // let imageData = try  Data(contentsOf: location! as URL)
                                
                                self.gif = UIImage.animatedImage(with: images, duration: 0.2*Double(images.count))
                                
                                
                                self.performSegue(withIdentifier: "previewGif", sender: self)
                            }catch{
                                print("image problem")
                            }
                           
                            
                            
                            
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

extension UIImage {
    func fixOrientation() -> UIImage {
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
    
    

    
}


