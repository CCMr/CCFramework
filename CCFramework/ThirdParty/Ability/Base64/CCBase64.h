//
//  CCLanguage.h
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

#import <Foundation/Foundation.h>

// CCBase64
//
/// Helper for handling Base64 and WebSafeBase64 encodings
//
/// The webSafe methods use different character set and also the results aren't
/// always padded to a multiple of 4 characters.  This is done so the resulting
/// data can be used in urls and url query arguments without needing any
/// encoding.  You must use the webSafe* methods together, the data does not
/// interop with the RFC methods.
//
@interface CCBase64 : NSObject

//
// Standard Base64 (RFC) handling
//

// encodeData:
//
/// Base64 encodes contents of the NSData object.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)encodeData:(NSData *)data;

// decodeData:
//
/// Base64 decodes contents of the NSData object.
//
/// Returns:
///   A new autoreleased NSData with the decoded payload.  nil for any error.
//
+(NSData *)decodeData:(NSData *)data;

// encodeBytes:length:
//
/// Base64 encodes the data pointed at by |bytes|.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)encodeBytes:(const void *)bytes length:(NSUInteger)length;

// decodeBytes:length:
//
/// Base64 decodes the data pointed at by |bytes|.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)decodeBytes:(const void *)bytes length:(NSUInteger)length;

// stringByEncodingData:
//
/// Base64 encodes contents of the NSData object.
//
/// Returns:
///   A new autoreleased NSString with the encoded payload.  nil for any error.
//
+(NSString *)stringByEncodingData:(NSData *)data;

// stringByEncodingBytes:length:
//
/// Base64 encodes the data pointed at by |bytes|.
//
/// Returns:
///   A new autoreleased NSString with the encoded payload.  nil for any error.
//
+(NSString *)stringByEncodingBytes:(const void *)bytes length:(NSUInteger)length;

// decodeString:
//
/// Base64 decodes contents of the NSString.
//
/// Returns:
///   A new autoreleased NSData with the decoded payload.  nil for any error.
//
+(NSData *)decodeString:(NSString *)string;

//
// Modified Base64 encoding so the results can go onto urls.
//
// The changes are in the characters generated and also allows the result to
// not be padded to a multiple of 4.
// Must use the matching call to encode/decode, won't interop with the
// RFC versions.
//

// webSafeEncodeData:padded:
//
/// WebSafe Base64 encodes contents of the NSData object.  If |padded| is YES
/// then padding characters are added so the result length is a multiple of 4.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)webSafeEncodeData:(NSData *)data
                      padded:(BOOL)padded;

// webSafeDecodeData:
//
/// WebSafe Base64 decodes contents of the NSData object.
//
/// Returns:
///   A new autoreleased NSData with the decoded payload.  nil for any error.
//
+(NSData *)webSafeDecodeData:(NSData *)data;

// webSafeEncodeBytes:length:padded:
//
/// WebSafe Base64 encodes the data pointed at by |bytes|.  If |padded| is YES
/// then padding characters are added so the result length is a multiple of 4.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)webSafeEncodeBytes:(const void *)bytes
                       length:(NSUInteger)length
                       padded:(BOOL)padded;

// webSafeDecodeBytes:length:
//
/// WebSafe Base64 decodes the data pointed at by |bytes|.
//
/// Returns:
///   A new autoreleased NSData with the encoded payload.  nil for any error.
//
+(NSData *)webSafeDecodeBytes:(const void *)bytes length:(NSUInteger)length;

// stringByWebSafeEncodingData:padded:
//
/// WebSafe Base64 encodes contents of the NSData object.  If |padded| is YES
/// then padding characters are added so the result length is a multiple of 4.
//
/// Returns:
///   A new autoreleased NSString with the encoded payload.  nil for any error.
//
+(NSString *)stringByWebSafeEncodingData:(NSData *)data
                                  padded:(BOOL)padded;

// stringByWebSafeEncodingBytes:length:padded:
//
/// WebSafe Base64 encodes the data pointed at by |bytes|.  If |padded| is YES
/// then padding characters are added so the result length is a multiple of 4.
//
/// Returns:
///   A new autoreleased NSString with the encoded payload.  nil for any error.
//
+(NSString *)stringByWebSafeEncodingBytes:(const void *)bytes
                                   length:(NSUInteger)length
                                   padded:(BOOL)padded;

// webSafeDecodeString:
//
/// WebSafe Base64 decodes contents of the NSString.
//
/// Returns:
///   A new autoreleased NSData with the decoded payload.  nil for any error.
//
+(NSData *)webSafeDecodeString:(NSString *)string;

@end
