//
//  Utilities.swift
//  UPic
//
//  Created by Eric Chang on 2/6/17.
//  Copyright © 2017 Eric Chang. All rights reserved.
//

import UIKit

// Titles
protocol CellTitled {
    var titleForCell: String { get }
}

// Colors
struct ColorPalette {
    static let darkPrimaryColor: UIColor = UIColor(red:0.27, green:0.35, blue:0.39, alpha:1.0)
    static let primaryColor: UIColor = UIColor(red:0.38, green:0.49, blue:0.55, alpha:1.0)
    static let lightPrimaryColor: UIColor = UIColor(red:0.81, green:0.85, blue:0.86, alpha:1.0)
    static let textIconColor: UIColor = UIColor(red:1.00, green:1.00, blue:1.00, alpha:1.0)
    static let accentColor: UIColor = UIColor(red:1.00, green:0.84, blue:0.25, alpha:1.0)
    static let primaryTextColor: UIColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
    static let secondaryTextColor: UIColor = UIColor(red:0.45, green:0.45, blue:0.45, alpha:1.0)
    static let dividerColor: UIColor = UIColor(red:0.71, green:0.71, blue:0.71, alpha:1.0)
}

// Categories
public enum GallerySections: String {
    case woofmeow = "WOOFS & MEOWS"
    case nature = "NATURE"
    case architecture = "ARCHITECTURE"
    
    static let sections: [String] = [GallerySections.woofmeow,
                                     GallerySections.nature,
                                     GallerySections.architecture].map { $0.rawValue }
    
    static func numberOfGallerySections() -> Int {
        return GallerySections.sections.count
    }
}

// Textfield Style
extension UITextField {
    
    func styled(placeholder: String) {
        
        let border = CALayer()
        let width = CGFloat(1.0)
        
        border.borderColor = UIColor.white.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
        
        self.textColor = ColorPalette.accentColor
        self.tintColor = ColorPalette.accentColor
        self.attributedPlaceholder = NSAttributedString(string: placeholder.uppercased(),
                                                             attributes: [NSForegroundColorAttributeName: ColorPalette.accentColor])
    }
}

// Button Style

extension UIButton {
    
    func styled(title: String) {
        
        self.setTitle(title.uppercased(), for: .normal)
        self.setTitleColor(ColorPalette.textIconColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16.0)
        
        self.backgroundColor = ColorPalette.primaryColor
        
        self.layer.borderColor = ColorPalette.textIconColor.cgColor
        self.layer.borderWidth = 1.0
    }
}
