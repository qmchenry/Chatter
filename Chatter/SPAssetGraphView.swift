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

    func drawGraph() {
        var bPath:NSBezierPath = NSBezierPath(rect: frame)
        let borderColor = NSColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        borderColor.set()
        bPath.lineWidth = 1.0
        bPath.stroke()
        bPath.moveToPoint(NSPoint(x: 0, y: frame.size.height/2))
        bPath.lineToPoint(NSPoint(x: frame.size.width, y: frame.size.height/2))
        bPath.stroke()
        
        let graphColor = NSColor(calibratedWhite: 0.4, alpha: 1.0)
        graphColor.set()
        let count = SPAudioReader.countOfAssetData(assetData)
        var x: Float = 0.0
        let xScale = Float(frame.size.width) / Float(count)
        let yScale = Float((frame.size.height-50)/100)
        let yHalf = Int(frame.size.height/2 + frame.origin.y)
        var gPath = NSBezierPath()
        var gbPath = NSBezierPath()
        gPath.lineWidth = 1.0
        gbPath.lineWidth = 1.0
        for (var i=0; i<count; i++) {
            let value = Float(SPAudioReader.floatFromAssetData(assetData, index: i) + 50.0)
            let point = NSPoint(x: Int(x), y: Int(value*yScale) + yHalf )
            let pointB = NSPoint(x: Int(x), y: Int(-value*yScale) + yHalf )
            if (i==0) {
                gPath.moveToPoint(point)
                gbPath.moveToPoint(pointB)
            } else {
                gPath.lineToPoint(point)
                gbPath.lineToPoint(pointB)
            }
            gPath.stroke()
            gbPath.stroke()
            //            println("p\(i):\(point)")
            x += xScale
        }
    }
    
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        println(dirtyRect)
        drawGraph()
    }
    
}
