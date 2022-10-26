//
//  SongsCollectionViewCell.swift
//  Music
//
//  Created by zs-mac-2 on 12/10/22.
//

import UIKit

class SongsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var rank: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var listners: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        myImageView.layer.borderColor = UIColor.black.cgColor
        myImageView.layer.borderWidth = 0.5
    }

}
