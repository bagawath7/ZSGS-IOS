//
//  CollectionViewCell.swift
//  Instagram-Clone
//
//  Created by zs-mac-4 on 28/10/22.
//

import UIKit

class FeedCell: UICollectionViewCell {
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: "bagawath.jpg")
        return iv
    }()
    
    private lazy var usernameButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Bagawath", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didtapUsername), for: .touchUpInside)
        return button
    }()
    
    private var postImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.image = UIImage(named: "zoho.jpg")
        return iv
    }()
    
    private lazy var likeButton:UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(named:"like_unselected" ), for: .normal)
        button.addTarget(self, action: #selector(didtapUsername), for: .touchUpInside)
        return button
    }()
    private lazy var commentButton:UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(named:"comment" ), for: .normal)
        button.addTarget(self, action: #selector(didtapUsername), for: .touchUpInside)
        return button
    }()
    
    private lazy var shareButton:UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(named:"send2" ), for: .normal)
        button.addTarget(self, action: #selector(didtapUsername), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel:UILabel = {
        let label = UILabel()
        label.text = "100 likes"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
        
    }()
    
    private let captionLabel:UILabel = {
        let label = UILabel()
        label.text = "Zoho❤️"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .black
        return label
        
    }()
    private let postTimeLabel:UILabel = {
        let label = UILabel()
        label.text = "2 days ago"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private var stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        layout()
       
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didtapUsername(){
        print("Tapped")
    }
    
    func layout(){
        
        //MARK: ProfileImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor,left: leadingAnchor, paddingTop: 12,paddingLeft: 12,width: 40, height: 40)
        profileImageView.layer.cornerRadius = 20.0
     
        //MARK: UsernameButtomn

        addSubview(usernameButton)
        usernameButton.centerY(inView: profileImageView,leftAnchor: profileImageView.trailingAnchor,paddingLeft: 8)
        
        //MARK: PostImageView

        addSubview(postImageView)
        postImageView.anchor(top: profileImageView.bottomAnchor,left: leadingAnchor,right: trailingAnchor,paddingTop: 8)
        postImageView.heightAnchor.constraint(equalTo: widthAnchor,multiplier: 1).isActive =  true
        
        //MARK: StackView

        
        
        stackView = UIStackView(arrangedSubviews: [likeButton,commentButton,shareButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        stackView.anchor(top: postImageView.bottomAnchor,width: 120,height: 50)
        
        //MARK: LikesLabel
        
        addSubview(likesLabel)
        likesLabel.anchor(top: stackView.bottomAnchor,left: leadingAnchor,paddingTop: -8,paddingLeft:  8)
        
        //MARK: CaptionLabel

        
        addSubview(captionLabel)
        captionLabel.anchor(top: likesLabel.bottomAnchor,left: leadingAnchor,paddingTop: 8,paddingLeft: 8)
        
        //MARK: PostTimeLabel

        addSubview(postTimeLabel)
        postTimeLabel.anchor(top: captionLabel.bottomAnchor,left: leadingAnchor,paddingTop:  8,paddingLeft:  8)
        
    }
   
    }

