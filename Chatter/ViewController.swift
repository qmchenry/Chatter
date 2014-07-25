//
//  ViewController.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/17/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa
import ChatterLib

class ViewController: NSViewController {
    
    @IBOutlet weak var graphView: SPAudioGraphView!
    @IBOutlet weak var sidebarView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
                                    
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
                                    
    }


}

