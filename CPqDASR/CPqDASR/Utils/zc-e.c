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

#include "zc-e.h"

// With 16000 Hz samples, 16 buts per sample and a mono channel the buffer holds 10 seconds of audio
const unsigned int kMainBufferSize = 320000;

// Length of queue buffer in bytes (16000 samples/second) * (2 bytes / sample) * 250 ms
const UInt32 kBufferSize = 8000;

// Number of buffers of Audio Queue
const unsigned int kNumberBuffers = 3;

// Size of window in number of samples
const unsigned int window_size = 100;

// number of samples / window = (size of samples in bytes / number of bytes per sample) / size of samples window
const unsigned int zero_cross_vector_size = (kMainBufferSize / 2) / window_size;

// energy threshold .

const int level_threshold = 2000;

void * mymalloc_custom(size_t size)
{
    void *p;
    if ( (p = malloc(size)) == NULL) {
        fprintf(stderr, "mymalloc_custom: failed to allocate %zu bytes", size);
        exit(1);
    }
    return p;
}


/**
 * Allocate buffers for zerocross counting.
 *
 * @param zc [i/o] zerocross work area
 * @param length [in] Cycle buffer size = Number of samples to hold
 */
void init_count_zc_e_custom(ZC *zc, int length)
{
    /* data spool for header-margin */
    zc->data = (SP16 *)mymalloc_custom(length * sizeof(SP16));
    /* zero-cross location */
    zc->is_zc = (int *)mymalloc_custom(length * sizeof(int));
    
    zc->length = length;
}



/**
 * Initialize all parameters and buffers for zero-cross counting.
 *
 * @param zc [i/o] zerocross work area
 * @param c_trigger [in] Tgigger level threshold
 * @param c_length [in] Cycle buffer size = Number of samples to hold
 * @param c_offset [in] Static DC offset of input data
 */
void reset_count_zc_e_custom(ZC *zc, int c_trigger, int c_length, int c_offset)
{
    int i;
    
    if (zc->length != c_length) {
        //log_warn("zerocross buffer length changed, re-allocate it");
        free_count_zc_e_custom(zc);
        init_count_zc_e_custom(zc, c_length);
    }
    
    zc->trigger = c_trigger;
    zc->offset = c_offset;
    
    zc->zero_cross = 0;
    zc->is_trig = FALSE;
    zc->sign = ZC_POSITIVE;
    zc->top = 0;
    zc->valid_len = 0;
    
    for (i=0; i<c_length; i++){
        zc->is_zc[i] = ZC_UNDEF;
    }
}

/**
 * End procedure: free all buffers.
 *
 * @param zc [i/o] zerocross work area
 */
void free_count_zc_e_custom(ZC *zc)
{
    free(zc->is_zc);
    free(zc->data);
}

/**
 * Adding buf[0..step-1] to the cycle buffer and update the count of
 * zero cross.   Also swap them with the oldest ones in the cycle buffer.
 * Also get the maximum level in the cycle buffer.
 *
 * @param zc [i/o] zerocross work area
 * @param buf [I/O] new samples, will be swapped by old samples when returned.
 * @param step [in] length of above.
 *
 * @return zero-cross count of the samples in the cycle buffer.
 */
int count_zc_e_custom(ZC *zc, SP16 *buf, int step)
{
    int i;
    SP16 tmp, level;
    
    level = 0;
    for (i=0; i<step; i++) {
        
        // fprintf(stderr, "zerocross: %d, buf[%d]: %hd\n", zc->zero_cross, i, buf[i]);
        
        
        if (zc->is_zc[zc->top] == TRUE) {
            zc->zero_cross--;
        }
        zc->is_zc[zc->top] = FALSE;
        /* exchange old data and buf */
        tmp = buf[i] + zc->offset;
        if (zc->is_trig) {
            if (zc->sign == ZC_POSITIVE && tmp < 0) {
                zc->zero_cross++;
                zc->is_zc[zc->top] = TRUE;
                zc->is_trig = FALSE;
                zc->sign = ZC_NEGATIVE;
            } else if (zc->sign == ZC_NEGATIVE && tmp > 0) {
                zc->zero_cross++;
                zc->is_zc[zc->top] = TRUE;
                zc->is_trig = FALSE;
                zc->sign = ZC_POSITIVE;
            }
        }
        if (abs(tmp) > zc->trigger) {
            zc->is_trig = TRUE;
        }
        if (abs(tmp) > level) level = abs(tmp);
        zc->data[zc->top] = buf[i];
        zc->top++;
        if (zc->valid_len < zc->top) zc->valid_len = zc->top;
        if (zc->top >= zc->length) {
            zc->top = 0;
        }
    }
    zc->level = (int)level;
    
    
    return (zc->zero_cross);
}


