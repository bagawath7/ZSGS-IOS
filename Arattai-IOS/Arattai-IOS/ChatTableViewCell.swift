//
//  ChatTableViewCell.swift
//  Aaratai_Clone
//
//  Created by zs-mac-4 on 21/10/22.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    @IBOutlet weak var UserImage: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var NoOfUnreadMessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        NoOfUnreadMessage.layer.cornerRadius = 12.5
        NoOfUnreadMessage.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
