//
//  TodoTableViewCell.swift
//  APITesting
//
//  Created by zs-mac-4 on 06/10/22.
//

import UIKit

class TodoTableViewCell: UITableViewCell {

    
    @IBOutlet weak var id : UILabel!
    @IBOutlet weak var title : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
