//
//  NumberTableViewCell.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 18.09.2021.
//

import UIKit
import Firebase

class NumberTableViewCell: UITableViewCell {
    @IBOutlet weak var number: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    var type: cellType!
    var ref: DatabaseReference!
    var storgeId: String!
    var firebaseId: String!
    var sync = true
    
    func configure(name: String, value: NSNumber, cellType: cellType) {
        number.text = "\(value)"
        nameLabel.text = name
        type = cellType
        ref = Database.database(url: "https://camera-scan-e5684-default-rtdb.europe-west1.firebasedatabase.app/").reference()
        switch cellType {
        case .iso:
            storgeId = LocalStorage.isoVal
            firebaseId = "iso"
            break
        case .shutter:
            storgeId = LocalStorage.shutterVal
            firebaseId = "shutter"
            break
        case .fps:
            storgeId = LocalStorage.fpsVal
            firebaseId = "fps"
            break
        case .wb:
            storgeId = LocalStorage.wbVal
            firebaseId = "wb"
            break
        case .tint:
            storgeId = LocalStorage.tintVal
            firebaseId = "tint"
            break
        default:
            storgeId = LocalStorage.isoVal
            firebaseId = "iso"
            break
        }
        
        if cellType == .fps {
            sync = false
            return
        }
        
        ref.child("cameraConf").child(firebaseId).observe(.value){snapshot in
            if let val = snapshot.value as? Int {
                LocalStorage.set(key: self.storgeId, val: val)
                self.number.text = "\(val)"
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

    @IBAction func onParam(_ sender: UITextField) {
        LocalStorage.set(key: storgeId, val: Int(sender.text ?? "0") ?? 0)
        if sync {
            ref.child("cameraConf").child(firebaseId).setValue(Int(sender.text ?? "0") ?? 0)
        }
    }
}
