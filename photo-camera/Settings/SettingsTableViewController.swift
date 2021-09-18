//
//  SettingsTableViewController.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 18.09.2021.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: #selector(didTapView))
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func didTapView(){
      self.view.endEditing(true)
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath[1] {
        case 0, 1, 2, 3, 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "number_settings_cell", for: indexPath) as! NumberTableViewCell
            return congigureNumberCell(cell: cell, index: indexPath[1])
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cs_settings_cell", for: indexPath) as! ColorSpaceTableViewCell
            cell.configure(text: "Color Space")
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "switch_settings_cell", for: indexPath) as! SwitchTableViewCell
            return configureSwitchCell(cell: cell, index: indexPath[1])
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "number_settings_cell", for: indexPath) as! NumberTableViewCell
            return cell
        }
    }
    
    func congigureNumberCell(cell: NumberTableViewCell, index: Int) -> NumberTableViewCell {
        print("number cell with index \(index)")
        switch index {
        case 0:
            cell.configure(name: "ISO", value: NSNumber(value: LocalStorage.getInt(key: LocalStorage.isoVal)), cellType: .iso)
            return cell
        case 1:
            cell.configure(name: "Shutter", value: NSNumber(value: LocalStorage.getInt(key: LocalStorage.shutterVal)), cellType: .shutter)
            return cell
        case 2:
            cell.configure(name: "White Balance (K)", value: NSNumber(value: LocalStorage.getInt(key: LocalStorage.wbVal)), cellType: .wb)
            return cell
        case 3:
            cell.configure(name: "Tint", value: NSNumber(value: LocalStorage.getInt(key: LocalStorage.tintVal)), cellType: .tint)
            return cell
        case 4:
            cell.configure(name: "FPS", value: NSNumber(value: LocalStorage.getInt(key: LocalStorage.fpsVal)), cellType: .fps)
            return cell
        default:
            return cell
        }
    }
    
    func configureSwitchCell(cell: SwitchTableViewCell, index: Int) -> SwitchTableViewCell {
        switch index {
        case 6:
            cell.configure(name: "Is Main Device", isOn: LocalStorage.getBool(key: LocalStorage.isMainDevice), cellType: .main_device)
            return cell
        default:
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath[1] == 5 {return 77.0}
        return 43.333
    }
}


extension UITableViewCell {
    enum cellType {
        case iso
        case shutter
        case wb
        case tint
        case color_spase
        case main_device
        case fps
        case exposure
        case lens_pos
    }
}
