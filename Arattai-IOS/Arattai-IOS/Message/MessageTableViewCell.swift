//
//  MessageTableViewCell.swift
//  Arattai-IOS
//
//  Created by zs-mac-4 on 26/10/22.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet  var leading: NSLayoutConstraint!
    @IBOutlet  var trailing: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
//    var trailingOdd:NSLayoutConstraint!
//    var leadingOdd: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        messageLabel.layer.cornerRadius = messageLabel.frame.size.height / 2
        messageLabel.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
