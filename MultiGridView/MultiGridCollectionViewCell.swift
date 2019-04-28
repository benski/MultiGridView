//
//  MultiGridCollectionViewCell.swift
//  MultiGridView
//
//  Created by Ben Allison on 4/25/19.
//  Copyright © 2019 Ben Allison. All rights reserved.
//

import Foundation
import UIKit

protocol MultiGridCollectionViewCellDelegate : class {
    func onReuse(cell: MultiGridCollectionViewCell)
}

@objc class MultiGridCollectionViewCell : UICollectionViewCell {
    public weak var delegate: MultiGridCollectionViewCellDelegate?
    public let collectionView: UICollectionView
    public override init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        super.init(frame: frame)
        contentView.addSubview(collectionView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    func bind(parent: UICollectionViewDelegate & UICollectionViewDataSource & MultiGridCollectionViewCellDelegate) {
        delegate = parent
        collectionView.delegate = parent
        collectionView.dataSource = parent
        collectionView.reloadData()
        // TODO(benski) set content offset so we can keep our old position when scrolling
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        delegate?.onReuse(cell: self)
        delegate = nil
        collectionView.delegate = nil
        collectionView.dataSource = nil
        collectionView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
