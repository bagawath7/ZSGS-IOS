//
//  PeopleTableViewCell.swift
//  ContactView
//
//  Created by zs-mac-4 on 26/09/22.
//

import UIKit

class PeopleTableViewCell: UITableViewCell {
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userimage: UIImageView!
    
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var userrole: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        userimage.layer.cornerRadius = 15.0
        arrow.image = UIImage(named: "arrow")
        arrow.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
