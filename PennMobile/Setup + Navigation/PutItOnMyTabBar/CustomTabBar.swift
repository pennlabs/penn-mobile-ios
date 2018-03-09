//
//  JWTabBar.swift
//  JW_TabBarController
//
//  Created by Jacob Wagstaff on 8/18/17.
//  Copyright © 2017 Jacob Wagstaff. All rights reserved.
//
import UIKit

protocol CustomTabBarDelegate {
    func didSelectViewController(_ tabBarView: CustomTabBar, atIndex index: Int)
    func numberOfTabs() -> Int
    func highLightedImages() -> [UIImage]
    func unHighlightedImages() -> [UIImage]
    func backgroundColor() -> UIColor
    func sliderColor() -> UIColor
    func sliderHeightMultiplier() -> CGFloat
    func sliderWidthMultiplier() -> CGFloat
    func animationDuration() -> Double
    func tabBarType() -> TabBarItemType
    func titles() -> [String]
    func fontForTitles() -> UIFont
    func titleColors() -> (UIColor, UIColor)
}

class CustomTabBar: UIView {
    
    var delegate: CustomTabBarDelegate!
    
    var tabStack = UIStackView()
    var tabBarItems: [TabBarItem] = []
    
    var previousIndex = 0
    
    var unHighlightedImages : [UIImage] = []
    var highlightedImages : [UIImage] = []
    
    var titles : [String] = []
    var titleFont : UIFont?
    
    var titleColors: (UIColor, UIColor) = (.white, .white)
    
    var sliderContainerView = UIView()
    var sliderView = UIView()
    var sliderConstraints : [NSLayoutConstraint] = []
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    func setup(){
        setDataFromDelegate()
        configureSubviews()
        configureLayout()
    }
    
    fileprivate func setDataFromDelegate(){
        unHighlightedImages = delegate.unHighlightedImages()
        highlightedImages = delegate.highLightedImages()
        
        titles = delegate.titles()
        titleFont = delegate.fontForTitles()
        titleColors = delegate.titleColors()
    }
    
    fileprivate func configureSubviews(){
        backgroundColor = delegate.backgroundColor()
        sliderContainerView.backgroundColor = .clear
        sliderView.backgroundColor = delegate.sliderColor()
        
        tabStack.axis = .horizontal
        tabStack.distribution = .fillProportionally
        
        //Set Attributes for each Tab
        for index in 1...delegate.numberOfTabs(){
            let newTab = TabBarItem()
            if delegate.tabBarType() == .icon{
                newTab.setupTabBarItem(type: .icon)
                if index == 1{
                    newTab.iconView.image = highlightedImages[index - 1]
                }else{
                    newTab.iconView.image = unHighlightedImages[index - 1]
                }
            }else{
                newTab.setupTabBarItem(type: .label)
                if index == 1{
                    newTab.iconView.image = highlightedImages[index - 1]
                    newTab.label.text = titles[index - 1]
                    newTab.label.font = titleFont
                    newTab.label.textColor = titleColors.0
                }else{
                    newTab.iconView.image = unHighlightedImages[index - 1]
                    newTab.label.text = titles[index - 1]
                    newTab.label.font = titleFont
                    newTab.label.textColor = titleColors.1
                }
            }
            
            
            
            newTab.containerButton.addTarget(self, action: #selector(CustomTabBar.barItemTapped(_:)), for: UIControlEvents.touchUpInside)
            tabBarItems.append(newTab)
            tabStack.addArrangedSubview(newTab)
        }
    }
    
    fileprivate func configureLayout(){
        addAutoLayoutSubview(sliderContainerView)
        sliderContainerView.addAutoLayoutSubview(sliderView)
        
        addAutoLayoutSubview(tabStack)
        tabStack.fillSuperview()
        
        NSLayoutConstraint.activate([
            sliderContainerView.heightAnchor.constraint(equalTo: tabStack.heightAnchor, multiplier: delegate.sliderHeightMultiplier()),
            sliderContainerView.bottomAnchor.constraint(equalTo: tabStack.bottomAnchor),
            
            sliderView.widthAnchor.constraint(equalTo: sliderContainerView.widthAnchor, multiplier: delegate.sliderWidthMultiplier()),
            sliderView.topAnchor.constraint(equalTo: sliderContainerView.topAnchor),
            sliderView.bottomAnchor.constraint(equalTo: sliderContainerView.bottomAnchor),
            sliderView.centerXAnchor.constraint(equalTo: sliderContainerView.centerXAnchor)
            ])
    }
    
    func barItemTapped(_ sender : UIButton) {
        let index = tabStack.arrangedSubviews.index(of: sender.superview!)!
        
        unhighlightPrevious(index: previousIndex)
        previousIndex = index
        highlightSelected(index: index)
        
        delegate?.didSelectViewController(self, atIndex: index)
    }
    
    func unhighlightPrevious(index: Int){
        //Set Image
        tabBarItems[index].iconView.image = unHighlightedImages[index]
        tabBarItems[index].label.textColor = titleColors.1
    }
    
    func highlightSelected(index: Int){
        //Set Image
        tabBarItems[index].iconView.image = highlightedImages[index]
        tabBarItems[index].label.textColor = titleColors.0
        
        //Animate Slider
        NSLayoutConstraint.deactivate(sliderConstraints)
        
        sliderConstraints = [
            sliderContainerView.leftAnchor.constraint(equalTo: tabBarItems[index].leftAnchor),
            sliderContainerView.rightAnchor.constraint(equalTo: tabBarItems[index].rightAnchor)
        ]
        
        NSLayoutConstraint.activate(sliderConstraints)
        
        UIView.animate(withDuration: delegate.animationDuration(), delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: { _ in
        })
        
    }
    
}
