//
//  SPURLAsset.swift
//  Chatter
//
//  Created by Quinn McHenry on 7/24/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

import Cocoa
import AVFoundation
import ChatterLib

public class SPURLAsset: AVURLAsset {

    var rawData:NSData?
    public var assetData:NSData? {
        if (!rawData) {
            rawData = SPAssetReader.dataFromAsset(self, downsampleFactor: 200)
        }
        return rawData
    }
}
