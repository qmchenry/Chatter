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

class Document: NSDocument, NSOutlineViewDataSource, NSOutlineViewDelegate {
                            
    @IBOutlet weak var imageView: NSImageView!
    @IBOutlet weak var graphView: SPAudioGraphView!
    @IBOutlet weak var sequenceLabel: NSTextFieldCell!
    @IBOutlet weak var whichPrincess: NSPopUpButton!
    @IBOutlet weak var whichStrategy: NSPopUpButton!
    var currentAsset: AVURLAsset?
    var player: AVAudioPlayer?
    @objc var frameAnimation = FrameAnimation()
    var state = PlaybackState.idle
    var audioFiles = ["test_vo","dx_frzn_016-120_anna","dx_frzn_017-530_anna","dx_frzn_025-540_elsa","dx_frzn_017-520_elsa"]
    
    
    @IBAction func play(sender: AnyObject) {
        frameAnimation.reset()
        player!.currentTime = 0.0
        player?.play()
        state = .playing
    }
    
    public func initGeneral() {
        imageView!.image = NSImage(named: frameAnimation.filename(frameAnimation.firstFrame))
        frameAnimation.buildFrames(graphView.dataPoints, withStrategy: .both)
        sequenceLabel!.stringValue = frameAnimation.printSequence()
    }
    
    public func initElsa() {
        frameAnimation.firstFrame = 13 //elsa, belle
        frameAnimation.frameSets = [[14,15,16,17],[18,19,20]] //elsa, belle
        frameAnimation.filenameBase = "el_home_region00_" //elsa
        initGeneral()
    }
    
    public func initRapunzel() {
        frameAnimation.firstFrame = 0 //rapunzel, merida
        frameAnimation.frameSets = [[14,15,16],[17,18,19,20]] //rapunzel
        frameAnimation.filenameBase = "ra_homeregion00_" //rapunzel
        initGeneral()
    }
    
    public func initBelle() {
        frameAnimation.firstFrame = 13 //elsa, belle
        frameAnimation.frameSets = [[14,15,16,17],[18,19,20]] //elsa, belle
        frameAnimation.filenameBase = "be_home_region00_" //belle
        initGeneral()
    }
    
    public func initMerida() {
        frameAnimation.firstFrame = 0 //rapunzel, merida
        frameAnimation.frameSets = [[14,15,16],[17,18,19]] //merida
        frameAnimation.filenameBase = "me_home_region00_" //merida
        initGeneral()
    }
    
    public func initJasmine() {
        frameAnimation.firstFrame = 12 //jasmine
        frameAnimation.frameSets = [[13,14,15],[16,17]] //jasmine
        frameAnimation.filenameBase = "ja_home_region00_" //jasmine
        initGeneral()
    }
    
    public func initAriel() {
        frameAnimation.firstFrame = 0
        frameAnimation.frameSets = [[14,15,16],[17,18,19]]
        frameAnimation.filenameBase = "ar_home_region00_"
        initGeneral()
    }
    
    func setAssetFileURL(fileURL: NSURL) {
        currentAsset = AVURLAsset(URL: fileURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        player = AVAudioPlayer(contentsOfURL: fileURL, error: nil)
        player!.prepareToPlay()
        
        graphView!.asset = currentAsset
        frameAnimation.buildFrames(graphView.dataPoints, withStrategy: .both)
        sequenceLabel!.stringValue = frameAnimation.printSequence()
    }
    
    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        
        whichPrincess.addItemsWithTitles(["Elsa","Belle","Jasmine","Merida","Rapunzel","Ariel"])
        for (var i = 0; i < 6; i++) {
            whichPrincess.itemAtIndex(i).enabled = true
            whichPrincess.itemAtIndex(i).target = self
            whichPrincess.itemAtIndex(i).action = Selector("init" + whichPrincess.itemTitleAtIndex(i))
        }
        
//        for strategy in FrameAnimationStrategy.allValues {
//            whichStrategy.addItemWithTitle(strategy.toRaw())
//        }
//        
//        for (var i = 0; i < 6; i++) {
//            whichStrategy.itemAtIndex(i).enabled = true
//            whichStrategy.itemAtIndex(i).target = frameAnimation
//            whichStrategy.itemAtIndex(i).action = Selector("buildFrames(graphView.dataPoints, withStrategy: ." + "FrameAnimationStrategy.fromRaw(whichStrategy.itemTitleAtIndex(i))")
//        }

        
        
        
//        setAssetFileURL(NSBundle.mainBundle().URLForResource("sw900yrs", withExtension: "wav"))
//        setAssetFileURL(NSBundle.mainBundle().URLForResource("test_vo", withExtension: "wav"))
//       setAssetFileURL(NSBundle.mainBundle().URLForResource("dx_frzn_016-120_anna", withExtension: "wav"))
        setAssetFileURL(NSBundle.mainBundle().URLForResource("dx_frzn_017-530_anna", withExtension: "wav"))
//        setAssetFileURL(NSBundle.mainBundle().URLForResource("dx_frzn_025-540_elsa", withExtension: "wav"))
//        setAssetFileURL(NSBundle.mainBundle().URLForResource("dx_frzn_017-520_elsa", withExtension: "wav"))
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
    
    init() {
        super.init()
        // Add your subclass-specific initialization here.
    }

}

