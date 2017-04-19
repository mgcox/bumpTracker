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
import CoreGraphics

import Charts

class CameraViewController: UIViewController {

    @IBOutlet weak var verticalGraphView: LineChartView!
    @IBOutlet weak var horizontalGraphView: LineChartView!
    
    @IBOutlet weak var previewView: UIView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var pastImageView: UIImageView!
    
    var captureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var previousPhoto : UIImage?
    var captureDevice : AVCaptureDevice?
    
    var previousPhotoXdata = LineChartDataSet()
    var previousPhotoYdata = LineChartDataSet()
    
    let LINE_WIDTH = CGFloat(1.0)
    
    
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
//        horizontalGraphView.delegate = self
      //  horizontalGraphView.noDataText = "no data available"
        
        
//        let chart = LineChartView(frame: self.horizontalGraphView.frame)
//        
//        let yVals: [Double] = [ 873, 568, 937, 726, 696, 687, 180, 389, 90, 928, 890, 437]
//        var entries = [ BarChartDataEntry]()
//        for (i, v) in yVals.enumerated() {
//            let entry = BarChartDataEntry()
//            entry.x = Double( i)
//            entry.y = v
//            
//            entries.append( entry)
//        }
//        
//        
//        let set = LineChartDataSet( values: entries, label: "Bar Chart")
//        let data = LineChartData( dataSet: set)
//        chart.data = data
//        // no data text
//        chart.noDataText = "No data available"
//        // user interaction
//        chart.isUserInteractionEnabled = false
//        
//        //horizontalGraphView = chart
//        
//        self.horizontalGraphView.addSubview( chart)
        
        
        self.horizontalGraphView.xAxis.drawGridLinesEnabled = false
        self.horizontalGraphView.xAxis.drawLabelsEnabled = false
        self.horizontalGraphView.xAxis.drawAxisLineEnabled = false
        self.horizontalGraphView.leftAxis.drawGridLinesEnabled = false
        self.horizontalGraphView.leftAxis.drawLabelsEnabled = false
        self.horizontalGraphView.leftAxis.drawAxisLineEnabled = false
        self.horizontalGraphView.rightAxis.drawGridLinesEnabled = false
        self.horizontalGraphView.rightAxis.drawLabelsEnabled = false
        self.horizontalGraphView.rightAxis.drawAxisLineEnabled = false
        self.horizontalGraphView.chartDescription = nil
        self.horizontalGraphView.drawMarkers = false
        self.horizontalGraphView.minOffset = 0.0
        
        
        self.verticalGraphView.xAxis.drawGridLinesEnabled = false
        self.verticalGraphView.xAxis.drawLabelsEnabled = false
        self.verticalGraphView.xAxis.drawAxisLineEnabled = false
        self.verticalGraphView.leftAxis.drawGridLinesEnabled = false
        self.verticalGraphView.leftAxis.drawLabelsEnabled = false
        self.verticalGraphView.leftAxis.drawAxisLineEnabled = false
        self.verticalGraphView.rightAxis.drawGridLinesEnabled = false
        self.verticalGraphView.rightAxis.drawLabelsEnabled = false
        self.verticalGraphView.rightAxis.drawAxisLineEnabled = false
        self.verticalGraphView.chartDescription = nil
        self.verticalGraphView.drawMarkers = false
        self.verticalGraphView.minOffset = 0.0
        
