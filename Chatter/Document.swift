//
//  Document.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/17/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa
import AVFoundation
import CoreAudio
import CoreMedia

class Document: NSDocument {
    
    var asset: AVURLAsset?
    
    init() {
        super.init()
        // Add your subclass-specific initialization here.
        let fileUrl = NSBundle.mainBundle().URLForResource("Submarine", withExtension: "aiff")
        asset = AVURLAsset(URL: fileUrl, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        
        let assetData = SPAudioReader.dataFromAsset(asset, downsampleFactor: 100)
        let count = SPAudioReader.countOfAssetData(assetData)
        for (var i=0; i<count; i++) {
            println("\(i) -> \(SPAudioReader.floatFromAssetData(assetData, index: i))")
        }
    }

    override func windowControllerDidLoadNib(aController: NSWindowController) {
        super.windowControllerDidLoadNib(aController)
        
        // Add any code here that needs to be executed once the windowController has loaded the document's window.
                                    
    }

    override class func autosavesInPlace() -> Bool {
        return true
    }

    override func makeWindowControllers() {
        // Returns the Storyboard that contains your Document window.
                                    

        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let windowController = storyboard.instantiateInitialController() as NSWindowController
        self.addWindowController(windowController)
                                    
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


}

