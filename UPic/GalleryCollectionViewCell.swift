//
//  GalleryCollectionViewCell.swift
//  UPic
//
//  Created by Eric Chang on 2/7/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

class GalleryCollectionViewCell: UICollectionViewCell {

    var imageView: UIImageView!
    var newOverlay: UIView!
    var upArrow: UIImageView!
    var upLabel: UILabel!
    var downArrow: UIImageView!
    var downLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let fullFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        
        imageView = UIImageView(frame: fullFrame)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        newOverlay = UIView(frame: fullFrame)
        newOverlay.backgroundColor = .black
        newOverlay.alpha = 0.2
        
        upArrow = UIImageView()
        upArrow.image = #imageLiteral(resourceName: "up_arrow").maskWithColor(color: .white)
        
        downArrow = UIImageView()
        downArrow.image = #imageLiteral(resourceName: "down_arrow").maskWithColor(color: .white)
        
        upLabel = UILabel()
        upLabel.text = ""
        upLabel.textColor = ColorPalette.textIconColor
        
        downLabel = UILabel()
        downLabel.text = ""
        downLabel.textColor = ColorPalette.textIconColor
        
        contentView.addSubview(imageView)
        contentView.addSubview(newOverlay)
        contentView.addSubview(upArrow)
        contentView.addSubview(downArrow)
        contentView.addSubview(upLabel)
        contentView.addSubview(downLabel)
        
        upArrow.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().inset(50.0)
            make.leading.equalTo(downArrow)
            make.width.height.equalTo(downArrow)
        }
        
        downArrow.snp.makeConstraints { (make) in
            make.bottom.leading.equalToSuperview().inset(10.0)
            make.height.width.equalTo(30.0)
        }
        
        upLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(upArrow.snp.trailing).offset(8.0)
            make.centerY.equalTo(upArrow)
        }
        
        downLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(downArrow.snp.trailing).offset(8.0)
            make.centerY.equalTo(downArrow)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
}
