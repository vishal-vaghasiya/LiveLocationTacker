//
//  UITableView+Extension.swift
//
//

import UIKit
extension UITableView {
    
    func dequeueReusableCell<T:UITableViewCell>(withType type:T.Type,indexPath:IndexPath? = nil) -> T {
        if let idx = indexPath {
            let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self), for: idx) as! T
            return cell
        }
        else {
            let cell = self.dequeueReusableCell(withIdentifier: String(describing: T.self)) as! T
            return cell
        }
    }
    
    func dequeueReusableHeaderFooterView<T:UIView>(withType type:T.Type) -> T {
        let identifier = String(describing: T.self)
        let cell = self.dequeueReusableHeaderFooterView(withIdentifier: identifier) as! T
        return cell
    }
    
    func register<T:UITableViewCell>(of type:T.Type) {
        let identifier = String(describing: T.self)
        self.register(UINib(nibName: identifier, bundle: Bundle.main), forCellReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterView<T:UIView>(of type:T.Type) {
        let identifier = String(describing: T.self)
        self.register(UINib(nibName: identifier, bundle: Bundle.main), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func registerHeaderFooterClass<T:UIView>(of type:T.Type) {
        let identifier = String(describing: T.self)
        self.register(type, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func scrollToBottom(animated: Bool = true) {
        let sections = self.numberOfSections
        let rows = self.numberOfRows(inSection: sections - 1)
        if (rows > 0){
            self.scrollToRow(at: IndexPath(row: rows - 1, section: sections - 1), at: .bottom, animated: animated)
        }
    }
}

open class SelfSizedTableView: UITableView {
    
    override open var contentSize: CGSize {
        didSet { // basically the contentSize gets changed each time a cell is added
            // --> the intrinsicContentSize gets also changed leading to smooth size update
            if oldValue != contentSize {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
}

extension UITableViewCell {
    
    var parentTableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}

extension UICollectionViewCell {
    
    var parentCollectionView: UICollectionView? {
        return parentView(of: UICollectionView.self)
    }
}

//MARK: - GetparentView From View.

extension UIView {
    func parentView<T: UIView>(of type: T.Type) -> T? {
        guard let view = superview else {
            return nil
        }
        return (view as? T) ?? view.parentView(of: T.self)
    }
}

extension UITableViewCell {
    var tableView: UITableView? {
        return parentView(of: UITableView.self)
    }
}
