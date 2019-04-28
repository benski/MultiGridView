//
//  ViewController.swift
//  MultiGridView
//
//  Created by Ben Allison on 4/25/19.
//  Copyright © 2019 Ben Allison. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let gridView: MultiGridView
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        gridView = MultiGridView(frame: .zero)
        gridView.register(SimpleColorCell.self, forCellWithReuseIdentifier: "color")
        gridView.registerHeader(SectionTitleView.self, withReuseIdentifier: "header")
        gridView.backgroundColor = .clear
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        gridView.dataSource = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        gridView = MultiGridView(frame: .zero)
        gridView.register(SimpleColorCell.self, forCellWithReuseIdentifier: "color")
        gridView.registerHeader(SectionTitleView.self, withReuseIdentifier: "header")
        gridView.backgroundColor = .clear
        super.init(coder: aDecoder)
        gridView.dataSource = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1)
        view.addSubview(gridView)
        gridView.frame = view.bounds
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gridView.frame = view.bounds
    }

}

extension ViewController : MultiGridViewDataSource {
    func numberOfSections(multiGridView: MultiGridView) -> Int {
        return 5
    }
    
    func numberOfItems(multiGridView: MultiGridView, section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1: return 20
        case 2: return 10
        case 3: return 3
        case 4: return 24
        default: return 0
        }
    }
    
    func cell(multiGridView: MultiGridView, indexPath: IndexPath) -> UICollectionViewCell {
        let cell = multiGridView.dequeueReusableCell(withReuseIdentifier: "color", for: indexPath)
        switch indexPath.section {
        case 0: cell.contentView.backgroundColor = UIColor.red
        case 1: cell.contentView.backgroundColor = UIColor.blue
        case 2: cell.contentView.backgroundColor = UIColor.yellow
        case 3: cell.contentView.backgroundColor = UIColor.orange
        case 4: cell.contentView.backgroundColor = UIColor.purple
        default: break
        }
        return cell
    }
    
    func direction(multiGridView: MultiGridView, section: Int) -> UICollectionView.ScrollDirection {
        switch section {
        case 0: return .vertical
        case 1: return .horizontal
        case 2: return .horizontal
        case 3: return .horizontal
        case 4: return .vertical
        default: return .vertical
        }
    }
    
    func columns(multiGridView: MultiGridView, section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 2
        case 2: return 2
        case 3: return 2
        case 4: return 2
        default: return 0
        }
    }
    
    func height(multiGridView: MultiGridView, section: Int) -> CGFloat {
        switch section {
        
        case 1: return 88+16
        case 2: return 88+16
        case 3: return 156+8+33+16
        
        default: return 0
        }
    }
    
    func cellHeight(multiGridView: MultiGridView, indexPath: IndexPath, width: CGFloat) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 60
        case 1:
            return 88
        case 2:
            return 88
        case 3:
            return 156+8+33
        default:
            return width * 9.0 / 16.0
        }
    }
    
    func cellWidth(multiGridView: MultiGridView, indexPath: IndexPath, height: CGFloat) -> CGFloat {
        return 156
    }
    
    func headerHeight(multiGridView: MultiGridView, section: Int, width: CGFloat) -> CGFloat {
        return 16+22+16
    }
    
    func header(multiGridView: MultiGridView, section: Int) -> UICollectionReusableView {
        guard let headerView = gridView.dequeueHeader(withReuseIdentifier: "header", for: section) as? SectionTitleView else { return UICollectionReusableView() }
        
        headerView.title = "Section \(section)"
        return headerView
    }
    
    func footerHeight(multiGridView: MultiGridView, section: Int, width: CGFloat) -> CGFloat {
        return 0
    }
    
    func footer(multiGridView: MultiGridView, section: Int) -> UICollectionReusableView {
        return UICollectionReusableView()
    }
    
    func insets(multiGridView: MultiGridView, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }
}
