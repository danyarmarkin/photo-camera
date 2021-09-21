//
//  SessionCell.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 21.09.2021.
//

import UIKit

class SessionCell: UITableViewCell {

    @IBOutlet weak var preview: UIImageView!
    @IBOutlet weak var framesAmountLabel: UILabel!
    @IBOutlet weak var sessionNameLabel: UILabel!
    @IBOutlet weak var isTrashSwitch: UISwitch!
    @IBOutlet weak var exportButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func onSwitch(_ sender: UISwitch) {
    }
    
    @IBAction func onExport(_ sender: Any) {
    }
}
