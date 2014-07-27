//
//  Document.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/25/14.
//  Copyright (c) 2014 Small Planet. All rights reserved.
//

import Cocoa
import Foundation
import CoreMedia
import ChatterLib

enum PlaybackState {
    case idle, playing
}

class Document: NSDocument {
                            
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var graphView: SPAudioGraphView!
    var currentAsset: AVURLAsset?
    var player: AVPlayer?
    var frameAnimation = FrameAnimation()
    var state = PlaybackState.idle
    
    @IBAction func play(sender: AnyObject) {
        frameAnimation.reset()
        player?.seekToTime(CMTimeMake(0,currentAsset!.duration.timescale))
        player?.play()
        state = .playing
    }
    
    func setAssetFileURL(fileURL: NSURL) {
        currentAsset = AVURLAsset(URL: fileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        player = AVPlayer(playerItem: AVPlayerItem(asset: currentAsset))
        graphView!.asset = currentAsset
        frameAnimation.buildFrames(graphView.dataPoints, withStrategy:.FirstSetUpDown)
    }
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
                                    
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
        
        let fileURL = NSBundle.mainBundle().URLForResource("test_vo", withExtension: "wav")
        setAssetFileURL(fileURL)
        imageView!.image = NSImage(named: frameAnimation.filename(frameAnimation.firstFrame))
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0/24.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)

    }
    
    func update() {
        if (state == .playing) {
            let frameName = frameAnimation.nextFrame()
            println("frameName = \(frameName)")
            imageView!.image = NSImage(named: frameName)
            if (!frameAnimation.hasNextFrame()) {
                state = .idle
            }
        }
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override var windowNibName: String {
        // Returns the nib file name of the document
        // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this property and override -makeWindowControllers instead.
        return "Document"
    }

    override func dataOfType(typeName: String?, error outError: NSErrorPointer) -> NSData? {
        // Insert code here to write your document to data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning nil.
        // You can also choose to override fileWrapperOfType:error:, writeToURL:ofType:error:, or writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
        outError.memory = NSError.errorWithDomain(NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return nil
    }

    override func readFromData(data: NSData?, ofType typeName: String?, error outError: NSErrorPointer) -> Bool {
        // Insert code here to read your document from the given data of the specified type. If outError != nil, ensure that you create and set an appropriate error when returning false.
        // You can also choose to override readFromFileWrapper:ofType:error: or readFromURL:ofType:error: instead.
        // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
        outError.memory = NSError.errorWithDomain(NSOSStatusErrorDomain, code: unimpErr, userInfo: nil)
        return false
    }
    
    init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

}

