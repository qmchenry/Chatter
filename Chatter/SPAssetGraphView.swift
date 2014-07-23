//
//  SPAssetGraphView.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/23/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa

class SPAssetGraphView: NSView {

    var assetData: NSData? {
    didSet {
        self.setNeedsDisplayInRect(self.frame)
    }
    }
    
    init(frame: NSRect) {
        super.init(frame: frame)
        // Initialization code here.
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        println(dirtyRect)
        var bPath:NSBezierPath = NSBezierPath(rect: dirtyRect)
        println(bPath)
        let fillColor = NSColor(red: 0.5, green: 0.0, blue: 0.5, alpha: 1.0)
        fillColor.set()
        bPath.fill()
        
        let borderColor = NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
        borderColor.set()
        bPath.lineWidth = 12.0
        bPath.stroke()
        
        let circleFillColor = NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)
        var circleRect = NSMakeRect(dirtyRect.size.width/4, dirtyRect.size.height/4, dirtyRect.size.width/2, dirtyRect.size.height/2)
        var cPath: NSBezierPath = NSBezierPath(ovalInRect: circleRect)
        circleFillColor.set()
        cPath.fill()    }
    
}
