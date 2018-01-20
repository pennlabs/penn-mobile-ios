//
//  TransitionalHomeCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

@objc protocol Transitionable where Self: GeneralHomeCell {
    var transitionButton: UIButton! { get set }
}

// MARK: - Prepare UI
extension Transitionable {
    func prepareTransitionButton() {
        transitionButton = HomeTransitionButton(type: .system)
        transitionButton.setTitle("Transition", for: .normal)
        
        guard let button = transitionButton as? HomeTransitionButton else { return }
        button.addTarget {
            guard let page = self.item?.type.page else { return }
            self.delegate.handleTransition(to: page)
        }
        
        addSubview(transitionButton)
        
        _ = transitionButton.anchor(topAnchor, left: nil, bottom: nil, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 100, heightConstant: 0)
    }
}

// MARK: - HomeTransitionButton
// Necessary because cannot directly implement #selector in a protocol extension
fileprivate class HomeTransitionButton: UIButton {
    typealias TransitionHandler = () -> Void
    
    fileprivate var transitionHandler: TransitionHandler?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(handleTransitionButton(_:)), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addTarget(_ handler: @escaping TransitionHandler) {
        self.transitionHandler = handler
    }
    
    func handleTransitionButton(_ sender: Any) {
        transitionHandler?()
    }
}
