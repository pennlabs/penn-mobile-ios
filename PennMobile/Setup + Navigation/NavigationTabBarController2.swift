//
//  NavigationTabBarController2.swift
//  PennMobile
//
//  Created by Josh Doman on 3/9/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class NavigationTabBarController2: PutItOnMyTabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = ControllerModel.shared.viewControllers.map {
            UINavigationController(rootViewController: $0)
        }
    }

    override func numberOfTabs() -> Int {
        return ControllerModel.shared.viewControllers.count
    }
    
    override func unHighlightedImages() -> [UIImage] {
        let homeImage = UIImage(named: "home_icon")!.withRenderingMode(.alwaysTemplate)
        return ControllerModel.shared.viewControllers.map { _ in return homeImage }
    }
    
    override func highLightedImages() -> [UIImage] {
        let homeImage = UIImage(named: "home_icon")!.withRenderingMode(.alwaysTemplate)
        return ControllerModel.shared.viewControllers.map { _ in return homeImage }
    }
    
    override func unHighlightedColor() -> UIColor {
        return .black
    }
    
    override func highlightedColor() -> UIColor {
        return .navRed
    }
    
    override func backgroundColor() -> UIColor {
        return .white
    }
    
    override func sliderColor() -> UIColor {
        return .clear
    }
    
    override func sliderHeightMultiplier() -> CGFloat {
        return 0.1
    }
    
    override func sliderWidthMultiplier() -> CGFloat {
        return 1.0
    }
}

extension UITabBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 40
        return sizeThatFits
    }
}
