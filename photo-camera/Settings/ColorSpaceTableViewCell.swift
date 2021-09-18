//
//  ColorSpaceTableViewCell.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 18.09.2021.
//

import UIKit

class ColorSpaceTableViewCell: UITableViewCell {

    @IBOutlet weak var colorSpace: UISegmentedControl!
    @IBOutlet weak var nameLabel: UILabel!
    
    func configure(text: String) {
        nameLabel.text = text
        colorSpace.selectedSegmentIndex = LocalStorage.getInt(key: LocalStorage.csVal)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func onColorSpace(_ sender: UISegmentedControl) {
        LocalStorage.set(key: LocalStorage.csVal, val: sender.selectedSegmentIndex)
    }
}
