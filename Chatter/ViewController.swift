//
//  ViewController.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/17/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var sidebarView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.addSubview(SPAssetGraphView(frame: view.frame))
        // Do any additional setup after loading the view.
                                    
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
                                    
    }


}

