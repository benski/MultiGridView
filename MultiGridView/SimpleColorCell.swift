//
//  SimpleColorCell.swift
//  MultiGridView
//
//  Created by Ben Allison on 4/26/19.
//  Copyright © 2019 Ben Allison. All rights reserved.
//

import Foundation
import UIKit

class SimpleColorCell : UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
