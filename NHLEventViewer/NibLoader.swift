//
//  NibLoader.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 11/11/2018, with the help from internet
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Cocoa

import Foundation

public enum NibLoadingError: Error {
    case nibNotFound
    case topLevelObjectNotFound
    case multipleTopLevelObjectsFound
}

public extension NSView {
    class func view<T: NSView>(with owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        let className = String(describing: self)
        return try self.view(from: className, owner: owner, bundle: bundle)
    }
    
    class func view<T: NSView>(from nibName: String,
                               owner: AnyObject?,
                               bundle: Bundle = Bundle.main) throws -> T {
        var topLevelObjects: NSArray?

        guard Bundle.main.loadNibNamed(nibName, owner: owner, topLevelObjects: &topLevelObjects),
            let objects = topLevelObjects else {
                throw NibLoadingError.nibNotFound
        }
        
        let views = objects.filter { object in object is NSView }
        
        if views.count > 1 {
            throw NibLoadingError.multipleTopLevelObjectsFound
        }
        
        guard let view = views.first as? T else {
            throw NibLoadingError.topLevelObjectNotFound
        }
        return view
    }
}

