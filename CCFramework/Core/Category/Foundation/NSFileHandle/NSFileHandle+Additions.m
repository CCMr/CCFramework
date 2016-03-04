//
//  NSFileHandle+readLine.m
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

#import "NSFileHandle+Additions.h"

@implementation NSFileHandle (Additions)

/**
 *  @brief   A Cocoa / Objective-C NSFileHandle category that adds the ability to read a file line by line.
 
 *
 *  @param theDelimier 分隔符
 *
 *  @return An NSData* object is returned with the line if found, or nil if no more lines were found
 */
- (NSData *)readLineWithDelimiter:(NSString *)theDelimiter
{
    NSUInteger bufferSize = 1024; // Set our buffer size
    
    // Read the delimiter string into a C string
    NSData *delimiterData = [theDelimiter dataUsingEncoding:NSASCIIStringEncoding];
    const char *delimiter = [delimiterData bytes];
    
    NSUInteger delimiterIndex = 0;
    
    NSData *lineData; // Our buffer of data
    
    unsigned long long currentPosition = [self offsetInFile];
    NSUInteger positionOffset = 0;
    
    BOOL hasData = YES;
    BOOL lineBreakFound = NO;
    
    while (lineBreakFound == NO && hasData == YES) {
        // Fill our buffer with data
        lineData = [self readDataOfLength:bufferSize];
        
        // If our buffer gets some data, proceed
        if ([lineData length] > 0) {
            // Get a pointer to our buffer's raw data
            const char *buffer = [lineData bytes];
            
            // Loop over the raw data, byte-by-byte
            for (int i = 0; i < [lineData length]; i++) {
                // If the current character matches a character in the delimiter sequence...
                if (buffer[i] == delimiter[delimiterIndex]) {
                    delimiterIndex++; // Move to the next char of the delimiter sequence
                    
                    if (delimiterIndex >= [delimiterData length]) {
                        // If we've found all of the delimiter characters, break out of the loop
                        lineBreakFound = YES;
                        positionOffset += i + 1;
                        break;
                    }
                } else {
                    // Otherwise, reset the current delimiter character offset
                    delimiterIndex = 0;
                }
            }
            
            if (lineBreakFound == NO) {
                positionOffset += [lineData length];
            }
        } else {
            hasData = NO;
            break;
        }
    }
    
    // Use positionOffset to determine the string to return...
    
    // Return to the start of this line
    [self seekToFileOffset:currentPosition];
    
    NSData *returnData = [self readDataOfLength:positionOffset];
    
    if ([returnData length] > 0) {
        return returnData;
    } else {
        return nil;
    }
}

@end
