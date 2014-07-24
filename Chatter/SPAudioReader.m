//
//  SPAudioReader.m
//  Chatter
//
//  Created by Quinn McHenry on 7/23/14.
//  Copyright (c) 2014 Small Planet Digital. All rights reserved.
//
// extracted from   FDWaveformView
//
//  Created by William Entriken on 10/6/13.
//  Copyright (c) 2013 William Entriken. All rights reserved.
//
// FROM http://stackoverflow.com/questions/5032775/drawing-waveform-with-avassetreader
// AND http://stackoverflow.com/questions/8298610/waveform-on-ios
// DO SEE http://stackoverflow.com/questions/1191868/uiimageview-scaling-interpolation
// see http://stackoverflow.com/questions/3514066/how-to-tint-a-transparent-png-image-in-iphone


#import "SPAudioReader.h"

#define absX(x) (x<0?0-x:x)
#define minMaxX(x,mn,mx) (x<=mn?mn:(x>=mx?mx:x))
#define noiseFloor (-50.0)
#define decibel(amplitude) (20.0 * log10(absX(amplitude)/32767.0))


@import AVFoundation;
@import CoreMedia;

@implementation SPAudioReader


+ (NSData *)dataFromAsset:(AVAsset *)asset downsampleFactor:(NSInteger)downsampleFactor {
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
    AVAssetTrack *songTrack = [asset.tracks objectAtIndex:0];
    NSDictionary *outputSettingsDict = [[NSDictionary alloc] initWithObjectsAndKeys:
        [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
        //     [NSNumber numberWithInt:44100.0],AVSampleRateKey, /*Not Supported*/
        //     [NSNumber numberWithInt: 2],AVNumberOfChannelsKey,    /*Not Supported*/
        [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
        [NSNumber numberWithBool:NO],AVLinearPCMIsBigEndianKey,
        [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
        [NSNumber numberWithBool:NO],AVLinearPCMIsNonInterleaved,
        nil];
    AVAssetReaderTrackOutput *output = [[AVAssetReaderTrackOutput alloc] initWithTrack:songTrack outputSettings:outputSettingsDict];
    [reader addOutput:output];
    UInt32 channelCount = 0;
    NSArray *formatDesc = songTrack.formatDescriptions;
    for(unsigned int i = 0; i < [formatDesc count]; ++i) {
        CMAudioFormatDescriptionRef item = (__bridge CMAudioFormatDescriptionRef)[formatDesc objectAtIndex:i];
        const AudioStreamBasicDescription* fmtDesc = CMAudioFormatDescriptionGetStreamBasicDescription(item);
        if (!fmtDesc) return nil; //!
        channelCount = fmtDesc->mChannelsPerFrame;
    }
    
    UInt32 bytesPerInputSample = 2 * channelCount;
    Float32 maximum = noiseFloor;
    Float64 tally = 0;
    Float32 tallyCount = 0;
    Float32 outSamples = 0;
    
    downsampleFactor = downsampleFactor<1 ? 1 : downsampleFactor;
    unsigned long int totalSamples = (unsigned long int) asset.duration.value;
    NSMutableData *fullSongData = [[NSMutableData alloc] initWithCapacity:totalSamples/downsampleFactor*2]; // 16-bit samples
    reader.timeRange = CMTimeRangeMake(CMTimeMake(0, asset.duration.timescale), asset.duration);
    [reader startReading];
    
    while (reader.status == AVAssetReaderStatusReading) {
        AVAssetReaderTrackOutput * trackOutput = (AVAssetReaderTrackOutput *)[reader.outputs objectAtIndex:0];
        CMSampleBufferRef sampleBufferRef = [trackOutput copyNextSampleBuffer];
        if (sampleBufferRef) {
            CMBlockBufferRef blockBufferRef = CMSampleBufferGetDataBuffer(sampleBufferRef);
            size_t bufferLength = CMBlockBufferGetDataLength(blockBufferRef);
            void *data = malloc(bufferLength);
            CMBlockBufferCopyDataBytes(blockBufferRef, 0, bufferLength, data);
            
            SInt16 *samples = (SInt16 *) data;
            int sampleCount = (int) bufferLength / bytesPerInputSample;
            for (int i=0; i<sampleCount; i++) {
                Float32 sample = (Float32) *samples++;
                sample = decibel(sample);
                sample = minMaxX(sample,noiseFloor,0);
                tally += sample; // Should be RMS?
                for (int j=1; j<channelCount; j++)
                    samples++;
                tallyCount++;
                
                if (tallyCount == downsampleFactor) {
                    sample = tally / tallyCount;
                    maximum = maximum > sample ? maximum : sample;
//                    NSLog(@"%.0f -> %f", outSamples, sample);
                    [fullSongData appendBytes:&sample length:sizeof(sample)];
                    tally = 0;
                    tallyCount = 0;
                    outSamples++;
                }
            }
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
            free(data);
        }
    }
    
    // if (reader.status == AVAssetReaderStatusFailed || reader.status == AVAssetReaderStatusUnknown)
    // Something went wrong. Handle it.
    if (reader.status == AVAssetReaderStatusCompleted){
        return fullSongData;
    }
    return nil;
}

+ (Float32) floatFromAssetData:(NSData*)assetData index:(NSInteger)index {
    Float32 value;
    [assetData getBytes:&value range:NSMakeRange(index*sizeof(Float32), sizeof(Float32))];
    return value;
}

+ (NSInteger) countOfAssetData:(NSData *)assetData {
    return assetData.length / sizeof(Float32);
}

@end
