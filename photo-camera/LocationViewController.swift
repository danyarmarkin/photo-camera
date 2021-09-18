//
//  LocationViewController.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 17.09.2021.
//

import UIKit
import CoreLocation
import CoreMotion
import Firebase

class LocationViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var xyPlaneImage: UIImageView!
    @IBOutlet weak var xyPlaneLabel: UILabel!
    @IBOutlet weak var zyPlaneImage: UIImageView!
    @IBOutlet weak var zyPlaneLabel: UILabel!
    
    var getXYFromDatabase = false
    var getZYFromDatabase = false
    
    var locationManager: CLLocationManager!
    var motion = CMMotionManager()
    
    var dbX = Float(0)
    var dbY = Float(-1)
    var dbZ = Float(0)
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        
        motion.startGyroUpdates()
        motion.startAccelerometerUpdates()
        
        xyPlaneImage.transform = xyPlaneImage.transform.scaledBy(x: 0.7, y: 0.7)
        
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        
        
        updateData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func xyInput(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getXYFromDatabase = false
        } else {
            getXYFromDatabase = true
        }
        updateAngles()
    }
    
    @IBAction func zyInput(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            getZYFromDatabase = false
        } else {
            getZYFromDatabase = true
        }
        updateAngles()
    }
    
    
    var xyPreVal = Float(0)
    var zyPreVal = Float(0)
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        let accelX = Float(motion.accelerometerData?.acceleration.x ?? 0)
        let accelY = Float(motion.accelerometerData?.acceleration.y ?? -1)
        let accelZ = Float(motion.accelerometerData?.acceleration.z ?? 0)
        
        if LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            ref.child("gyroData").child("x").setValue(accelX)
            ref.child("gyroData").child("y").setValue(accelY)
            ref.child("gyroData").child("z").setValue(accelZ)
        }
        
        updateAngles()
    }
    
    func updateAngles() {
        
        let accelX = Float(motion.accelerometerData?.acceleration.x ?? 0)
        let accelY = Float(motion.accelerometerData?.acceleration.y ?? -1)
        let accelZ = Float(motion.accelerometerData?.acceleration.z ?? 0)
        
        var x = Float(0)
        var y = Float(-1)
        if getXYFromDatabase {
            x = dbX
            y = dbY
        }
        var retxy = false
        var retzy = false
        if getXYFromDatabase && LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            xyPlaneImage.transform = self.xyPlaneImage.transform.rotated(by: CGFloat(-self.xyPreVal))
            xyPreVal = 0
            xyPlaneLabel.text = "0.0"
            retxy = true
        }
        if getZYFromDatabase && LocalStorage.getBool(key: LocalStorage.isMainDevice) {
            zyPlaneImage.transform = self.zyPlaneImage.transform.rotated(by: CGFloat(-self.zyPreVal))
            zyPreVal = 0
            zyPlaneLabel.text = "0.0"
            retzy = true
        }
        if !retxy {
            var xyPhi = (x * accelX + y * accelY)
            xyPhi /= sqrt(x*x + y*y)
            xyPhi /= sqrt(accelX*accelX + accelY*accelY)
            xyPhi = acos(xyPhi)
            if (accelX - x > 0) { xyPhi *= -1 }
            xyPlaneLabel.text = "\(round(xyPhi * 57.299))"
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.xyPlaneImage.transform = self.xyPlaneImage.transform.rotated(by: CGFloat(xyPhi - self.xyPreVal))
                    self.xyPlaneImage.layoutSubviews()
                })
            xyPreVal = xyPhi
        }
        
        var z = Float(0)
        y = Float(-1)
        if getZYFromDatabase {
            z = dbZ
            y = dbY
        }
        if !retzy {
            var zyPhi = (z * accelZ + y * accelY)
            zyPhi /= sqrt(z*z + y*y)
            zyPhi /= sqrt(accelZ*accelZ + accelY*accelY)
            zyPhi = acos(zyPhi)
            if (accelZ - z > 0) { zyPhi *= -1 }
            zyPlaneLabel.text = "\(round(zyPhi * 57.299))"
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                    self.zyPlaneImage.transform = self.zyPlaneImage.transform.rotated(by: CGFloat(zyPhi - self.zyPreVal))
                    self.zyPlaneImage.layoutSubviews()
                })
            zyPreVal = zyPhi
        }
    }
    
    func updateData() {
        ref.child("gyroData").child("x").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? CGFloat {
                self.dbX = Float(val)
                self.updateAngles()
            }
        })
        ref.child("gyroData").child("y").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? CGFloat {
                self.dbY = Float(val)
                self.updateAngles()
            }
        })
        ref.child("gyroData").child("z").observe(.value, with: {(snapshot) in
            let value = snapshot.value
            if let val = value as? CGFloat {
                self.dbZ = Float(val)
                self.updateAngles()
            }
        })
    }
    
}
