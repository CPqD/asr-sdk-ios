//
//  CPqDASRAudioSource.h
//  CPqDASR
//
//  Created by rodrigomorbach on 05/04/18.
//  Copyright © 2018 CPqD. All rights reserved.
//

#ifndef CPqDASRAudioSource_h
#define CPqDASRAudioSource_h

#import <Foundation/Foundation.h>

/**
 * @brief Recognizer must implement this delegate in order to be notified about new incoming data from audio source.
 */
@protocol CPqDASRAudioSourceDelegate <NSObject>

/**
 *
 */
- (void)audioSourceHasDataAvailable;

@end

/**
 * @brief Represents an audio input source for the recognition process.
 */
@protocol CPqDASRAudioSource <NSObject>

/**
 * Reads data from the source.
 */
- (NSData *)read;

/**
 * Closes the source and releases any system resources associated.
 */
- (void)close;

/**
 * Informs that the audio is finished. Forces any buffered output bytes to
 * be written out.
 */
- (void)finish;

@optional

/**
 * Optional. Starts audio source recording or configuration, if necessary.
 */
- (void)start;

@required
@property (nonatomic, weak) id<CPqDASRAudioSourceDelegate> delegate;
@end

#endif /* CPqDASRAudioSource_h */
