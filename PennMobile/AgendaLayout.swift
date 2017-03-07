//
//  AgendaLayout.swift
//  PennMobile
//
//  Created by Josh Doman on 3/5/17.
//  Copyright © 2017 PennLabs. All rights reserved.
//

import UIKit

protocol ScheduleLayoutDelegate {
    // 1. Method to ask the delegate for the height of the cell
    func collectionView(collectionView:UICollectionView, heightForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat
    // 2. Method to ask the delegate for the width of the cell
    func collectionView(collectionView: UICollectionView, widthForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat

    // 3. Methods ask for x and yOffsets
    func collectionView(collectionView: UICollectionView, xOffsetForCellAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat
    func collectionView(collectionView: UICollectionView, yOffsetForCellAtIndexPath indexPath: IndexPath, heightForHour: CGFloat) -> CGFloat
    
    func getHeightForHour() -> CGFloat
    func getPadding() -> CGFloat
}

class ScheduleLayoutAttributes: UICollectionViewLayoutAttributes {
    
    // 1. Custom attribute
    var color: UIColor = UIColor(r: 73, g: 144, b: 226)
    
    // 2. Override copyWithZone to conform to NSCopying protocol
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! ScheduleLayoutAttributes
        copy.color = color
        return copy
    }
    
    // 3. Override isEqual
    override func isEqual(_ object: Any?) -> Bool {
        if let attributtes = object as? ScheduleLayoutAttributes {
            if attributtes.color == color {
                return super.isEqual(object)
            }
        }
        return false
    }
}


class ScheduleLayout: UICollectionViewLayout {
    //1. Pinterest Layout Delegate
    var delegate: ScheduleLayoutDelegate!
    
    //2. Configurable properties
    var cellPadding: CGFloat {
        get {
            return delegate.getPadding()
        }
    }
    var contentHeightForHour: CGFloat {
        get {
            return delegate.getHeightForHour()
        }
    }
    
    //3. Array to keep a cache of attributes.
    private var cache = [UICollectionViewLayoutAttributes]()
    
    //4. Content height and size
    private var contentHeight: CGFloat = 0.0
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return collectionView!.bounds.width - (insets.left + insets.right)
    }
    
    //5. Colors to be used in cells
    private var colors: [UIColor] = {
        let paleTeal = UIColor(r: 149, g: 207, b: 175)
        let coral = UIColor(r: 242, g: 110, b: 103)
        let marigold = UIColor(r: 255, g: 193, b: 7)
        let oceanBlue = UIColor(r: 73, g: 144, b: 226)
        return [paleTeal, coral, marigold, oceanBlue]
    }()
    
    override class var layoutAttributesClass: AnyClass {
        return ScheduleLayoutAttributes.self
    }
    
    override func prepare() {
        //1. Only calculate once
        if cache.isEmpty {
            
            // 2. Iterates through the list of items in the first section
            for item in 0 ..< collectionView!.numberOfItems(inSection: 0) {
                
                let indexPath = IndexPath(item: item, section: 0)

                // 3. Asks the delegate for the xOffset, yOffset, height, and width of the cell and calculates the cell frame.
                let width = delegate.collectionView(collectionView: collectionView!, widthForCellAtIndexPath: indexPath, width: contentWidth) - cellPadding
                let height = delegate.collectionView(collectionView: collectionView!, heightForCellAtIndexPath: indexPath, heightForHour: contentHeightForHour) - cellPadding
                let xOffset = delegate.collectionView(collectionView: collectionView!, xOffsetForCellAtIndexPath: indexPath, width: contentWidth)
                let yOffset = delegate.collectionView(collectionView: collectionView!, yOffsetForCellAtIndexPath: indexPath, heightForHour: contentHeightForHour)
                
                let frame = CGRect(x: xOffset, y: yOffset, width: width, height: height)
                                
                // 4. Creates an UICollectionViewLayoutItem with the frame and add it to the cache
                let attributes = ScheduleLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                attributes.color = colors[item % colors.count]
                cache.append(attributes)
                
                // 5. Updates the collection view content height
                contentHeight = max(contentHeight, frame.maxY)
            }
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        if cache.isEmpty {
            self.prepare()
        }
        
        // Loop through the cache and look for items in the rect
        for attributes  in cache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if cache.isEmpty {
            self.prepare()
        }
        
        return cache.first { $0.indexPath == indexPath }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        
        cache = []
        contentHeight = 0
    }
}
