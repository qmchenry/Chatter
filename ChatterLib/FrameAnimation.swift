//
//  FrameAnimation.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/26/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

import Cocoa

public enum FrameAnimationStrategy: String {
    case FirstSetUpDown = "First set, up/down"
}

public class FrameAnimation {
    public var firstFrame: Int = 13
    public var frameSets: [[Int]] = [[14,15,16,17],[18,19,20]]
    public var currentFrameSetIndex = 0
    public var filenameBase = "el_home_region00_"
    public var filenameExtension = ".png"
    public var digits = 4
    var currentFrameIndex = 0
    public var frames: [Int] = []   // designed frames
    
    public func buildFrames(data: Array<(time:Double, value:Float)>, withStrategy strategy:FrameAnimationStrategy = .FirstSetUpDown) {
        frames.removeAll(keepCapacity: true)
        var up = true
        var index = 0
        for (time, value) in data {
            if (value < -40) {
                frames += firstFrame
            } else {
                if (up) {
                    if (index+1 >= frameSets[currentFrameSetIndex].count) {
                        up = false
                        index--
                    } else {
                        index++
                    }
                } else {
                    if (index-1 <= 0) {
                        up = true
                        index++
                    } else {
                        index--
                    }
                }
                frames += frameSets[currentFrameSetIndex][index]
            }
        }
        println("frames = \(frames)")
    }
    
    public func reset() {
        currentFrameIndex = 0
    }
    
    public func nextFrame() -> String? {
        if (currentFrameIndex >= frames.count) {
            return nil
        }
        return filename(frames[currentFrameIndex++])
    }
    
    public func hasNextFrame() -> Bool {
        return currentFrameIndex < frames.count
    }
    
    public func filename(frameIndex: Int) -> String {
        let formatString = String(format:"%%0%dd", digits)
        let frameNumber = String(format: formatString, frameIndex)
        return filenameBase + frameNumber + filenameExtension
    }
    
    public func filenames(frameSetIndex: Int) -> [String] {
        var filenames:[String] = []
        for index in frameSets[frameSetIndex] {
            filenames += filename(index)
        }
        return filenames
    }
    
    public func count() -> Int {
        return frameSets[currentFrameSetIndex].count
    }
    
    public func framesetFilename(index: Int) -> String {
        return filename(frameSets[currentFrameSetIndex][index%count()])
    }
    
    public init() {
        
    }

}
