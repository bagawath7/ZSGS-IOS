//
//  PlayerTableViewCell.swift
//  Cricket
//
//  Created by zs-mac-4 on 08/10/22.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

    @IBOutlet weak var PlayerImage: UIImageView!
    @IBOutlet weak var PlayerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
