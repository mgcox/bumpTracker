//
//  CameraViewController.swift
//  BumpTracker
//
//  Created by Garrett Cox on 3/22/17.
//  Copyright © 2017 GNiOS Applications. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import CorePlot
import CoreGraphics

import Charts

class CameraViewController: UIViewController {

    @IBOutlet weak var verticalGraphView: BarChartView!
    @IBOutlet weak var horizontalGraphView: BarChartView!
    var histogramOption : CPTScatterPlotHistogramOption?
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var pastImageView: UIImageView!
    
    var captureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var previousPhoto : UIImage?
    var captureDevice : AVCaptureDevice?
    
    var data = [Double]()
    var max = 100.0
    var min = 0.0
  //  var graph = CPTXYGraph(frame: CGRect.zero)
    //let plot = CPTScatterPlot()
    var timer: Timer?
    var y = 0.0
    
    let DEBUG = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

//        self.horizontalGraphView.hostedGraph = graph
//        //        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: "updateGraph", userInfo: nil, repeats: true)
//        //timer = Timer.scheduledTimer(timeInterval: 1.0,invocation: updateGraph, repeats: true)
//        
        horizontalGraphView.delegate = self
        horizontalGraphView.noDataText = "no data available"
    }
    
    
    func numberOfRecords(for: CPTPlot!) -> AnyObject? {
        print("COUNT: ", data.count as AnyObject)
        return data.count as AnyObject
    }
    
    func numberForPlot(plot: CPTPlot!, field fieldEnum: UInt, recordIndex idx: UInt) -> NSNumber! {
        
        switch fieldEnum {
        case 0:
            return idx as NSNumber
        case 1:
            return data[Int(idx)] as NSNumber
        default:
            return 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let backCamera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if previousPhoto != nil {
            pastImageView.image = previousPhoto
        }
        
        
        if error == nil && captureSession.canAddInput(input) {
            captureSession.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
            if captureSession.canAddOutput(stillImageOutput) {
                captureSession.addOutput(stillImageOutput)
                
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                //previewLayer!.videoGravity = AVLayerVideoGravityResizeAspect
                previewLayer!.videoGravity = AVLayerVideoGravityResize
                previewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                
                previewView.layer.addSublayer(previewLayer!)
                
                
                //let exampleView = UIImageView(image: #imageLiteral(resourceName: "Sillouhette"))
                //exampleView.frame = (previewView?.bounds)!
                //exampleView.alpha = 0.2
                //previewView.addSubview(exampleView)
            
                
                self.pastImageView.layer.zPosition = 1
                self.previewView.bringSubview(toFront: pastImageView)
                captureSession.startRunning()
                
                
                timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(updateGraph), userInfo: nil, repeats: false)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        previewLayer!.frame = previewView.bounds
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer!.frame = previewView.layer.bounds
    }
    
    func saveToCamera() {
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
                if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
                    
                    if let cameraImage = UIImage(data: imageData) {
                        
                        UIImageWriteToSavedPhotosAlbum(cameraImage, nil, nil, nil)
                    }
                }
            })
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func takePhotoButtonPressed(_ sender: Any) {
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
                   
                    let monochromeFilter = CIFilter(name:"CIColorMonochrome")
                    
                    // Set some filter parameters.
                    monochromeFilter?.setValue(CIImage(image: image), forKey:kCIInputImageKey)
                    monochromeFilter?.setValue(CIColor(red: 0.5, green: 0.5, blue: 0.5), forKey:kCIInputColorKey)
                    monochromeFilter?.setValue(1.0, forKey:kCIInputIntensityKey)
    
                    // Use the playground to peek at the image now
                    let outputCIImage = monochromeFilter?.outputImage
                    
                    let monochromeVersion = UIImage(ciImage: outputCIImage!, scale: 1.0, orientation: .right)
 
                    
                    
                    //TODO: Give user alert/ let them confirm that is the photo they want to use
                    self.savePhotoShoot(photoTaken: image)
                    
                    //We no longer want to update photo with previous photo
                    //self.pastImageView.image = image
                    
                }
            })
        }
        
        
    }
    
    
    func savePhotoShoot(photoTaken : UIImage){
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
        
        // 3 - Save Values to CoreData
        shoot.setValue(Date(), forKeyPath: "Date")
        
        shoot.setValue(UInt16(1), forKeyPath: "week")
        
        let imageData = NSData(data: UIImageJPEGRepresentation(photoTaken, 1.0)!)
        
        shoot.setValue(imageData, forKey: "photoData")
        
        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        
    }
    
    func sumProfile(photo: UIImage, axis: String){
        let start = DispatchTime.now()
        
        var grayScaledImage = [Int]()
        data = [Double]()
    
        let size = photo.size
        let width = Int(size.width)
        let height = Int(size.height)
        print("Width: " + String(width))
        print("Height: " + String(height))
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = photo.cgImage else { return }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        
        // B&W
        for i in 0...(width-1) {
            for j in 0...(height-1) {
                let offset = 4 * ((width * Int(j)) + Int(i))
                let red = pixelData[offset+1]
                let green = pixelData[offset+2]
                let blue = pixelData[offset+3]
                let avg = (Int(red) + Int(green) + Int(blue)) / 3
                grayScaledImage.append(avg)
            }
        }
        
        // SUM
        if axis == "x"{
            for i in 0...(width-1) {
                var tempSum = 0
                for j in 0...(height-1) {
                    let offset = ((width * Int(j)) + Int(i)%(width-1))
                    // Sum along the axis.
                    tempSum += grayScaledImage[offset]
                }
                // Append to sum array.
                self.data.append(Double(tempSum))
            }
        } else if axis == "y"{
            for j in 0...(height-1){
                var tempSum = 0
                for i in 0...(width-1){
                    let offset = ((width * Int(j) + Int(i)%(width-1)))
                    tempSum += grayScaledImage[offset]
                }
                self.data.append(Double(tempSum))
            }
        }
        
        if self.DEBUG{
            let end = DispatchTime.now()
            let diff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000 // Gives seconds
            print("Sum finished in \(diff) seconds.")
        }
    }
    
    func updateGraph(){
        DispatchQueue.global(qos: .background).async
            {

                print("X")
                self.sumProfile(photo: self.previousPhoto!, axis:"x")
                print("Y")
                self.sumProfile(photo: self.previousPhoto!, axis:"y")
                // create graph
                
            DispatchQueue.main.async {
                print("Updating")
              
            }
        
        }
        

    }
    
    func getSnapShot(completion: @escaping (_ result : UIImage) -> Void) {
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            videoConnection.videoOrientation = AVCaptureVideoOrientation.portrait
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: {(sampleBuffer, error) in
                if (sampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    
                    let dataProvider = CGDataProvider(data: imageData as! CFData)
                    let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: .defaultIntent)
                    
                    let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)

                    completion(image)
                }
            })
        }
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
