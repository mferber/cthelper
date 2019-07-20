//
//  UIViewController+Containment.swift
//  Cthelper
//
//  Created by Matthias Ferber on 12/2/18.
//  Copyright © 2018 Matthias Ferber. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func mafAdopt(_ child: UIViewController, asSubviewOf parentView: UIView? = nil) {
        addChild(child)
        parentView?.addSubview(child.view)
        child.didMove(toParent: self)
        
        if let parentView = parentView {
            child.view.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
            child.view.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
            child.view.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
            child.view.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive = true
        }
    }
    
    public func mafDisown(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
}
