//
//  MultiGridView.swift
//  MultiGridView
//
//  Created by Ben Allison on 4/25/19.
//  Copyright © 2019 Ben Allison. All rights reserved.
//

import Foundation
import UIKit

public protocol MultiGridViewDataSource : class {
    func numberOfSections(multiGridView: MultiGridView) -> Int
    func numberOfItems(multiGridView: MultiGridView, section: Int) -> Int
    func cell(multiGridView: MultiGridView, indexPath: IndexPath) -> UICollectionViewCell
    func direction(multiGridView: MultiGridView, section: Int) -> UICollectionView.ScrollDirection
    
    // return the number of columns for a vertical Grid View (or number of rows for horizontal Grid View)
    func columns(multiGridView: MultiGridView, section: Int) -> Int
    
    // return the height of a horizontal section in a vertical Grid View (or vice-versa)
    func height(multiGridView: MultiGridView, section: Int) -> CGFloat
    
    // return a cell height given a width. called only for vertical sections
    func cellHeight(multiGridView: MultiGridView, indexPath: IndexPath, width: CGFloat) -> CGFloat
    
    // return a cell width given a height. called only for horizontal sections
    func cellWidth(multiGridView: MultiGridView, indexPath: IndexPath, height: CGFloat) -> CGFloat
    
    func headerHeight(multiGridView: MultiGridView, section: Int, width: CGFloat) -> CGFloat
    func header(multiGridView: MultiGridView, section: Int) -> UICollectionReusableView
    
    func footerHeight(multiGridView: MultiGridView, section: Int, width: CGFloat) -> CGFloat
    func footer(multiGridView: MultiGridView, section: Int) -> UICollectionReusableView
    
    func insets(multiGridView: MultiGridView, section: Int) -> UIEdgeInsets
}

public class MultiGridView : UIView {
    
    struct HorizontalSection {
        let collectionView: UICollectionView
        let section: Int
    }
    
    struct ReuseIdentifier {
        static let horizontalCell = "bja9419ajb"
        let cell: UICollectionViewCell.Type
        let identifier: String
    }
    public weak var dataSource: MultiGridViewDataSource? {
        didSet {
            collectionView.reloadData()
        }
    }
    private let collectionView: UICollectionView
    private let mainLayout: UICollectionViewFlowLayout
    
    var reuseIdentifiers = [ReuseIdentifier]()
    var horizontalSections = [HorizontalSection]()
    
    public override init(frame: CGRect) {
        mainLayout = UICollectionViewFlowLayout()
        mainLayout.scrollDirection = .vertical
        collectionView = UICollectionView(frame: frame,
                                          collectionViewLayout: mainLayout)
        collectionView.backgroundColor = .clear
        collectionView.register(MultiGridCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier.horizontalCell)
        super.init(frame: frame)
        collectionView.dataSource = self
        collectionView.delegate = self
        addSubview(collectionView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = self.bounds
    }
}

extension MultiGridView {
    func section(collectionView: UICollectionView) -> Int? {
        guard let horizontalSection = horizontalSections.first(where: { (horizontalSection) -> Bool in
            return horizontalSection.collectionView === collectionView
        }) else { return nil }
        return horizontalSection.section
    }
    
    func collectionView(section: Int) -> UICollectionView? {
        guard let horizontalSection = horizontalSections.first(where: { (horizontalSection) -> Bool in
            return horizontalSection.section == section
        }) else { return nil }
        return horizontalSection.collectionView
    }
    
    var collectionViews: [UICollectionView] {
        return horizontalSections.compactMap({ (horizontalSection) -> UICollectionView? in
            return horizontalSection.collectionView
        })
    }
}

extension MultiGridView {
    public func register(_ cellClass: UICollectionViewCell.Type, forCellWithReuseIdentifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: forCellWithReuseIdentifier)
        reuseIdentifiers.append(ReuseIdentifier(cell: cellClass, identifier: forCellWithReuseIdentifier))
    }
    
    public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
        if let collectionView = self.collectionView(section: indexPath.section) {
            let virtualIndexPath = IndexPath(item: indexPath.item, section: 0)
            return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: virtualIndexPath)
        }

        return self.collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func registerHeader(_ viewClass: AnyClass?, withReuseIdentifier identifier: String) {
        collectionView.register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    public func registerFooter(_ viewClass: AnyClass?, withReuseIdentifier identifier: String) {
        collectionView.register(viewClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    public func dequeueHeader(withReuseIdentifier identifier: String, for section: Int) -> UICollectionReusableView {
        let indexPath = IndexPath(item: 0, section: section)
        return self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath)
    }
    
    public func dequeueFooter(withReuseIdentifier identifier: String, for section: Int) -> UICollectionReusableView {
        let indexPath = IndexPath(item: 0, section: section)
        return self.collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath)
    }
}

