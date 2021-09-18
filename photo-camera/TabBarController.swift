//
//  TabBarController.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 16.09.2021.
//

import UIKit
import Firebase

class TabBarController: UITabBarController {
    var ref: DatabaseReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        LocalStorage.set(key: LocalStorage.deviceName, val: UIDevice.current.name + "-" + UIDevice.current.model)
        ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(1)
        registerLive()
        UIApplication.shared.isIdleTimerDisabled = true
        
        if (LocalStorage.getInt(key: LocalStorage.isoVal) == 0) {
            LocalStorage.set(key: LocalStorage.isoVal, val: 100)
        }
        if (LocalStorage.getInt(key: LocalStorage.shutterVal) == 0) {
            LocalStorage.set(key: LocalStorage.shutterVal, val: 200)
        }
        if (LocalStorage.getInt(key: LocalStorage.wbVal) == 0) {
            LocalStorage.set(key: LocalStorage.wbVal, val: 3000)
        }
        if (LocalStorage.getInt(key: LocalStorage.fpsVal) == 0) {
            LocalStorage.set(key: LocalStorage.fpsVal, val: 4)
        }
        
        ref.child("mainDevice").observe(.value) { snapshot in
            if let val = snapshot.value as? String {
                if val == LocalStorage.getString(key: LocalStorage.deviceName) {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
                    let devices = DeviceControl()
                    devices.configure(ref: self.ref)
                    devices.updateDevices()
                } else {
                    LocalStorage.set(key: LocalStorage.isMainDevice, val: false)
                }
            }
        }
        let deviceControl = DeviceControl()
        deviceControl.configure(ref: ref)
        deviceControl.monitorDevices()
    }
    
    func registerLive() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterFocus),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(enterBackground),
                                               name: UIApplication.didFinishLaunchingNotification,
                                               object: nil)
    }
    
    @objc func enterBackground() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(0)
    }
    
    @objc func enterFocus() {
        self.ref.child("devices").child(LocalStorage.getString(key: LocalStorage.deviceName)).setValue(1)
    }
}