void calculateZcVector(
                       void *samples,
                       unsigned int samples_offset,
                       int *zero_cross_vector,
                       unsigned int zero_cross_vector_size,
                       unsigned int *zero_cross_vector_position,
                       unsigned int start_margin,
                       unsigned int window_size,
                       int level_threshold
                       ) {
    
    short *buffer = NULL;
    SP16 *currentBuffer = NULL;
    
    int num_samples;
    ZC zc;
    
    int c_length = start_margin ; // c_length = (int)(head_margin_msec * samples_in_msec); numero de amostras; start margin
    int zc_vector_first_invalid;
    
    buffer = (short *) samples;
    currentBuffer = buffer;
    
    num_samples = samples_offset / 2;
    
    zc_vector_first_invalid = (samples_offset / 2) / window_size;
    
    init_count_zc_e_custom(&zc, c_length);
    
    reset_count_zc_e_custom(&zc, level_threshold, c_length, 0);
    

    // Até então o for começava com i = *zero_cross_vector_position para não preencher o vetor desde o início toda vez,
    // dado que ele estaria preenchido em [0..*zero_cross_vector_position].
    // No entanto ele calcula errado, aparentemente.
    // Portanto não temos escolha e recalculamos o vetor desde o início toda vez.
    int i;
    for (i = 0; i < zc_vector_first_invalid; ++i) {
        zero_cross_vector[i] = count_zc_e_custom(&zc, &(currentBuffer[i * window_size]), window_size);
    }
    
    *zero_cross_vector_position = zc_vector_first_invalid;
    free_count_zc_e_custom(&zc);
}

int hasSpeechStopped(int *zero_cross_vector, unsigned int zero_cross_vector_position, unsigned int *speech_start_position, unsigned int *speech_stop_position, unsigned int mainBufferSize) {
    
    // states:
    // 1: searching start of speech
    // 2: searching end of speech
    int state;
    
    int zc_threshold;
    
    int i;
    
    state = 1;
    
    zc_threshold = 60;
    
    int is_speech_stop;
    
    is_speech_stop = 0;
    
    unsigned int local_speech_start_window = 0;
    unsigned int local_speech_stop_window = 0;
    
    for (i = 0; i < zero_cross_vector_position; ++i) {
        
        switch (state) {
            case 1:
                if (zero_cross_vector[i] >= zc_threshold) {
                    
                    int is_speech_start;
                    // 100 ms in 8k = 800 samples = 8 windows
                    int j;
                    
                    if (i + 8 <= zero_cross_vector_position) {
                        
                        is_speech_start = 1;
                        
                        for (j = i + 1; j < i + 8; ++j) {
                            if (zero_cross_vector[j] < zc_threshold) {
                                is_speech_start = 0;
                                break;
                            }
                        }
                        
                        if (is_speech_start) {
                            local_speech_start_window = i;
                            state = 2;
                            i += 7;
                        }
                    }
                }
                break;
                
            case 2:
                if (zero_cross_vector[i] < zc_threshold) {
                    // 500 ms in 8k = 4000 samples = 40 windows
                    // 500 ms in 16k = 8000 samples = 80 windows
                    int windows = (mainBufferSize == 320000) ? 160 : 80;
                    int j;
                    
                    if (i + windows <= zero_cross_vector_position) {
                        is_speech_stop = 1;
                        for (j = i + 1; j < i + windows; ++j) {
                            if (zero_cross_vector[j] >= zc_threshold) {
                                is_speech_stop = 0;
                                break;
                                
                            }
                        }
                    }
                }
                break;
            default:
                break;
        }
        if (is_speech_stop) {
            local_speech_stop_window = i;
            break;
        }
    }
    
    if (is_speech_stop) {
        *speech_start_position = local_speech_start_window;
        *speech_stop_position = local_speech_stop_window;
    } else {
        *speech_start_position = *speech_stop_position = UINT32_MAX;
    }
    
    return is_speech_stop;
    
}

