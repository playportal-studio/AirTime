//
//  PPLoginButton.swift
//  PlayPortal
//
//  Created by Gary J. Baldwin on 9/12/18.
//  Copyright © 2018 Dynepic. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class PPLoginButton : UIButton {
    init() {

        
        //Ratio is 279w / 55h
        var buttonWidth: CGFloat = UIScreen.main.bounds.size.width * 0.7
        if buttonWidth > 300 {
            buttonWidth = 300
        }
        let buttonHeight: CGFloat = buttonWidth * 55 / 279
        let rect = CGRect(x: 0, y: 0, width: buttonWidth, height: buttonHeight)

        super.init(frame: rect)
        
        addImage()
        addTarget(self, action: #selector(PPLoginButton.didTouch), for: .touchUpInside)
        layer.cornerRadius = buttonHeight / 2
        layer.masksToBounds = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addImage() {
        let bundle = Bundle(for: PPLoginButton.self)
        let image = UIImage(named: "SSOButtonImage", in: bundle, compatibleWith: traitCollection)
        let ssoButtonImage = UIImageView(image: image)
        ssoButtonImage.frame = bounds
        ssoButtonImage.contentMode = .scaleAspectFit
        addSubview(ssoButtonImage)
        sendSubview(toBack: ssoButtonImage)
    }
    
    @objc func didTouch() {
        PPManager.sharedInstance.PPusersvc.login()
    }
}
