//
//  ProfileHeaderCell.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 02/11/22.
//

import UIKit
import SDWebImage

protocol ProfileHeaderDelegate: AnyObject{
    
    func header(_ profileHeader:ProfileHeaderCell,didTapActionButtonFor user:UserModel.ViewModel.User)
    
}


class ProfileHeaderCell: UICollectionViewCell {
    
    var viewmodel: ProfileModel.ViewModel.HeaderViewmodel?{
        didSet{
            configure()
        }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(){
        if let viewmodel = viewmodel{
            nameLabel.text = viewmodel.fullname
            profileImageView.sd_setImage(with: viewmodel.profileImageUrl)
            
            editProfileFollowButton.setTitle(viewmodel.followButtonText, for: .normal)
            editProfileFollowButton.setTitleColor(viewmodel.followButtonTextColor, for: .normal)
            editProfileFollowButton.backgroundColor = viewmodel.followButtonBackGroundColor
            
            postsLabel.attributedText = viewmodel.noOfPosts
            followerslabel.attributedText = viewmodel.noOfFollowers
            followingLabel.attributedText = viewmodel.noOfFollowing
            
        }
        
    }
    func layout(){
        //MARK: ProfileImageView
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,left: leadingAnchor,paddingTop: 16,paddingLeft: 12)
        profileImageView.setDimensions(height: 60, width: 60)
        
        //MARK: NameLabel
        
        addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor,left: leadingAnchor,paddingTop: 12 ,paddingLeft: 12)
        
        //MARK: CaptionLabel
        addSubview(captionLabel)
        captionLabel.anchor(top: nameLabel.bottomAnchor,left: leadingAnchor,paddingTop: 12 ,paddingLeft: 12)
        
        //MARK: EditProfileFollowButton
        addSubview(editProfileFollowButton)
        editProfileFollowButton.anchor(top: captionLabel.bottomAnchor, left: leadingAnchor,
        right: trailingAnchor,paddingTop: 16,paddingLeft: 24,paddingRight: 24)
        
        //MARK: StackView for posts,following,followers
        let stack = UIStackView(arrangedSubviews: [postsLabel,followerslabel,followingLabel])
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.centerY(inView: profileImageView)
        stack.anchor(left: profileImageView.trailingAnchor,right: trailingAnchor,paddingLeft: 12,paddingRight: 12,height: 50)
        
        let topDivider = UIView()
        topDivider.backgroundColor = .lightGray
        
        let bottomDivider = UIView()
        bottomDivider.backgroundColor = .lightGray
        
        let buttonStack = UIStackView(arrangedSubviews: [gridButton,listButton,bookmarkButton])
        buttonStack.distribution = .fillEqually
        
        
        addSubview(buttonStack)
//        addSubview(topDivider)
//       addSubview(bottomDivider)
        buttonStack.anchor(top:editProfileFollowButton.bottomAnchor,left: leadingAnchor,bottom: bottomAnchor,right: trailingAnchor,paddingTop: 2, height: 50)
//        topDivider.anchor(top: buttonStack.topAnchor,left: leadingAnchor,right: trailingAnchor,
//                         height: 0.5)
//        buttonStack.anchor(top: buttonStack.bottomAnchor,left: leadingAnchor,right: trailingAnchor,height: 0.5)
    }
    
    private let profileImageView:UIImageView = {
        let iv = UIImageView()
//        iv.image = UIImage(named: "bagawath")
        iv.backgroundColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 30
        return iv
    }()
    private let nameLabel:UILabel = {
        let label = UILabel()
//        label.text = "Bagawath"
        label.font = UIFont.boldSystemFont(ofSize: 14)
        return  label
    }()
    
    private let captionLabel:UILabel = {
        let label = UILabel()
        label.text = "ZSGS/22"
        label.font = UIFont.systemFont(ofSize: 14)
        return  label
    }()
    
    private lazy var editProfileFollowButton:UIButton = {
        let button = UIButton()
        button.setTitle("Edit Profile", for: .normal)
        button.layer.cornerRadius = 3
        button.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.borderWidth = 0.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleEditProfileFollowTap), for: .touchUpInside)
        return button
    }()
    
    private lazy var postsLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
        
    }()
    
    private lazy var followerslabel :UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
        
    }()
    
    private lazy var followingLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center

        return label
        
    }()
    
    
    let gridButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "grid"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let listButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "list"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    let bookmarkButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "ribbon"), for: .normal)
        button.tintColor = UIColor(white: 0, alpha: 0.2)
        return button
    }()
    
    //MARK: ACTIONS
    
    @objc func handleEditProfileFollowTap(){
        if let viewmodel = viewmodel{
            delegate?.header(self, didTapActionButtonFor: viewmodel.user)
            
        }
    }
    
  
}

    
    

