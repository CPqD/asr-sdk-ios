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

#import <Foundation/Foundation.h>
#import <CPqDASR/CPqDASRRecognitionDelegate.h>


@class ASRMessage;

/**
 * @brief To be implemented by recognizer in order to be notified about ws state changes.
 */
@protocol CPqDASRClientEndpointDelegate <NSObject>

@optional
/**
 * Websocket connection has been opened.
 */
- (void)asrClientEndpointConnectionDidOpen;

@end

typedef void (^OpenConnectionBlock)(BOOL success);
typedef void (^SendMessageBlock)(ASRMessage * responseMessage);

@interface CPqDASRClientEndpoint : NSObject

/**
 * Init asr ws client.
 * @param wsURL - asr websocket url
 * @param dispatch_queue - queue to dispatch ws events.
 * @param credentials - to be used in ws connection, e.g ["username", "password"].
 */
- (instancetype)initWithURL:(NSURL *)wsURL dispatchQueue:(dispatch_queue_t)dispatch_queue credentials:(NSArray *)credentials;

/**
 * Init asr ws client.
 * @param wsURL - asr websocket url
 * @param credentials - to be used in ws connection, e.g ["username", "password"].
 */
- (instancetype)initWithURL:(NSURL *)wsURL credentials:(NSArray *)credentials;

/**
 * Set a delegate to be notified about recognition process. Mandatory.
 * @param recognitionDelegate - designated delegate.
 */
- (void)setRecognitionDelegate:(id<CPqDASRRecognitionDelegate>)recognitionDelegate;

/**
 * Set a delegate to be notified about changes in WS connection. Mandatory.
 * @param wsDelegate - designated delegate
 */
- (void)setWSDelegate:(id<CPqDASRClientEndpointDelegate>)wsDelegate;

/*!
 @brief Open a websocket connection.
 @discussion Before calling this method you must set wsDelegate property.
 */
- (void)open;

/*!
 @brief Open a websocket connection.
 @param block - to be called by end of the connection.
 */
- (void)openWithBlock:(OpenConnectionBlock)block;

/**
 @brief send message to websocket server.
 @param message to be sent
 */
- (void)sendMessage:(ASRMessage *)message;

/**
 @brief send message to websocket server and call the passed block.
 @param message to be sent
 @param block to be invoked with WebSocket server response
 */
- (void)sendMessage:(ASRMessage *)message withCompletionBlock:(SendMessageBlock)block;

/**
 @brief get session status.
 @return status one of ASRSessionStatus enumeration.
 */
- (NSInteger)getStatus;

/*!
 @brief Close connection to websocket server
 */
- (void)close;

/*!
 @brief Verify whether websocket connection is opened or not
 */
- (BOOL)isOpen;

/**
 * @param sessionTimeout
 *            the sessionTimeoutTime to be set
 */
- (void)setSessionTimeout:(NSTimeInterval)sessionTimeout;

@end
