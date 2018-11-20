//
//  MyViewController.swift
//  testNib
//
//  Created by Esko Jääskeläinen on 11/11/2018.
//  Copyright © 2018 Esko Jääskeläinen. All rights reserved.
//

import Cocoa

class MyViewController: NSViewController {
    
    @IBOutlet weak var textField: NSTextField!
    
    @IBAction func countButtonAction(_ sender: Any) {
        var count = textField.integerValue
        count += 1
        textField.integerValue = count
    }
}
