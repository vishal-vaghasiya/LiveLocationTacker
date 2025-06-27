//
//  CollectionView+Extension.swift
//  Taala
//
//  Created by JDBTechs on 25/02/21.
//

import UIKit

extension UICollectionView {
    func dequeueReusableCell<T:UICollectionViewCell>(withType type:T.Type,indexPath:IndexPath) -> T {
        let cell = self.dequeueReusableCell(withReuseIdentifier: String(describing: T.self), for: indexPath) as! T
        return cell
    }
    
    func registerHeader<T:UICollectionReusableView>(withType type:T.Type) {
        let nibnameAndIdentifier = String(describing: T.self)
        self.register(UINib(nibName: nibnameAndIdentifier, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nibnameAndIdentifier)
    }
    
    func registerFooter<T:UICollectionReusableView>(withType type:T.Type) {
        let nibnameAndIdentifier = String(describing: T.self)
        self.register(UINib(nibName: nibnameAndIdentifier, bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: nibnameAndIdentifier)
    }
    
    func dequeueReusableHeaderView<T:UICollectionReusableView>(withType type:T.Type,indexPath:IndexPath) -> T {
        let nibnameAndIdentifier = String(describing: T.self)
        let headerView = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: nibnameAndIdentifier, for: indexPath) as! T
        return headerView
    }
    
    func dequeueReusableFooterView<T:UICollectionReusableView>(withType type:T.Type,indexPath:IndexPath) -> T {
        let nibnameAndIdentifier = String(describing: T.self)
        let footerView = self.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: nibnameAndIdentifier, for: indexPath) as! T
        return footerView
    }
    
    func register<T:UICollectionViewCell>(of type:T.Type) {
        let nibnameAndIdentifier = String(describing: T.self)
        self.register(UINib(nibName: nibnameAndIdentifier, bundle: Bundle.main), forCellWithReuseIdentifier: nibnameAndIdentifier)
    }
}

extension UICollectionView {
    
    func getCellWidth(_ items:CGFloat,_ inset:CGFloat) -> CGFloat {
        let totalwidth = self.frame.size.width - ((items + 1) * inset)
        let width = Int(totalwidth/items)
        return CGFloat(width)
    }
}

class SelfSizedUICollectionView : UICollectionView {
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return self.collectionViewLayout.collectionViewContentSize
    }
}