void MyAudioQueueInputCallback(
                               void                                *aqData,
                               AudioQueueRef                       inAQ,
                               AudioQueueBufferRef                 inBuffer,
                               const AudioTimeStamp                *inStartTime,
                               UInt32                              inNumPackets,
                               const AudioStreamPacketDescription  *inPacketDesc
                               ) {
    

    // Pointer for convenience
    struct AQRecorderState *pAqData;
    
    pAqData = (struct AQRecorderState *) aqData;
    
    // main buffer
    void *_mainBuffer;
    
    // offset of main buffer
    unsigned int *_mainBufferOffset;
    
    // zero cross vector used to detect end of speech
    int *_zero_cross_vector;
    
    // Position of first non-valid elemtn in zero cross vector
    unsigned int *_zero_cross_vector_position;
    
    _mainBuffer = pAqData->mainBuffer;
    _mainBufferOffset = pAqData->mainBufferOffset;
    _zero_cross_vector = pAqData->zero_cross_vector;
    _zero_cross_vector_position = pAqData->zero_cross_vector_position;
    
    // Write in the main buffer. If there is no space left in main buffer, erase old samples from main buffer to fit new ones.
    if (*_mainBufferOffset + inBuffer->mAudioDataByteSize > pAqData->kMainBufferSize) {
        
        unsigned int difference;
        
        //difference = *_mainBufferOffset + inBuffer->mAudioDataByteSize - kMainBufferSize;
        difference = *_mainBufferOffset + inBuffer->mAudioDataByteSize - pAqData->kMainBufferSize;
        
        memmove(_mainBuffer, _mainBuffer + difference, *_mainBufferOffset - difference);
        
        *_mainBufferOffset -= difference;
  
        printf("overflow! data exceeded in %d bytes", difference);
        
    }
    
    memcpy(_mainBuffer + *_mainBufferOffset, inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
    
    *_mainBufferOffset += inBuffer->mAudioDataByteSize;
    
    pAqData->audioBuffer = inBuffer->mAudioData;
    pAqData->lastLengthAudioBuffer = (int)inBuffer->mAudioDataByteSize;
    
    pAqData->callbackMethodImplementation(pAqData->callbackTarget, pAqData->callbackMethodSelector, (int)inBuffer->mAudioDataByteSize);
    
    // Enqueue buffer is running.
    if (pAqData->mIsRunning) {
        
        AudioQueueEnqueueBuffer(pAqData->mQueue, inBuffer, 0, NULL);
        
    }
    
    //Verify each two seconds
    if (*_mainBufferOffset >= 64000) {
        unsigned int speech_start_window;
        unsigned int speech_stop_window;
        
        // 2400 samples = (0,3 seconds) * (8000 samples / second)
        // 4800 samples = (0,3 seconds) * (16000 samples / second)
        //unsigned int samples = 4800;
        unsigned int samples = (pAqData->kMainBufferSize == 320000) ? 4800 : 2400;
        calculateZcVector(_mainBuffer, *_mainBufferOffset, _zero_cross_vector, zero_cross_vector_size, _zero_cross_vector_position, samples, window_size, level_threshold);
        if (hasSpeechStopped(_zero_cross_vector, *_zero_cross_vector_position, &speech_start_window, &speech_stop_window, pAqData->kMainBufferSize)) {
            pAqData->silenceCallbackMethodImplementation(pAqData->silenceCallbackTarget, pAqData->silenceCallbackMethodSelector, 1);
        }
        
    }
    
}
