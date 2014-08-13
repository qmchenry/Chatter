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
    case lessRandom = "Like both but not random"
    case oneByOne = "Jump only one frame at a time"
    case oneByOneLookAhead = "Look before you leap, jump one frame at a time"
    
    public static let allValues = [FirstSetUpDown, BothSetsUpDown, CurrentValue, both, Count, lessRandom, oneByOne, oneByOneLookAhead]
}

@objc public class FrameAnimation: NSObject {
    
    public var firstFrame: Int = 13 //elsa
    public var frameSets: [[Int]] = [[14,15,16,17],[18,19,20]] //elsa
    public var currentFrameSetIndex = 0
    public var filenameBase = "el_home_region00_" //elsa
    public var filenameExtension = ".png"
    public var digits = 4
    var currentFrameIndex = 0
    public var frames:[Int] = []   // designed frames
    
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
                    frames.append(firstFrame)
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
                    frames.append(frameSets[currentFrameSetIndex][index])
                }
            } // case .FirstSetUpDown
            
        case .BothSetsUpDown:
            frames.removeAll(keepCapacity: true)
            var up = true
            var WhichSet = false //false for first set, true for second set
            var index = 0
            for value in normalized {
                if (value < 0.1) {
                    frames.append(firstFrame)
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
                    frames.append(frameSets[currentFrameSetIndex][index])
                }
            } // case .BothSetsUpDown
            
        case .CurrentValue:
            frames.removeAll(keepCapacity: true)
            var tempFrames = [firstFrame]
            tempFrames += frameSets[0] //[13,14,15,16,17]
            for value in normalized {
                let index = Int(value*Float(tempFrames.count-1))
                frames.append(tempFrames[index])
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
                frames.append(tempFrames[index])
                
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
                frames.append(tempFrames[index])
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
                frames.append(tempFrames[index])
            // a strategy trying to be less random than .both
            // but it ends up only using the second set of frames hmmm
            }// case .lessRandom
            
        case .oneByOne:
            // only uses first frameset and never changes index by more than 1 at a time
            frames.removeAll(keepCapacity: true)
            var whichSet = 0
            var currentIndex = 0
            var tempFrames = [firstFrame] + frameSets[whichSet]
            let count = tempFrames.count
            for value in normalized {
                let desiredIndex = Int(value*Float(count-1))
                var deltaIndex = desiredIndex - currentIndex;
                if abs(deltaIndex) > 1 {
                    deltaIndex = deltaIndex / abs(deltaIndex)
                }
                println("oneByOne current=\(currentIndex) desired=\(desiredIndex) delta=\(deltaIndex)")
                currentIndex += deltaIndex
                frames.append(tempFrames[currentIndex])
            }// case .oneByOne

        case .oneByOneLookAhead:
            // only uses first frameset and never changes index by more than 1 at a time
            // and looks frameSet.count-ish steps ahead to see if it needs to start closing ahead of time
            frames.removeAll(keepCapacity: true)
            let closedThreshold = 0.15
            var whichSet = 0
            var currentIndex:Int = 0
            var tempFrames = [firstFrame] + frameSets[whichSet]
            let count = tempFrames.count
            var deltaIndex = 0
            for (var i=0; i<normalized.count; i++) {
                if i == normalized.count - 1 {
                    deltaIndex = 0
                    currentIndex = 0
                } else if (normalized.count - i < currentIndex + 1) {
                    deltaIndex = -1
                    println("oneByOne current=\(currentIndex)  --- lookahead end")
                } else {
                    let value = normalized[i]
                    if currentIndex > 0 {
                        for (var step=0; step<currentIndex; step++) {
                            let index = step + i
                            if Float(normalized[index]) < Float(closedThreshold) {
                                // found a case where we need to slide down to mouth closed
                                for (var j=0; j<step; j++) {
                                    currentIndex--
                                    frames.append(tempFrames[currentIndex])
                                    i++
                                    println("oneByOne current=\(currentIndex)  --- lookahead")
                                }
                                continue
                            }
                        }
                        
                    }
                    let desiredIndex = Int(value*Float(count-1))
                    deltaIndex = desiredIndex - currentIndex;
                    if abs(deltaIndex) > 1 {
                        deltaIndex = deltaIndex / abs(deltaIndex)
                    }
                    println("oneByOne current=\(currentIndex) desired=\(desiredIndex) delta=\(deltaIndex)")
                }
                currentIndex += deltaIndex
                frames.append(tempFrames[currentIndex])
            }// case .oneByOneLookAhead

        } // switch
        println("frames = \(frames)")
    }
    
    //functions to shorten sequence in printSequence
    
    public func shortenSequences() -> [String] {
        var seq:[String] = []
        var inARow = 1 //counts duplicates
        
        for (var i = 0; i < frames.count-1; i++) {
            if frames[i+1] == frames[i]+1 {
                inARow++
                if i == frames.count-2 {
                    if inARow > 2 {
                        seq.append(String(frames[i-inARow+1]) + "-" + String(frames[i+1]))
                        inARow = 1
                    }
                    else if inARow == 2 {
                        seq.append(String(frames[i]))
                        seq.append(String(frames[i+1]))
                        inARow = 1
                    }
                    else {
                        inARow = 1
                        seq.append(String(frames[i]))
                        if i == frames.count-2 {
                            seq.append(String(frames[i+1]))
                        }
                    }
                    
                }
            }
            else {
                if inARow > 2 {
                    seq.append(String(frames[i-inARow+1]) + "-" + String(frames[i]))
                    inARow = 1
                    if i == frames.count-2 {
                        seq.append(String(frames[i+1]))
                    }
                }
                else if inARow == 2 {
                    seq.append(String(frames[i-1]))
                    seq.append(String(frames[i]))
                    if i == frames.count-2 {
                        seq.append(String(frames[i]))
                        seq.append(String(frames[i+1]))
                    }
                    inARow = 1
                }
                else {
                    inARow = 1
                    seq.append(String(frames[i]))
                    if i == frames.count-2 {
                        seq.append(String(frames[i+1]))
                    }
                }
            }
        }
        
        return seq
    }
    
    public func shortenDuplicates(var sequence:[String]) -> String {
        var seq = ""
        var count = 1 //counts duplicates
        
        for (var i = 1; i < sequence.count; i++) {
            if countElements(sequence[i-1]) > 2 {
                seq += sequence[i-1] + ","
                if i == sequence.count-1 {
                    if count > 1 {
                        seq += sequence[i] + "*" + String(count)
                        count = 1
                    }
                    else {
                        count = 1
                        seq += sequence[i]
                    }
                }
            }
            else if sequence[i] == sequence[i-1] {
                count++
                sequence.removeAtIndex(i--)
                if i == sequence.count-1 {
                    seq += sequence[i] + "*" + String(count)
                }
            }
            else {
                if count > 1 {
                    seq += sequence[i-1] + "*" + String(count) + ","
                    count = 1
                    if i == sequence.count-1 {
                        seq += sequence[i]
                    }
                }
                else {
                    count = 1
                    seq += sequence[i-1] + ","
                    if i == sequence.count-1 {
                        seq += sequence[i]
                    }
                }
            }
        }
        
        return seq
    }
    
    public func printSequence(var shortened : Bool = false) -> String {
        var seq = ""
        
        if (shortened == false) {
            for i in frames {
                seq += String(i) + ","
            }
        } else {
            println("frames = \(frames)")
            println("shortenSequences = \(shortenSequences())")
            println("shortenDuplicates = \(shortenDuplicates(shortenSequences()))")
            seq += shortenDuplicates(shortenSequences())
        }
        return seq
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
            filenames.append(filename(index))
        }
        return filenames
    }
    
    public func count() -> Int {
        return frameSets[currentFrameSetIndex].count
    }
    
    public func framesetFilename(index: Int) -> String {
        return filename(frameSets[currentFrameSetIndex][index%count()])
    }
    
    public override init() {
        
    }
    
    func normalize(data: Array<(time:Double, value:Float)>) -> [Float] {
        let max = data.sorted{$0.value > $1.value}[0].value
        let min:Float = Float(SPAssetReader.noiseFloor())
        let scale:Float = 1.0/(max-min)
        var normalized = [Float]()
        for (time,value) in data {
            normalized.append((value-min)*scale)
        }
        return normalized
    }

}
