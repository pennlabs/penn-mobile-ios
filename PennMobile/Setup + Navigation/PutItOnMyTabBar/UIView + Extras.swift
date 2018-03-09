//
//  UIView+Extras.swift
//

import UIKit

extension UIView {
    
    // MARK: - NSLayoutConstraint Convenience Methods
    
    func addAutoLayoutSubview(_ subview: UIView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func insertAutoLayoutSubview(_ view: UIView, belowSubview: UIView) {
        insertSubview(view, belowSubview: belowSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func insertAutoLayoutSubview(_ view: UIView, aboveSubview: UIView) {
        insertSubview(view, aboveSubview: aboveSubview)
        view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Layout
    
    func fillSuperview() {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ])
    }
    
    func fillSuperviewLayoutMargins() {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([
            leftAnchor.constraint(equalTo: superview.leftMargin),
            rightAnchor.constraint(equalTo: superview.rightMargin),
            topAnchor.constraint(equalTo: superview.topMargin),
            bottomAnchor.constraint(equalTo: superview.bottomMargin)
            ])
    }
    
    func centerInSuperView() {
        guard let superview = self.superview else { return }
        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
            ])
    }
    
    // MARK: - Layout Shortcuts
    func rightToRight(constant: CGFloat = 0) {
        guard let superview = self.superview else { return }
        rightAnchor.constraint(equalTo: superview.rightAnchor, constant: constant).isActive = true
    }
    
    // MARK: - Layout Margins Guide Shortcut
    
    var leftMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.leftAnchor
    }
    
    var rightMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.rightAnchor
    }
    
    var centerXMargin: NSLayoutXAxisAnchor {
        return layoutMarginsGuide.centerXAnchor
    }
    
    var widthMargin: NSLayoutDimension {
        return layoutMarginsGuide.widthAnchor
    }
    
    var topMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.topAnchor
    }
    
    var bottomMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.bottomAnchor
    }
    
    var centerYMargin: NSLayoutYAxisAnchor {
        return layoutMarginsGuide.centerYAnchor
    }
    
    var heightMargin: NSLayoutDimension {
        return layoutMarginsGuide.heightAnchor
    }
    
    // MARK: - Borders
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
}