        self.horizontalGraphView.autoScaleMinMaxEnabled = true
        self.horizontalGraphView.xAxis.granularityEnabled = true
//        self.horizontalGraphView.xAxis.granularity = 3
        
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
                
                
                startGraphing()
                
                
                
            }
        }
        
    }
    
    func startGraphing(){
        
        getPreviousPhotoSumData()
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateGraph), userInfo: nil, repeats: true)
    }
    
    func getPreviousPhotoSumData(){
        print("Setting previous photo data")
        
        let (xaxisArray, verticalArray) = self.sumProfile(photo: self.previousPhoto!, axis:"x")
        
        
        var entries = [ BarChartDataEntry]()
        for (i, v) in xaxisArray.enumerated() {
            let entry = BarChartDataEntry()
            entry.x = Double( i)
            entry.y = v
            
            entries.append( entry)
        }
        
        
        self.previousPhotoXdata = LineChartDataSet( values: entries, label: "")
        self.previousPhotoXdata.lineWidth = LINE_WIDTH
        self.previousPhotoXdata.circleRadius = LINE_WIDTH
        
        
        var yentries = [ BarChartDataEntry]()
        for (i, v) in verticalArray.enumerated() {
            let entry = BarChartDataEntry()
            entry.x = v
            entry.y = Double( i)
            
            yentries.append( entry)
        }
        
        self.previousPhotoYdata = LineChartDataSet( values: yentries, label: "")
        self.previousPhotoYdata.lineWidth = LINE_WIDTH
        self.previousPhotoYdata.circleRadius = LINE_WIDTH

        
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
//                    let outputCIImage = monochromeFilter?.outputImage
                    
//                    let monochromeVersion = UIImage(ciImage: outputCIImage!, scale: 1.0, orientation: .right)
 
                    
                    
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
    
    func sumProfile(photo: UIImage, axis: String) -> ([Double],[Double]){
//        let start = DispatchTime.now()
        
        var xDataArray = [Double]()
        var yDataArray = [Double]()
    
        let size = photo.size
        let width = Int(size.width)
        let height = Int(size.height)
//        print("Width: " + String(width))
//        print("Height: " + String(height))
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
        guard let cgImage = photo.cgImage else { return (xDataArray, yDataArray)}
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        
        // SUM
        if axis == "x"{
            for j in stride(from: (height - 1), to: 0, by: -1) {
                if(j%100 == 0){
                    var tempSum = 0
                    for i in stride(from: (width - 1), to: 0, by: -1) {
                        let offset = 4 * ((width * Int(j)) + Int(i))
                        let red = pixelData[offset+1]
                        let green = pixelData[offset+2]
                        let blue = pixelData[offset+3]
                        tempSum += (Int(red) + Int(green) + Int(blue)) / 3
                    }
                    xDataArray.append(Double(tempSum))
                }
            }
        } else if axis == "y"{
            for i in stride(from: (width - 1), to: 0, by: -1) {
                if(i%100 == 0){
                    var tempSum = 0
                    for j in stride(from: (height - 1), to: 0, by: -1) {
                        let offset = 4 * ((width * Int(j)) + Int(i))
                        let red = pixelData[offset+1]
                        let green = pixelData[offset+2]
                        let blue = pixelData[offset+3]
                        tempSum += (Int(red) + Int(green) + Int(blue)) / 3
                    }
                    yDataArray.append(Double(tempSum))
                }
            }
        }
        
//        if self.DEBUG{
//            let end = DispatchTime.now()
//            let diff = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000 // Gives seconds
//            print("Sum finished in \(diff) seconds.")
//        }
        
        return (xDataArray, yDataArray)
    }
    
    func updateGraph(){
        DispatchQueue.global(qos: .background).async
            {
                
                self.getSnapShot(completion: { (snappedImage) in
                    
                    let (xaxisArray, verticalArray) = self.sumProfile(photo: snappedImage, axis:"x")
                    
                    
                    var entries = [ BarChartDataEntry]()
                    for (i, v) in xaxisArray.enumerated() {
                        let entry = BarChartDataEntry()
                        entry.x = Double( i)
                        entry.y = v
                        
                        entries.append( entry)
                    }
                    
                    
                    let set = LineChartDataSet( values: entries, label: "")
                    set.lineWidth = self.LINE_WIDTH
                    set.circleRadius = self.LINE_WIDTH
                    //let data = LineChartData( dataSet: set)
                    let data = LineChartData(dataSets: [set,self.previousPhotoXdata])
                    data.setDrawValues(false) // Don't draw labels on each individual value
                    
                    var yentries = [ BarChartDataEntry]()
                    for (i, v) in verticalArray.enumerated() {
                        let entry = BarChartDataEntry()
                        entry.x = v
                        entry.y = Double( i)
                        
                        yentries.append( entry)
                    }
                    
                    
                    let yset = LineChartDataSet( values: yentries, label: "")
                    yset.lineWidth = self.LINE_WIDTH
                    yset.circleRadius = self.LINE_WIDTH
                    let ydata = LineChartData(dataSets: [yset,self.previousPhotoYdata])
                    ydata.setDrawValues(false) // Don't draw labels on each individual value
                    
                    DispatchQueue.main.async {
                        self.horizontalGraphView.data = data
                        self.horizontalGraphView.notifyDataSetChanged()
                        
                        self.verticalGraphView.data = ydata
                        self.verticalGraphView.notifyDataSetChanged()
                    }
                    
                    
                    
                })
                
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
    
    override func viewWillDisappear(_ animated: Bool) {
        timer?.invalidate()
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
