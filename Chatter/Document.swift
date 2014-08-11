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
import AppKit

enum PlaybackState {
    case idle, playing
}

struct Princess {
    var firstFrame: Int
    var frameSets: [[Int]]
    var filenameBase: String
}

class Document: NSDocument, NSOutlineViewDataSource, NSOutlineViewDelegate {
                            
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var graphView: SPAudioGraphView!
    @IBOutlet weak var sequenceLabel: NSTextFieldCell!
    @IBOutlet weak var whichPrincess: NSPopUpButton!
    @IBOutlet weak var whichStrategy: NSPopUpButton!
    @IBOutlet weak var whichSequence: NSButton!
    @IBOutlet weak var frameRate: NSTextField!
    var currentAsset: AVURLAsset?
    var player: AVAudioPlayer?
    @objc var frameAnimation = FrameAnimation()
    var state = PlaybackState.idle
    var strategy: FrameAnimationStrategy = .both {
        didSet {
            processFrames()
        }
    }
    
    var shortSequence : Bool = true {
        didSet {
            processFrames()
        }
    }
    
    var princess: Princess? {
        didSet {
            frameAnimation.firstFrame = princess!.firstFrame
            frameAnimation.frameSets = princess!.frameSets
            frameAnimation.filenameBase = princess!.filenameBase
            imageView!.image = NSImage(named: frameAnimation.filename(frameAnimation.firstFrame))
            processFrames()
        }
    }
    
    var setFrameRate : Int?{
        didSet {
            processFrames()
        }
    }
    
    let princesses = [
        "Elsa" : Princess(firstFrame: 13, frameSets: [[14,15,16,17],[18,19,20]], filenameBase: "el_home_region00_"),
        "Ariel" : Princess(firstFrame: 0, frameSets: [[14,15,16],[17,18,19]], filenameBase: "ar_home_region00_"),
        "Belle" : Princess(firstFrame: 13, frameSets: [[14,15,16,17],[18,19,20]], filenameBase: "be_home_region00_"),
        "Jasmine" : Princess(firstFrame: 0, frameSets: [[13,14,15],[16,17]], filenameBase: "ja_home_region00_"),
        "Merida" : Princess(firstFrame: 0, frameSets: [[14,15,16],[17,18,19]], filenameBase: "me_home_region00_"),
        "Rapunzel" : Princess(firstFrame: 0, frameSets: [[14,15,16],[17,18,19]], filenameBase: "ar_home_region00_")]

    var audioFiles = ["test_vo","dx_frzn_016-120_anna","dx_frzn_017-530_anna","dx_frzn_025-540_elsa","dx_frzn_017-520_elsa"]
    
    @IBAction func play(sender: AnyObject) {
        frameAnimation.reset()
        player!.currentTime = 0.0
        player?.play()
        state = .playing
    }
    
    func processFrames() {
        frameAnimation.buildFrames(graphView.dataPoints, withStrategy: .both)
        sequenceLabel!.stringValue = frameAnimation.printSequence(shortened : shortSequence)
        graphView.setFrameRate(frameRate.value() as Int)
    }
    
    func princessCallback(sender: NSMenuItem!) {
        princess = princesses[sender.title]
    }
    
    func setAssetFileURL(fileURL: NSURL) {
        currentAsset = AVURLAsset(URL: fileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        player!.prepareToPlay()
        
        graphView!.asset = currentAsset
        processFrames()
    }
    
    func strategyCallback(sender: NSMenuItem!) {
        strategy = FrameAnimationStrategy.fromRaw(sender.title)!
    }
    
    func sequenceCallback(sender : NSButton!) {
        shortSequence = (sender.state == NSOnState)
    }
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        
        whichPrincess.addItemsWithTitles([String](princesses.keys))
        for (var i = 0; i < 6; i++) {
            whichPrincess.itemAtIndex(i).enabled = true
            whichPrincess.itemAtIndex(i).target = self
            whichPrincess.itemAtIndex(i).action = Selector("princessCallback:")
        }
        
        for strategy in FrameAnimationStrategy.allValues {
            whichStrategy.addItemWithTitle(strategy.toRaw())
//            whichStrategy.itemWithTitle(strategy.toRaw()).enabled = true
        }
        
        for (var i = 0; i < 6; i++) {
            whichStrategy.itemAtIndex(i).enabled = true
            whichStrategy.itemAtIndex(i).target = self
            whichStrategy.itemAtIndex(i).action = Selector("strategyCallback:")
        }
        
        whichSequence.title = "short?"
        whichSequence.target = self
        whichSequence.action = Selector("sequenceCallback:")

        
        setAssetFileURL(NSBundle.mainBundle().URLForResource("dx_frzn_017-530_anna", withExtension: "wav"))
        imageView!.image = NSImage(named: frameAnimation.filename(frameAnimation.firstFrame))
        var timer = NSTimer.scheduledTimerWithTimeInterval(1.0/16.0, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
        
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
    
// Dragging and Dropping



// NSOutlineViewDataSource
    
    
    func outlineView(outlineView: NSOutlineView!, numberOfChildrenOfItem item: AnyObject!) -> Int {
        return audioFiles.count
//        return !item ? 1 : audioFiles.count
    }
    
    func outlineView(outlineView: NSOutlineView!, child index: Int, ofItem item: AnyObject!) -> AnyObject! {
        return audioFiles[index]
//        return !item ? "Audio files" : audioFiles[index]
    }
    
    func outlineView(outlineView: NSOutlineView!, isItemExpandable item: AnyObject!) -> Bool {
        return false
    }
    
    

// NSOutlineViewDelegate

    func outlineView(outlineView: NSOutlineView!, dataCellForTableColumn tableColumn: NSTableColumn!, item: AnyObject!) -> NSCell! {
        println("item = \(item)")
        let text = item as String!
        return NSCell(textCell: text)
    }
    
    func outlineView(outlineView: NSOutlineView!, shouldShowOutlineCellForItem item: AnyObject!) -> Bool  {
        return true
    }
    
    func outlineView(outlineView: NSOutlineView!, viewForTableColumn tableColumn: NSTableColumn!, item: AnyObject!) -> NSView! {
        var result = outlineView.makeViewWithIdentifier("DataCell", owner: self) as NSTableCellView
        let string = item as String
        result.textField.stringValue = string
        return result
    }

    func outlineViewSelectionDidChange(notification: NSNotification!) {
        println("didChange \(notification)")
        let outlineView = notification!.object as NSOutlineView
        let selectedRow = outlineView.selectedRow
        setAssetFileURL(NSBundle.mainBundle().URLForResource(audioFiles[selectedRow], withExtension: "wav"))
    }
    
// NSDocument
    
    
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
    
    override init() {
        super.init()
    }

}

