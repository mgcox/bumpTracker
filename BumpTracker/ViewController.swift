//
//  ViewController.swift
//  BumpTracker
//
//  Created by Garrett Cox on 2/15/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit
import CoreData


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

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewPhoto" {
            let destVC = segue.destination as! PhotoshootViewerVC
            destVC.shoot = selectedPhotoShoot
            
        }
    }
}

