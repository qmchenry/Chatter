//
//  FrameAnimation.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/26/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

/* Strategy thoughts
Depending on the final framerate (if high enough), a perceptual trick of animating the frame one data point in advance might make the visual perception (slower) match better with audio perception. This would also allow a 0 first value that quickly ascends to have an active mouth position immediately
*/

import Cocoa

public enum FrameAnimationStrategy: String {
    case FirstSetUpDown = "First set, up/down"
    case BothSetsUpDown = "Both sets, up/down"
    case CurrentValue = "Based on current value"
    case both = "Both sets and current value"
    case Count = "Counts the number of times there's no sound"
    case lessRandom = "like both but not random"
}

@objc public class FrameAnimation: NSObject {
    
    public var firstFrame: Int = 13 //elsa
    public var frameSets: [[Int]] = [[14,15,16,17],[18,19,20]] //elsa
    public var currentFrameSetIndex = 0
    public var filenameBase = "el_home_region00_" //elsa
    public var filenameExtension = ".png"
    public var digits = 4
    var currentFrameIndex = 0
    public var frames: [Int] = []   // designed frames
    
    public func buildFrames(data: Array<(time:Double, value:Float)>, withStrategy strategy:FrameAnimationStrategy = .CurrentValue) {
        
        // normalize data
        let normalized = normalize(data)
        
        switch strategy {
            
        case .FirstSetUpDown:
            frames.removeAll(keepCapacity: true)
            var up = true
            var index = 0
            for value in normalized {
                if (value < 0.1) {
                    frames += firstFrame
                } else {
                    if (up) {
                        if (index+1 >= frameSets[currentFrameSetIndex].count) {
                            up = false
                        }
                    } else {
                        if (index-1 <= 0) {
                            up = true
                        }
                    }
                    index += up ? 1 : -1
                    frames += frameSets[currentFrameSetIndex][index]
                }
            } // case .FirstSetUpDown
            
        case .BothSetsUpDown:
            frames.removeAll(keepCapacity: true)
            var up = true
            var WhichSet = false //false for first set, true for second set
            var index = 0
            for value in normalized {
                if (value < 0.1) {
                    frames += firstFrame
                }
                else {
                    if (up) {
                        if (index+1 >= frameSets[currentFrameSetIndex].count) {
                            up = false
                            WhichSet = true
                        }
                    }
                    else {
                        if (index-1 <= 0) {
                            up = true
                            WhichSet = false
                        }
                    }
                    //index = WhichSet ? OtherFirstFrame : firstFrame
                    index += up ? 1 : -1
                    frames += frameSets[currentFrameSetIndex][index]
                }
            } // case .BothSetsUpDown
            
        case .CurrentValue:
            frames.removeAll(keepCapacity: true)
            var tempFrames = [firstFrame]
            tempFrames += frameSets[0] //[13,14,15,16,17]
            for value in normalized {
                let index = Int(value*Float(tempFrames.count-1))
                frames += tempFrames[index]
            }// case .CurrentValue
            
        case .both:
            frames.removeAll(keepCapacity: true)
            var tempFrames = [firstFrame] + frameSets[0] //[13,14,15,16,17]
            var whichSet = 0
            for value in normalized {
                if random() % 100 < 10 {
                    whichSet = 1 - whichSet
                    tempFrames = [firstFrame] + frameSets[whichSet] //[13,18,19,20]
                }
                let index = Int(value*Float(tempFrames.count-1))
                frames += tempFrames[index]
                
            }// case .both
            
        case .Count:
            frames.removeAll(keepCapacity: true)
            var tempFrames = [firstFrame] + frameSets[0] //[13,14,15,16,17]
            var whichSet = 0
            var count = 0 //counts the number of times there's no sound
            for value in normalized {
                if (value <= 0.1) {
                    count++
                }
                else if (count >= 4) {
                    whichSet = 1 - whichSet
                    tempFrames = [firstFrame] + frameSets[whichSet] //[13,18,19,20]
                }
                
                let index = Int(value*Float(tempFrames.count-1))
                frames += tempFrames[index]
            // a strategy attempting to switch sets based on the number of times there's no sound
            //... but ends up looking kind of crazy
            }// case .Count
            
        case .lessRandom:
            frames.removeAll(keepCapacity: true)
            var tempFrames = [firstFrame] + frameSets[0] //[13,14,15,16,17]
            var whichSet = 0
            var rand = 0
            for value in normalized {
                while rand <= 4 {
                    ++rand
                    if rand == 1 {
                        whichSet = 1 - whichSet
                        tempFrames = [firstFrame] + frameSets[whichSet] //[13,18,19,20]
                    }
                }
                let index = Int(value*Float(tempFrames.count-1))
                frames += tempFrames[index]
            // a strategy trying to be less random than .both
            // but it ends up only using the second set of frames hmmm
            }// case .lessRandom
            
        } // switch
        println("frames = \(frames)")
    }
    
    public func printSequence() -> String {
        var seq = "frames : ["
        for i in frames {
            seq += String(i) + ","
        }
        return seq + "]"
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
    
    func normalize(data: Array<(time:Double, value:Float)>) -> [Float] {
        let max = data.sorted{$0.value > $1.value}[0].value
        let min:Float = Float(SPAssetReader.noiseFloor())
        let scale:Float = 1.0/(max-min)
        var normalized = [Float]()
        for (time,value) in data {
            normalized += (value-min)*scale
        }
        return normalized
    }

}
