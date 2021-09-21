//
//  ActionCell.swift
//  photo-camera
//
//  Created by Данила Ярмаркин on 21.09.2021.
//

import UIKit

class ActionCell: UITableViewCell {

    @IBOutlet weak var actionName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
