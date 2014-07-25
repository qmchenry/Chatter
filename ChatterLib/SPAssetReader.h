//
//  SPAssetReader.h
//  Chatter
//
//  Created by Quinn McHenry on 7/24/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVAsset.h>

@interface SPAssetReader : NSObject

+ (CGFloat)noiseFloor;
+ (void)setNoiseFloor:(CGFloat)newValue ;
+ (NSData *)dataFromAsset:(AVAsset *)asset downsampleFactor:(NSInteger)downsampleFactor;
+ (Float32) floatFromAssetData:(NSData*)assetData index:(NSInteger)index;
+ (NSInteger) countOfAssetData:(NSData *)assetData;

@end
