//
//  SPAudioGraphView.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/24/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa
import ChatterLib

public class SPAudioGraphView: NSView {

    let frameRate = 24 // frames/sec
    
    var assetData: NSData?
    var dataPoints: Array<(time:Double, value:Double)> = []
    public var asset: AVURLAsset? {
        didSet {
            SPAssetReader.setNoiseFloor(-50)
            assetData = SPAssetReader.dataFromAsset(asset, downsampleFactor: 200)
            
            dataPoints.removeAll(keepCapacity: true)
            let maxFrame = Int(frameCount())
            let delta = Double(SPAssetReader.countOfAssetData(assetData)/maxFrame)
            let frames = Int(frameCount())
            var timeIndex = 0.0
            for (var i=0; i<frames; i++) {
                let index:Int = i * Int(Double(maxFrame) / frameCount())
                println("i:\(i)  index:\(index)  timeIndex:\(timeIndex)  ")
                dataPoints += (timeIndex, Double(SPAssetReader.floatFromAssetData(assetData, index: index)))
                timeIndex += assetDuration / frameCount()
            }
            println("dataPoints = \(dataPoints)")
            self.setNeedsDisplayInRect(self.frame)
        }
    }
    
    public var assetDuration: Double {
        var duration = 0.0
        if (asset) {
            duration = Double(asset!.duration.value) / Double(asset!.duration.timescale)
        }
            println("duration = \(duration)  a.d=\(asset!.duration.value)  a.t=\(asset!.duration.timescale)")
        return duration;
    }
    
    func frameCount() -> Double {
        return assetDuration * Double(frameRate)
    }
    
    init(frame: NSRect) {
        super.init(frame: frame)
        // Initialization code here.
    }
    
    func drawCircleAtPoint(point: NSPoint) {
        println("drawCircleAtPoint: \(point)")
        let radius = 5;
        let point = NSPoint(x: point.x - radius, y: point.y - radius)
        let size = NSSize(width: radius*2, height: radius*2)
        let rect = NSRect(origin: NSPointToCGPoint(point), size: NSSizeToCGSize(size))
        let bPath = NSBezierPath(ovalInRect: rect)
        let color = NSColor(red: 0.1, green: 0.1, blue: 0.8, alpha: 1.0)
        color.set()
        bPath.stroke()
        bPath.fill()
    }
    
    func drawGraph() {
        if (!assetData) {
            return
        }
        var bPath:NSBezierPath = NSBezierPath(rect: frame)
        let borderColor = NSColor(calibratedWhite: 0.4, alpha: 1.0)
        borderColor.set()
        bPath.lineWidth = 1.0
        bPath.stroke()
        bPath.moveToPoint(NSPoint(x: 0, y: frame.size.height/2))
        bPath.lineToPoint(NSPoint(x: frame.size.width, y: frame.size.height/2))
        bPath.stroke()
        
        // draw time hashes, one per frame
        var hPath:NSBezierPath = NSBezierPath()
        let hashColor = NSColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0)
        hashColor.set()
        let yHalf = Int(frame.size.height/2 + frame.origin.y)
        let hashCount: Double = frameCount()
        let hashDist: Double = Double(frame.size.width) / hashCount
        var xHash = 0.0
        let count = SPAssetReader.countOfAssetData(assetData)
        var x: Float = 0.0
        let xScale = Float(frame.size.width) / Float(count)
        let yScale = Float((frame.size.height-50.0)/100.0)

        for (var i=0; i<Int(hashCount); i++) {
            let hashHeight = (i % frameRate == 0 ? 20 : 6)
            hPath.moveToPoint(NSPoint(x:Int(xHash), y:yHalf+hashHeight))
            hPath.lineToPoint(NSPoint(x:Int(xHash), y:yHalf-hashHeight))
            hPath.stroke()
            let (timeIndex, dataValue) = dataPoints[i]
            let y = Float(dataValue) * yScale
            let point = NSPoint(x:Int(xHash), y:Int(y) + yHalf)
            drawCircleAtPoint(point)
            xHash += hashDist
        }
        
        let graphColor = NSColor(red: 0.4, green: 0.4, blue: 0.8, alpha: 1.0)
        graphColor.set()
        var gPath = NSBezierPath()
        var gbPath = NSBezierPath()
        gPath.lineWidth = 1.0
        gbPath.lineWidth = 1.0
        for (var i=0; i<count; i++) {
            let value = Float(SPAssetReader.floatFromAssetData(assetData, index: i)) - Float(SPAssetReader.noiseFloor())
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
        println("noiseFloor = \(SPAssetReader.noiseFloor())")
    }
    
    override public func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)
        println(dirtyRect)
        drawGraph()
    }
}
