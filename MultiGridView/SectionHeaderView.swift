//
//  SectionHeaderView.swift
//  MultiGridView
//
//  Created by Ben Allison on 4/26/19.
//  Copyright © 2019 Ben Allison. All rights reserved.
//

import Foundation
import UIKit

class SectionTitleView: UICollectionReusableView {
    let titleLabel: UILabel
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    override init(frame: CGRect) {
        titleLabel = UILabel(frame: .zero)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        titleLabel.textColor = UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1)
        super.init(frame: frame)
        addSubview(titleLabel)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = bounds.insetBy(dx: 16, dy: 16)
    }
        
}
