//
//  SPAudioReader.h
//  Chatter
//
//  Created by Quinn McHenry on 7/23/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

@interface SPAudioReader : NSObject

+ (NSData *)dataFromAsset:(AVAsset *)asset downsampleFactor:(NSInteger)downsampleFactor;
+ (Float32) floatFromAssetData:(NSData*)assetData index:(NSInteger)index;
+ (NSInteger) countOfAssetData:(NSData *)assetData;

@end
