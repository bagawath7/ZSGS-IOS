//
//  ChatTableViewCell.swift
//  aaratai
//
//  Created by zs-mac-4 on 17/10/22.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var profilepic: UIImageView!
    @IBOutlet weak var lastmessage: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var msgLabel: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profilepic.layer.cornerRadius = 25
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
