//
//  RACBacktrace.h
//  ReactiveCocoa
//
//  Created by Justin Spahr-Summers on 2012-08-20.
//  Copyright (c) 2012 GitHub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef DEBUG

FOUNDATION_EXPORT void cc_dispatch_async(dispatch_queue_t queue, dispatch_block_t block);
FOUNDATION_EXPORT void cc_dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
FOUNDATION_EXPORT void cc_dispatch_after(dispatch_time_t time, dispatch_queue_t queue, dispatch_block_t block);
FOUNDATION_EXPORT void cc_dispatch_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
FOUNDATION_EXPORT void cc_dispatch_barrier_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function);
FOUNDATION_EXPORT void cc_dispatch_after_f(dispatch_time_t time, dispatch_queue_t queue, void *context, dispatch_function_t function);

#define dispatch_async           cc_dispatch_async
#define dispatch_barrier_async   cc_dispatch_barrier_async
#define dispatch_after           cc_dispatch_after
#define dispatch_async_f         cc_dispatch_async_f
#define dispatch_barrier_async_f cc_dispatch_barrier_async_f
#define dispatch_after_f         cc_dispatch_after_f

/// Preserves backtraces across asynchronous calls.
///
/// On OS X, you can enable the automatic capturing of asynchronous backtraces
/// (in Debug builds) by setting the `DYLD_INSERT_LIBRARIES` environment variable
/// to `@executable_path/../Frameworks/ReactiveCocoa.framework/ReactiveCocoa` in
/// your scheme's Run action settings.
///
/// On iOS, your project and RAC will automatically use the `rac_` GCD functions
/// (declared above) for asynchronous work. Unfortunately, unlike OS X, it's
/// impossible to capture backtraces inside NSOperationQueue or other code
/// outside of your project.
///
/// Once backtraces are being captured, you can `po [RACBacktrace backtrace]` in
/// the debugger to print them out at any time. You can even set up an alias in
/// ~/.lldbinit to do so:
///
///    command alias racbt po [RACBacktrace backtrace]
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

#define cc_dispatch_async           dispatch_async
#define cc_dispatch_barrier_async   dispatch_barrier_async
#define cc_dispatch_after           dispatch_after
#define cc_dispatch_async_f         dispatch_async_f
#define cc_dispatch_barrier_async_f dispatch_barrier_async_f
#define cc_dispatch_after_f         dispatch_after_f

#endif
