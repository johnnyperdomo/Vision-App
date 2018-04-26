//
//  RoundedShadowView.swift
//  Vision-App
//
//  Created by Johnny Perdomo on 4/26/18.
//  Copyright © 2018 Johnny Perdomo. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        self.layer.shadowRadius = 15 //blurs shadow
        self.layer.shadowOpacity = 0.75 //opaque
        self.layer.cornerRadius = self.frame.height / 2 //rounds corners
    }

}
