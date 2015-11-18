//
//  interf_enc.h
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

#ifndef OPENCORE_AMRNB_INTERF_ENC_H
#define OPENCORE_AMRNB_INTERF_ENC_H

#ifdef __cplusplus
extern "C" {
#endif
    
#ifndef AMRNB_WRAPPER_INTERNAL
    /* Copied from enc/src/gsmamr_enc.h */
    enum Mode {
        MR475 = 0, /* 4.75 kbps */
        MR515,     /* 5.15 kbps */
        MR59,      /* 5.90 kbps */
        MR67,      /* 6.70 kbps */
        MR74,      /* 7.40 kbps */
        MR795,     /* 7.95 kbps */
        MR102,     /* 10.2 kbps */
        MR122,     /* 12.2 kbps */
        MRDTX,     /* DTX       */
        N_MODES    /* Not Used  */
    };
#endif
    
    void *Encoder_Interface_init(int dtx);
    void Encoder_Interface_exit(void *state);
    int Encoder_Interface_Encode(void *state, enum Mode mode, const short *speech, unsigned char *out, int forceSpeech);
    
#ifdef __cplusplus
}
#endif

#endif
