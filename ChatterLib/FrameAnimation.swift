//
//  FrameAnimation.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/26/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

import Cocoa

public class FrameAnimation {
    public var firstFrame: Int = 0
    public var frameSets: [[Int]] = [[13,13,13,14,15,16,17,16,15,14,13,13,13,18,19,20,19,18],[14,15,16,17,16,15,14],[18,19,20,19,18]]
    public var currentFrameSetIndex = 0
    public var filenameBase = "el_home_region00_"
    public var filenameExtension = ".png"
    public var digits = 4
    
    public init() {
        
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
}