extension MultiGridView : UICollectionViewDataSource {

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else { return 0 }
        if collectionView == self.collectionView {
            let direction = dataSource.direction(multiGridView: self, section: section)
            if direction == mainLayout.scrollDirection {
                return dataSource.numberOfItems(multiGridView: self, section: section)
            } else {
                return 1
            }
        } else {
            guard let virtualSection = self.section(collectionView: collectionView) else { return 0}
            return dataSource.numberOfItems(multiGridView: self, section: virtualSection)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else { return UICollectionViewCell() }
        if collectionView == self.collectionView {
            let direction = dataSource.direction(multiGridView: self, section: indexPath.section)
            if direction == .vertical {
                return dataSource.cell(multiGridView: self, indexPath: indexPath)
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReuseIdentifier.horizontalCell, for: indexPath) as! MultiGridCollectionViewCell
                for reuseIdentifier in self.reuseIdentifiers {
                    cell.collectionView.register(reuseIdentifier.cell, forCellWithReuseIdentifier: reuseIdentifier.identifier)
                }
                horizontalSections.append(HorizontalSection(collectionView: cell.collectionView, section: indexPath.section))
                cell.bind(parent: self)
                return cell                
            }
        } else {
            guard let virtualSection = self.section(collectionView: collectionView) else { return UICollectionViewCell() }
            let virtualIndexPath = IndexPath(item: indexPath.item, section: virtualSection)
            return dataSource.cell(multiGridView: self, indexPath: virtualIndexPath)
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let dataSource = dataSource else { return 0 }
        guard collectionView == self.collectionView else { return 1 }
        return dataSource.numberOfSections(multiGridView: self)
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let dataSource = dataSource else { return UICollectionReusableView() }
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return dataSource.header(multiGridView: self, section: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            return dataSource.footer(multiGridView: self, section: indexPath.section)
        default:
            return UICollectionReusableView()
        }
        
    }
}

extension MultiGridView : MultiGridCollectionViewCellDelegate {
    func onReuse(cell: MultiGridCollectionViewCell) {
            horizontalSections.removeAll { (horizontalSection) -> Bool in
                return horizontalSection.collectionView == cell.collectionView
            }
    }
}

extension MultiGridView : UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let dataSource = dataSource else { return .zero }
        if collectionView == self.collectionView {
            let direction = dataSource.direction(multiGridView: self, section: indexPath.section)
            if direction == .vertical {
                let columns = CGFloat(dataSource.columns(multiGridView: self, section: indexPath.section))
                let insets: UIEdgeInsets = dataSource.insets(multiGridView: self, section: indexPath.section)
                let spacing = CGFloat(4) // TODO(benski)
                let width = floor(self.bounds.width - insets.left - insets.right - (columns - 1) * spacing) / columns
                let height = dataSource.cellHeight(multiGridView: self, indexPath: indexPath, width: width)
                return CGSize(width: width, height: height)
            } else {
                let height = dataSource.height(multiGridView: self, section: indexPath.section)
                return CGSize(width: self.bounds.width, height: height)
            }
        } else {
            // benski> for now we assume horizontal scrollers are a single row
            guard let virtualSection = self.section(collectionView: collectionView) else { return .zero }
            let insets: UIEdgeInsets = dataSource.insets(multiGridView: self, section: virtualSection)
            let virtualIndexPath = IndexPath(item: indexPath.item, section: virtualSection)
            let height = dataSource.height(multiGridView: self, section: virtualSection) - insets.top - insets.bottom
            let width = dataSource.cellWidth(multiGridView: self, indexPath: virtualIndexPath, height: height)
            return CGSize(width: width, height: height)
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let dataSource = dataSource else { return .zero }
        let virtualSection = self.section(collectionView: collectionView) ?? section
        return dataSource.insets(multiGridView: self, section: virtualSection)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4 // TODO(benski)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4 // TODO(benski)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard collectionView == self.collectionView else { return .zero }
        guard let dataSource = dataSource else { return .zero }
        let height = dataSource.headerHeight(multiGridView: self, section: section, width: self.bounds.width)
        return CGSize(width: self.bounds.width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard collectionView == self.collectionView else { return .zero }
        guard let dataSource = dataSource else { return .zero }
        let height = dataSource.footerHeight(multiGridView: self, section: section, width: self.bounds.width)
        return CGSize(width: self.bounds.width, height: height)
    }
}
