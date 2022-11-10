//
//  ProfileCell.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 02/11/22.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemPink
        addSubview(postImageView)
        postImageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let postImageView:UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "zoho.jpg")
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
}
