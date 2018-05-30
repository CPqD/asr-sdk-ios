/*******************************************************************************
 * Copyright 2017 CPqD. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License.  You may obtain a copy
 * of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
 * License for the specific language governing permissions and limitations under
 * the License.
 ******************************************************************************/

#define TRUE 1
#define FALSE 0

#define ZC_UNDEF 2			///< Undefined mark for zerocross
#define ZC_POSITIVE 1		///< Positive mark used for zerocross
#define ZC_NEGATIVE -1		///< Negative mark used for zerocross

#include <AudioToolbox/AudioToolbox.h>
#include <objc/objc.h>

typedef short SP16;		///< 16bit speech data

typedef struct {
    int trigger;		///< Level threshold
    int length;		///< Cycle buffer size = number of samples to hold
    int offset;		///< Static data DC offset
    int zero_cross;		///< Current zero-cross num
    int is_trig;		///< Triggering status for zero-cross comp.
    int sign;			///< Current sign of waveform
    int top;			///< Top pointer of zerocross cycle buffer
    int valid_len;		///< Filled length
    SP16 *data;		///< Temporal data buffer for zerocross output
    int *is_zc;		///< zero-cross location
    int level;		///< Maximum absolute value of waveform signal in the zerocross buffer
} ZC;

void init_count_zc_e_custom(ZC *zc, int length);

void reset_count_zc_e_custom(ZC *zc, int c_trigger, int c_length, int c_offset);

void free_count_zc_e_custom(ZC *zc);

int count_zc_e_custom(ZC *zc, SP16 *buf, int step);

void calculateZcVector(
                       void *samples,
                       unsigned int samples_offset,
                       int *zero_cross_vector,
                       unsigned int zero_cross_vector_size,
                       unsigned int *zero_cross_vector_position,
                       unsigned int start_margin,
                       unsigned int window_size,
                       int level_threshold
                       );

int hasSpeechStopped(int *zero_cross_vector, unsigned int zero_cross_vector_position, unsigned int *speech_start_window, unsigned int *speech_stop_window, unsigned int mainBufferSize);

void MyAudioQueueInputCallback(
                               void                                *aqData,
                               AudioQueueRef                       inAQ,
                               AudioQueueBufferRef                 inBuffer,
                               const AudioTimeStamp                *inStartTime,
                               UInt32                              inNumPackets,
                               const AudioStreamPacketDescription  *inPacketDesc
                               );

extern const unsigned int kMainBufferSize;

extern const unsigned int kNumberBuffers;

extern const UInt32 kBufferSize;

extern const unsigned int window_size;

extern const unsigned int zero_cross_vector_size;

extern const int level_threshold;

// struct to hold relevant info for Audio Queue
struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    
    AudioQueueBufferRef          mBuffers[3];
    AudioFileID                  mAudioFile;
    
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;
    IMP                          callbackMethodImplementation;
    SEL                          callbackMethodSelector;
    __unsafe_unretained id       callbackTarget;
    void                         *mainBuffer;
    unsigned int                 *mainBufferOffset;
    int                          *zero_cross_vector;
    unsigned int                 *zero_cross_vector_position;
    
    void                         *audioBuffer;
    IMP                          silenceCallbackMethodImplementation;
    SEL                          silenceCallbackMethodSelector;
    __unsafe_unretained id       silenceCallbackTarget;
    int                          lastLengthAudioBuffer;
    
    unsigned int kMainBufferSize;
    
};
