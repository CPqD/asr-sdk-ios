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

// Tamanho do buffer principal.
// Com amostras em 8000 Hz, 16 bits por amostra e um canal (mono), o buffer comporta 30 segundos de audio.

extern const unsigned int kMainBufferSize;

// Numero de buffers no Audio Queue.

extern const unsigned int kNumberBuffers;

// Tamanho do queue buffer em bytes (8000 amostras/segundo) * (2 bytes/amostra) * (0,2 segundo).

extern const UInt32 kBufferSize;

// Tamanho da janela em numero de amostras.

extern const unsigned int window_size;

// numero de amostras / janela = (tamanho das amostras em bytes / numero de bytes por amostra) / tamanho da janela em amostras

extern const unsigned int zero_cross_vector_size;

// Limiar de energia.

extern const int level_threshold;

// struct para armazenar dados relevantes durante o uso do Audio Queue.

struct AQRecorderState {
    AudioStreamBasicDescription  mDataFormat;
    AudioQueueRef                mQueue;
    // AudioQueueBufferRef          mBuffers[kNumberBuffers];
    AudioQueueBufferRef          mBuffers[3];
    AudioFileID                  mAudioFile;
    // UInt32                       bufferByteSize;
    SInt64                       mCurrentPacket;
    bool                         mIsRunning;
    IMP                          callbackMethodImplementation;
    SEL                          callbackMethodSelector;
    __unsafe_unretained id       callbackTarget;
    void                         *mainBuffer;
    unsigned int                 *mainBufferOffset;
    int                          *zero_cross_vector;
    unsigned int                 *zero_cross_vector_position;
    
    //rmorbach -
    void                         *audioBuffer;
    IMP                          silenceCallbackMethodImplementation;
    SEL                          silenceCallbackMethodSelector;
    __unsafe_unretained id       silenceCallbackTarget;
    int                          lastLengthAudioBuffer;
    
    unsigned int kMainBufferSize;
    
};
