//
//  CCBacktrace.h
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

#ifdef DEBUG

extern void cc_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
extern void cc_dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
extern void cc_dispatch_after(dispatch_time_t time, dispatch_queue_t queue, dispatch_block_t block);
extern void cc_dispatch_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
extern void cc_dispatch_barrier_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
extern void cc_dispatch_after_f(dispatch_time_t time, dispatch_queue_t queue, void *context, dispatch_function_t function);

#define cc_gcd_dispatch_async           cc_dispatch_async
#define cc_gcd_dispatch_barrier_async   cc_dispatch_barrier_async
#define cc_gcd_dispatch_after           cc_dispatch_after
#define cc_gcd_dispatch_async_f         cc_dispatch_async_f
#define cc_gcd_dispatch_barrier_async_f cc_dispatch_barrier_async_f
#define cc_gcd_dispatch_after_f         cc_dispatch_after_f

/// Preserves backtraces across asynchronous calls.
///
/// On OS X, you can enable the automatic capturing of asynchronous backtraces
/// (in Debug builds) by setting the `DYLD_INSERT_LIBRARIES` environment variable
/// to `@executable_path/../Frameworks/CCFramework.framework/CCFramework` in
/// your scheme's Run action settings.
///
/// On iOS, your project and CC will automatically use the `cc_` GCD functions
/// (declared above) for asynchronous work. Unfortunately, unlike OS X, it's
/// impossible to capture backtraces inside NSOperationQueue or other code
/// outside of your project.
///
/// Once backtraces are being captured, you can `po [CCBacktrace backtrace]` in
/// the debugger to print them out at any time. You can even set up an alias in
/// ~/.lldbinit to do so:
///
///    command alias racbt po [CCBacktrace backtrace]
///
@interface CCBacktrace : NSObject

/// The backtrace from any previous thread.
@property (nonatomic, strong, readonly) CCBacktrace *previousThreadBacktrace;

/// The call stack of this backtrace's thread.
@property (nonatomic, copy, readonly) NSArray *callStackSymbols;

/// Captures the current thread's backtrace, appending it to any backtrace from
/// a previous thread.
+ (instancetype)backtrace;

/// Same as +backtrace, but omits the specified number of frames at the
/// top of the stack (in addition to this method itself).
+ (instancetype)backtraceIgnoringFrames:(NSUInteger)ignoreCount;

@end

#else

#define cc_gcd_dispatch_async           dispatch_async
#define cc_gcd_dispatch_barrier_async   dispatch_barrier_async
#define cc_gcd_dispatch_after           dispatch_after
#define cc_gcd_dispatch_async_f         dispatch_async_f
#define cc_gcd_dispatch_barrier_async_f dispatch_barrier_async_f
#define cc_gcd_dispatch_after_f         dispatch_after_f

#endif
