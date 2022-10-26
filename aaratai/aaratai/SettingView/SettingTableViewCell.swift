//
//  SettingTableViewCell.swift
//  aaratai
//
//  Created by zs-mac-4 on 17/10/22.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var settingImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        settingImageView.layer.cornerRadius = 10
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
