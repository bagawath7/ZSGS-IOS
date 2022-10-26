//
//  TableAnimationViewCell.swift
//  TableView
//
//  Created by zs-mac-4 on 28/09/22.
//

import UIKit

class TableAnimationViewCell: UITableViewCell {
    override class func description() -> String {
            return "TableAnimationViewCell"
        }

    @IBOutlet weak var ContainerView: UIView!
    var tableViewHeight: CGFloat = 62
        var color = UIColor.white {
            didSet {
                self.ContainerView.backgroundColor = color
            }
        }
    override func awakeFromNib() {
        super.awakeFromNib()
        super.awakeFromNib()
                self.selectionStyle = .none
                self.ContainerView.layer.cornerRadius = 4
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
