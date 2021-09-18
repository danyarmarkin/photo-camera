//
//  SwitchTableViewCell.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 18.09.2021.
//

import UIKit
import Firebase

class SwitchTableViewCell: UITableViewCell {
    @IBOutlet weak var mainSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    var type: cellType!
    var ref: DatabaseReference!
    var isMainDeviceCell = false
    
    func configure(name: String, isOn: Bool, cellType: cellType) {
        nameLabel.text = name
        mainSwitch.isOn = isOn
        type = cellType
        
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        
        if cellType == .main_device {
            isMainDeviceCell = true
            ref.child("mainDevice").observe(.value) { snapshot in
                if let val = snapshot.value as? String {
                    if val == LocalStorage.getString(key: LocalStorage.deviceName) {
                        LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
                        let devices = DeviceControl()
                        devices.configure(ref: self.ref)
                        devices.updateDevices()
                        self.mainSwitch.isOn = true
                    } else {
                        LocalStorage.set(key: LocalStorage.isMainDevice, val: false)
                        self.mainSwitch.isOn = false
                    }
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitch(_ sender: UISwitch) {
        if isMainDeviceCell {
            LocalStorage.set(key: LocalStorage.isMainDevice, val: true)
            ref.child("mainDevice").setValue(LocalStorage.getString(key:LocalStorage.deviceName))
            self.mainSwitch.isOn = true
            let devices = DeviceControl()
            devices.configure(ref: self.ref)
            devices.updateDevices()
            
        }
    }
}
