//
//  VotersFeedTableViewCell.swift
//  UPic
//
//  Created by Madushani Lekam Wasam Liyanage on 2/10/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

class VotersFeedTableViewCell: UITableViewCell {
    
    var propicImage = UIImageView()
    var feedLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        propicImage.contentMode = .scaleAspectFill
        propicImage.layer.cornerRadius = contentView.frame.size.height / 2
        propicImage.layer.masksToBounds = true
        
        
        contentView.addSubview(propicImage)
        contentView.addSubview(feedLabel)
        
        propicImage.snp.makeConstraints { (make) in
            make.width.height.equalTo(50.0)
            make.leading.equalTo(contentView.snp.leading).offset(8.0)
            make.centerY.equalTo(contentView)
        }
        
        feedLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(propicImage.snp.trailing).offset(8.0)
            make.height.centerY.equalTo(contentView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }


}
