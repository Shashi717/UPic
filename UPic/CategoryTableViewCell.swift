//
//  CategoryTableViewCell.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    // MARK: - Properties
    var newImage = UIImageView()
    var newOverlay = UIView()
    var newLabel = UILabel()
    
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
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // Customize overlay
        newImage.contentMode = .scaleAspectFill
        
        newOverlay.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        newLabel.textAlignment = .center
        newLabel.textColor = ColorPalette.textIconColor
        newLabel.layer.borderColor = ColorPalette.textIconColor.cgColor
        newLabel.layer.borderWidth = 3.0
        
        // Adding new overlay
        setHierarchyAndConstraintsOf(imageView: newImage,
                                     overlay: newOverlay,
                                     label: newLabel,
                                     to: contentView)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    // MARK: - Cell Setup
    internal func setHierarchyAndConstraintsOf(imageView: UIImageView, overlay: UIView, label: UILabel, to cell: UIView) {
        cell.addSubview(imageView)
        cell.addSubview(overlay)
        cell.addSubview(label)
        
        imageView.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(cell)
        }
        
        overlay.snp.makeConstraints { (make) in
            make.leading.top.trailing.bottom.equalTo(imageView)
        }
        
        label.snp.makeConstraints { (make) in
            make.center.equalTo(overlay)
            make.width.equalTo(250.0)
            make.height.equalTo(80.0)
        }
    }

}
