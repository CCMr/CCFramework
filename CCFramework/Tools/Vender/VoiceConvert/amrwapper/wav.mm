//
//  wav.m
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

#import <UIKit/UIkit.h>
#include "wav.h"

void WavWriter::writeString(const char *str)
{
    fputc(str[0], wav);
    fputc(str[1], wav);
    fputc(str[2], wav);
    fputc(str[3], wav);
}

void WavWriter::writeInt32(int value)
{
    fputc((value >> 0) & 0xff, wav);
    fputc((value >> 8) & 0xff, wav);
    fputc((value >> 16) & 0xff, wav);
    fputc((value >> 24) & 0xff, wav);
}

void WavWriter::writeInt16(int value)
{
    fputc((value >> 0) & 0xff, wav);
    fputc((value >> 8) & 0xff, wav);
}

void WavWriter::writeHeader(int length)
{
    writeString("RIFF");
    writeInt32(4 + 8 + 20 + 8 + length); //将16改为20
    writeString("WAVE");
    
    writeString("fmt ");
    writeInt32(20);
    
    int bytesPerFrame = bitsPerSample / 8 * channels;
    int bytesPerSec = bytesPerFrame * sampleRate;
    writeInt16(1);	     // Format
    writeInt16(channels);      // Channels
    writeInt32(sampleRate);    // Samplerate
    writeInt32(bytesPerSec);   // Bytes per sec
    writeInt16(bytesPerFrame); // Bytes per frame
    writeInt16(bitsPerSample); // Bits per sample
    
    writeInt32(0); //这儿需要字节对齐  nExSize
    
    writeString("data");
    writeInt32(length);
}

WavWriter::WavWriter(const char *filename, int sampleRate, int bitsPerSample, int channels)
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [paths objectAtIndex:0];
    NSString *docFilePath = [documentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%s", filename]];
    NSLog(@"documentPath=%@", documentPath);
    
    wav = fopen([docFilePath cStringUsingEncoding:NSASCIIStringEncoding], "wb");
    if (wav == NULL)
        return;
    dataLength = 0;
    this->sampleRate = sampleRate;
    this->bitsPerSample = bitsPerSample;
    this->channels = channels;
    
    writeHeader(dataLength);
}

WavWriter::~WavWriter()
{
    if (wav == NULL)
        return;
    fseek(wav, 0, SEEK_SET);
    writeHeader(dataLength);
    fclose(wav);
}

void WavWriter::writeData(const unsigned char *data, int length)
{
    if (wav == NULL)
        return;
    fwrite(data, length, 1, wav);
    dataLength += length;
}

