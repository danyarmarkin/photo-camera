//
//  CameraViewController.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 17.09.2021.
//

import UIKit
import AVFoundation
import Firebase

class CameraViewController: UIViewController, UITextFieldDelegate  {
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var qrCodeFrameView: UIView?
    var captureDevice: AVCaptureDevice!
    
    var nameInd = 0
    var isTrashButtonActive = false
    var photoRecordingStarted = false
    var photoTimer: Timer!
    var session = Session()
    
    @objc let cameraSettings = CameraSettings()
    var observation: NSKeyValueObservation?
    
    var ref: DatabaseReference!

    @IBOutlet weak var objectName: UITextField!
    @IBOutlet weak var sessionName: UILabel!
    @IBOutlet weak var reloadSession: UIButton!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var toTrashButton: UIButton!
    @IBOutlet weak var startPhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        objectName.delegate = self
        
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()

        captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        do {
            try captureDevice.lockForConfiguration()
            captureDevice.isSubjectAreaChangeMonitoringEnabled = true
            captureDevice.unlockForConfiguration()
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            captureSession?.addOutput(capturePhotoOutput!)
            captureSession?.sessionPreset = .photo
            
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
//            previewView.layer.addSublayer(videoPreviewLayer!)
            mainImageView.layer.addSublayer(videoPreviewLayer!)
            
            captureSession?.startRunning()
            
            _ = CameraSettingsObserver(capDev: captureDevice, settings: cameraSettings)
            
            
            cameraSettings.monitoringData()
            
        } catch {
            //If any error occurs, simply print it out
            print(error)
            return
        }
        
        monitoringData()
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func moveToTrash(_ sender: Any) {
//        cameraSettings.colorSpace = 1
    }
    
    @IBAction func startPhoto(_ sender: Any) {
        if photoRecordingStarted {
            ref.child("isStartVideo").setValue(0)
        } else if !photoRecordingStarted {
            ref.child("isStartVideo").setValue(1)
        }
        isTrashButtonActive = false
    }
    
    @IBAction func onObjectNameChanged(_ sender: UITextField) {
        ref.child("objectName").setValue(sender.text)
    }
    
    @IBAction func onReloadSession(_ sender: Any) {
        let session = LocalStorage.randomSessionId(length: 4)
        self.ref.child("currentSession").setValue(session)
    }
    
    override func accessibilityElementDidBecomeFocused() {
        super.accessibilityElementDidBecomeFocused()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func photoTimerConf() {
        photoTimer = Timer.scheduledTimer(withTimeInterval: 0.33, repeats: true, block: { [self](timer) in
            
            guard let capturePhotoOutput = self.capturePhotoOutput else { return }
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .off
            if #available(iOS 13.0, *) {
                photoSettings.photoQualityPrioritization = .speed
                capturePhotoOutput.maxPhotoQualityPrioritization = .speed
                photoSettings.isAutoStillImageStabilizationEnabled = false
                photoSettings.isAutoVirtualDeviceFusionEnabled = false
            }
            capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        })
        photoTimer.tolerance = 0.08
    }
    

    func monitoringData() {
        ref.child("isStartVideo").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? Int {
                if val == 1 && !self.photoRecordingStarted{
                    self.startPhotoButton.backgroundColor = .systemRed
                    self.photoRecordingStarted = true
                    self.photoTimerConf()
                    self.createFolder(name: self.session.getFullName())
                    self.nameInd = 0
                    
                } else {
                    self.startPhotoButton.backgroundColor = .lightGray
                    self.photoRecordingStarted = false
                    if self.photoTimer != nil {
                        self.photoTimer.invalidate()
                    }
                    if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
                        let newName = LocalStorage.randomSessionId(length: 4)
                        self.ref.child("currentSession").setValue(newName)
                    }
                }
            }
        })
        
        ref.child("objectName").observe(.value, with: {snapshot in
            let value = snapshot.value
            if let val = value as? String {
                self.session.objectName = val
                self.objectName.text = val
            }
        })
        
        ref.child("currentSession").observe(.value, with: {snapshot in
            let value = snapshot.value
            if let val = value as? String {
                self.session.sessionName = val
                self.sessionName.text = self.session.getShortName()
            }
        })
        
        ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).observe(.value, with: {snapshot in
            let value = snapshot.value
            if let val = value as? Int {
                self.session.deviceIndex = val
                self.sessionName.text = self.session.getShortName()
            }
        })
        ref.child("devicesAmount").observe(.value, with: {snapshot in
            let value = snapshot.value
            if let val = value as? Int {
                self.session.deviceAmount = val
                self.sessionName.text = self.session.getShortName()
            }
        })
    }
    
    
    func createFolder(name: String) {
        let manager = FileManager.default
        do {
            let rootFolderURL = try manager.url(
                    for: .documentDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: false
                )

                let nestedFolderURL = rootFolderURL.appendingPathComponent(name)

            try manager.createDirectory(
                    at: nestedFolderURL,
                    withIntermediateDirectories: false,
                    attributes: nil
                )
            
        } catch {
            return
        }
    }
    
}


extension CameraViewController : AVCapturePhotoCaptureDelegate {
    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                 didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                 previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                 resolvedSettings: AVCaptureResolvedPhotoSettings,
                 bracketSettings: AVCaptureBracketedStillImageSettings?,
                 error: Error?) {
        // Make sure we get some photo sample buffer
        guard error == nil,
            let photoSampleBuffer = photoSampleBuffer else {
            print("Error capturing photo: \(String(describing: error))")
            return
        }
        
        // Convert photo same buffer to a jpeg image data by using AVCapturePhotoOutput
        guard let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
            return
        }
        
        // Initialise an UIImage with our image data
        let capturedImage = UIImage.init(data: imageData , scale: 1.0)
        if let image = capturedImage {
            // Save our captured image to photos album
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            print("Fail to capture photo: \(String(describing: error))")
            return
        }
        
//        output.maxPhotoQualityPrioritization = .

        guard let imageData = photo.fileDataRepresentation() else {
            print("Fail to convert pixel buffer")
            return
        }

        guard let capturedImage = UIImage.init(data: imageData , scale: 1.0) else {
            print("Fail to convert image data to UIImage")
            return
        }

        let imageToSave = UIImage(cgImage: capturedImage.cgImage!, scale: 1.0, orientation: .right)
        saveImage(image: imageToSave)
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveImage(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 1) {
            let filename = getDocumentsDirectory()
                .appendingPathComponent(session.getFullName())
                .appendingPathComponent(session.getFileName(ind: nameInd))
            try? data.write(to: filename)
            print(nameInd)
            nameInd += 1
        }
    }
}


extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeRight: return .landscapeRight
        case .landscapeLeft: return .landscapeLeft
        case .portrait: return .portrait
        default: return nil
        }
    }
}

extension UIImage {
    var heic: Data? { heic() }
    func heic(compressionQuality: CGFloat = 1) -> Data? {
        guard
            let mutableData = CFDataCreateMutable(nil, 0),
            let destination = CGImageDestinationCreateWithData(mutableData, "public.heic" as CFString, 1, nil),
            let cgImage = cgImage
        else { return nil }
        CGImageDestinationAddImage(destination, cgImage, [kCGImageDestinationLossyCompressionQuality: compressionQuality, kCGImagePropertyOrientation: cgImageOrientation.rawValue] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}

extension UIImage {
    var cgImageOrientation: CGImagePropertyOrientation { .init(imageOrientation) }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}

