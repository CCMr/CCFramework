//
// WebViewJavascriptBridge_JS.h
//  CCFramework
//
// Copyright (c) 2015 CC ( http://www.ccskill.com )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "WebViewJavascriptBridge_JS.h"

NSString *WebViewJavascriptBridge_js()
{
#define __wvjb_js_func__(x) #x
    
    // BEGIN preprocessorJSCode
    static NSString *preprocessorJSCode = @__wvjb_js_func__(; (function() {
        if (window.WebViewJavascriptBridge) {
            return;
        }
        window.WebViewJavascriptBridge = {
        registerHandler: registerHandler,
        callHandler: callHandler,
        _fetchQueue: _fetchQueue,
        _handleMessageFromObjC: _handleMessageFromObjC
        };
        
        var messagingIframe;
        var sendMessageQueue = [];
        var messageHandlers = {};
        
        var CUSTOM_PROTOCOL_SCHEME = 'wvjbscheme';
        var QUEUE_HAS_MESSAGE = '__WVJB_QUEUE_MESSAGE__';
        
        var responseCallbacks = {};
        var uniqueId = 1;
        
        function registerHandler(handlerName, handler) {
            messageHandlers[handlerName] = handler;
        }
        
        function callHandler(handlerName, data, responseCallback) {
            if (arguments.length == 2 && typeof data == 'function') {
                responseCallback = data;
                data = null;
            }
            _doSend({ handlerName:handlerName, data:data }, responseCallback);
        }
        
        function _doSend(message, responseCallback) {
            if (responseCallback) {
                var callbackId = 'cb_'+(uniqueId++)+'_'+new Date().getTime();
                responseCallbacks[callbackId] = responseCallback;
                message['callbackId'] = callbackId;
            }
            sendMessageQueue.push(message);
            messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        }
        
        function _fetchQueue() {
            var messageQueueString = JSON.stringify(sendMessageQueue);
            sendMessageQueue = [];
            return messageQueueString;
        }
        
        function _dispatchMessageFromObjC(messageJSON) {
            setTimeout(function _timeoutDispatchMessageFromObjC() {
                var message = JSON.parse(messageJSON);
                var messageHandler;
                var responseCallback;
                
                if (message.responseId) {
                    responseCallback = responseCallbacks[message.responseId];
                    if (!responseCallback) {
                        return;
                    }
                    responseCallback(message.responseData);
                    delete responseCallbacks[message.responseId];
                } else {
                    if (message.callbackId) {
                        var callbackResponseId = message.callbackId;
                        responseCallback = function(responseData) {
                            _doSend({ responseId:callbackResponseId, responseData:responseData });
                        };
                    }
                    
                    var handler = messageHandlers[message.handlerName];
                    try {
                        handler(message.data, responseCallback);
                    } catch(exception) {
                        console.log("WebViewJavascriptBridge: WARNING: javascript handler threw.", message, exception);
                    }
                    if (!handler) {
                        console.log("WebViewJavascriptBridge: WARNING: no handler for message from ObjC:", message);
                    }
                }
            });
        }
        
        function _handleMessageFromObjC(messageJSON) {
            _dispatchMessageFromObjC(messageJSON);
        }
        
        messagingIframe = document.createElement('iframe');
        messagingIframe.style.display = 'none';
        messagingIframe.src = CUSTOM_PROTOCOL_SCHEME + '://' + QUEUE_HAS_MESSAGE;
        document.documentElement.appendChild(messagingIframe);
        
        setTimeout(_callWVJBCallbacks, 0);
        function _callWVJBCallbacks() {
            var callbacks = window.WVJBCallbacks;
            delete window.WVJBCallbacks;
            for (var i=0; i<callbacks.length; i++) {
                callbacks[i](WebViewJavascriptBridge);
            }
        }
    })();); // END preprocessorJSCode
    
#undef __wvjb_js_func__
    return preprocessorJSCode;
};