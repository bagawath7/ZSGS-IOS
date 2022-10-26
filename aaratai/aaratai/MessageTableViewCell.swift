//
//  MessageTableViewCell.swift
//  aaratai
//
//  Created by zs-mac-4 on 18/10/22.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet var senderImage: UIImageView!
    @IBOutlet  var leading: NSLayoutConstraint!
    @IBOutlet var trailing: NSLayoutConstraint!
   
    @IBOutlet weak var messageTextField: UILabel!
    
    @IBOutlet weak var messageView: UIView!
    static let identifier="MessageTableViewCell"
    override func awakeFromNib() {
        

        super.awakeFromNib()
        // Initialization code

    }
    
    override func layoutSubviews() {
        super .layoutSubviews()
        messageView.layer.cornerRadius = messageView.frame.size.height / 5
        senderImage.layer.cornerRadius = 25.0
        senderImage.contentMode = .scaleAspectFit
        selectionStyle = .none
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
  
    
}
