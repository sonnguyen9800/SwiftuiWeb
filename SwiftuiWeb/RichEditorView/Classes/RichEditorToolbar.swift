//
//  RichEditorToolbar.swift
//
//  Created by Caesar Wirth on 4/2/15.
//  Updated/Modernized by C. Bess on 9/18/19.
//
//  Copyright (c) 2015 Caesar Wirth. All rights reserved.
//

import UIKit

/// RichEditorToolbarDelegate is a protocol for the RichEditorToolbar.
/// Used to receive actions that need extra work to perform (eg. display some UI)
@objc public protocol RichEditorToolbarDelegate: class {

    /// Called when the Text Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeTextColor(_ toolbar: RichEditorToolbar, sender: AnyObject)

    /// Called when the Background Color toolbar item is pressed.
    @objc optional func richEditorToolbarChangeBackgroundColor(_ toolbar: RichEditorToolbar, sender: AnyObject)

    /// Called when the Insert Image toolbar item is pressed.
    @objc optional func richEditorToolbarInsertImage(_ toolbar: RichEditorToolbar)

    /// Called when the Insert Link toolbar item is pressed.
    @objc optional func richEditorToolbarInsertLink(_ toolbar: RichEditorToolbar)
}

fileprivate func pinViewEdges(of childView: UIView, to parentView: UIView) {
    NSLayoutConstraint.activate([
        childView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
        childView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor),
        childView.topAnchor.constraint(equalTo: parentView.topAnchor),
        childView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor)
    ])
}

private let DefaultFont = UIFont.preferredFont(forTextStyle: .body)

/// RichEditorToolbar is UIView that contains the toolbar for actions that can be performed on a RichEditorView
@objcMembers open class RichEditorToolbar: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {

    /// The delegate to receive events that cannot be automatically completed
    open weak var delegate: RichEditorToolbarDelegate?

    /// A reference to the RichEditorView that it should be performing actions on
    open weak var editor: RichEditorView?

    /// The list of options to be displayed on the toolbar
    open var options: [RichEditorOption] = [] {
        didSet {
            updateToolbar()
        }
    }

    /// The tint color to apply to the toolbar background.
    open var barTintColor: UIColor? {
        get { return backgroundColor }
        set { backgroundColor = newValue }
    }
    
    /// The spacing between the option items
    open var itemMargin: CGFloat = 12 {
        didSet {
            collectionView.collectionViewLayout.invalidateLayout()
        }
    }

    private var collectionView: UICollectionView!
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }
    
    private func initViews() {
        autoresizingMask = .flexibleWidth

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = backgroundColor
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(ToolbarCell.self, forCellWithReuseIdentifier: "cell")
        
        let visualView = UIVisualEffectView(frame: bounds)
        visualView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        visualView.effect = UIBlurEffect(style: .regular)
        visualView.contentView.addSubview(collectionView)
        
        pinViewEdges(of: collectionView, to: visualView)

        addSubview(visualView)
    }
    
    
    private func updateToolbar() {
        collectionView.reloadData()
    }
    
    func stringWidth(_ text: String, withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }

    // MARK: - CollectionView
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let option = options[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ToolbarCell
        cell.option = option
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = options[indexPath.item]
        
        if let cell = collectionView.cellForItem(at: indexPath) {
            option.action(self, sender: cell.contentView)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return itemMargin
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let opt = options[indexPath.item]
        var width: CGFloat = 0
        if let image = opt.image {
            width = image.size.width
        } else {
            width = stringWidth(opt.title, withConstrainedHeight: bounds.height, font: DefaultFont)
        }
        return CGSize(width: width, height: bounds.height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: itemMargin, height: 1)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: itemMargin, height: 1)
    }
}


private class ToolbarCell: UICollectionViewCell {
    var option: RichEditorOption! {
        didSet {
            // remove the previous subview
            contentView.subviews.first?.removeFromSuperview()
            
            var subview: UIView!
            
            // build the subview for the cell
            if let image = option.image {
                let imageView = UIImageView(frame: .zero)
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                subview = imageView
            } else {
                let label = UILabel(frame: .zero)
                label.text = option.title
                label.font = DefaultFont
                label.textColor = tintColor
                subview = label
            }
            
            subview.translatesAutoresizingMaskIntoConstraints = false
            subview.sizeToFit()
            contentView.addSubview(subview)
            pinViewEdges(of: subview, to: contentView)
        }
    }
}
