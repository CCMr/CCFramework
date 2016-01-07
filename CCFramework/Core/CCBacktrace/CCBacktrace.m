//
//  CCBacktrace.m
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

#import <execinfo.h>
#import <pthread.h>
#import "CCBacktrace.h"

#define CC_BACKTRACE_MAX_CALL_STACK_FRAMES 128

#ifdef DEBUG

// Undefine the macros that hide the real GCD functions.
#undef dispatch_async
#undef dispatch_barrier_async
#undef dispatch_after
#undef dispatch_async_f
#undef dispatch_barrier_async_f
#undef dispatch_after_f

@interface CCBacktrace () {
    void *_callStackAddresses[CC_BACKTRACE_MAX_CALL_STACK_FRAMES];
    int _callStackSize;
}

@property(nonatomic, strong, readwrite) CCBacktrace *previousThreadBacktrace;
@end

@interface CCDispatchInfo : NSObject

// The recorded backtrace.
@property(nonatomic, strong, readonly) CCBacktrace *backtrace;

// The information for the original dispatch.
@property(nonatomic, readonly) dispatch_function_t function;
@property(nonatomic, readonly) void *context;
@property(nonatomic, readonly) dispatch_queue_t queue;

- (id)initWithQueue:(dispatch_queue_t)queue function:(dispatch_function_t)function context:(void *)context;

@end

// Function for use with dispatch_async_f and friends, which will save the
// backtrace onto the current queue, then call through to the original dispatch.
static void CCTraceDispatch(void *ptr)
{
    // Balance out the retain necessary for async calls.
    CCDispatchInfo *info __attribute__((objc_precise_lifetime)) = CFBridgingRelease(ptr);
    
    dispatch_queue_set_specific(info.queue, (void *)pthread_self(), (__bridge void *)info.backtrace, NULL);
    info.function(info.context);
    dispatch_queue_set_specific(info.queue, (void *)pthread_self(), NULL, NULL);
}

// Always inline this function, for consistency in backtraces.
__attribute__((always_inline)) static dispatch_block_t CCBacktraceBlock(dispatch_queue_t queue, dispatch_block_t block)
{
    CCBacktrace *backtrace = [CCBacktrace backtrace];
    
    return [^{
        CCBacktrace *backtraceKeptAlive __attribute__((objc_precise_lifetime)) = backtrace;
        
        dispatch_queue_set_specific(queue, (void *)pthread_self(), (__bridge void *)backtraceKeptAlive, NULL);
        block();
        dispatch_queue_set_specific(queue, (void *)pthread_self(), NULL, NULL);
    } copy];
}

void cc_dispatch_async(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_async(queue, CCBacktraceBlock(queue, block));
}

void cc_dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_barrier_async(queue, CCBacktraceBlock(queue, block));
}

void cc_dispatch_after(dispatch_time_t time, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_after(time, queue, CCBacktraceBlock(queue, block));
}

void cc_dispatch_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function)
{
    CCDispatchInfo *info = [[CCDispatchInfo alloc] initWithQueue:queue function:function context:context];
    dispatch_async_f(queue, (void *)CFBridgingRetain(info), &CCTraceDispatch);
}

void cc_dispatch_barrier_async_f(dispatch_queue_t queue, void *context, dispatch_function_t function)
{
    CCDispatchInfo *info = [[CCDispatchInfo alloc] initWithQueue:queue function:function context:context];
    dispatch_barrier_async_f(queue, (void *)CFBridgingRetain(info), &CCTraceDispatch);
}

void cc_dispatch_after_f(dispatch_time_t time, dispatch_queue_t queue, void *context, dispatch_function_t function)
{
    CCDispatchInfo *info = [[CCDispatchInfo alloc] initWithQueue:queue function:function context:context];
    dispatch_after_f(time, queue, (void *)CFBridgingRetain(info), &CCTraceDispatch);
}

// This is what actually performs the injection.
//
// The DYLD_INSERT_LIBRARIES environment variable must include the CC dynamic
// library in order for this to work.
__attribute__((used)) static struct {
    const void *replacement;
    const void *replacee;
} interposers[] __attribute__((section("__DATA,__interpose"))) = {
    {(const void *)&cc_dispatch_async, (const void *)&dispatch_async},
    {(const void *)&cc_dispatch_barrier_async, (const void *)&dispatch_barrier_async},
    {(const void *)&cc_dispatch_after, (const void *)&dispatch_after},
    {(const void *)&cc_dispatch_async_f, (const void *)&dispatch_async_f},
    {(const void *)&cc_dispatch_barrier_async_f, (const void *)&dispatch_barrier_async_f},
    {(const void *)&cc_dispatch_after_f, (const void *)&dispatch_after_f},
};

static void CCSignalHandler(int sig)
{
    NSLog(@"Backtrace: %@", [CCBacktrace backtrace]);
    fflush(stdout);
    
    // Restore the default action and raise the signal again.
    signal(sig, SIG_DFL);
    raise(sig);
}

static void CCExceptionHandler(NSException *ex)
{
    NSLog(@"Uncaught exception %@", ex);
    NSLog(@"Backtrace: %@", [CCBacktrace backtrace]);
    fflush(stdout);
}

@implementation CCBacktrace

#pragma mark Properties

- (NSArray *)callStackSymbols
{
    if (_callStackSize == 0) return @[];
    
    char **symbols = backtrace_symbols(_callStackAddresses, _callStackSize);
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:(NSUInteger)_callStackSize];
    
    for (int i = 0; i < _callStackSize; i++) {
        NSString *str = @(symbols[i]);
        [array addObject:str];
    }
    
    free(symbols);
    return array;
}

#pragma mark Lifecycle

+ (void)load
{
    @autoreleasepool
    {
        NSString *libraries = [[[NSProcessInfo processInfo] environment] objectForKey:@"DYLD_INSERT_LIBRARIES"];
        
        // Don't install our handlers if we're not actually intercepting function
        // calls.
        if ([libraries rangeOfString:@"ReactiveCocoa"].length == 0) return;
        
        NSLog(@"*** Enabling asynchronous backtraces");
        
        NSSetUncaughtExceptionHandler(&CCExceptionHandler);
    }
    
    signal(SIGILL, &CCSignalHandler);
    signal(SIGTRAP, &CCSignalHandler);
    signal(SIGABRT, &CCSignalHandler);
    signal(SIGFPE, &CCSignalHandler);
    signal(SIGBUS, &CCSignalHandler);
    signal(SIGSEGV, &CCSignalHandler);
    signal(SIGSYS, &CCSignalHandler);
    signal(SIGPIPE, &CCSignalHandler);
}

- (void)dealloc
{
    __autoreleasing CCBacktrace *previous __attribute__((unused)) = self.previousThreadBacktrace;
    self.previousThreadBacktrace = nil;
}

#pragma mark Backtraces

+ (instancetype)backtrace
{
    return [self backtraceIgnoringFrames:1];
}

+ (instancetype)backtraceIgnoringFrames:(NSUInteger)ignoreCount
{
    @autoreleasepool
    {
        CCBacktrace *oldBacktrace = (__bridge id)dispatch_get_specific((void *)pthread_self());
        
        CCBacktrace *newBacktrace = [[CCBacktrace alloc] init];
        newBacktrace.previousThreadBacktrace = oldBacktrace;
        
        int size = backtrace(newBacktrace->_callStackAddresses, CC_BACKTRACE_MAX_CALL_STACK_FRAMES);
        
        // Omit this method plus however many others from the backtrace.
        ++ignoreCount;
        if ((NSUInteger)size > ignoreCount) {
            memmove(newBacktrace->_callStackAddresses, newBacktrace->_callStackAddresses + ignoreCount, ((NSUInteger)size - ignoreCount) * sizeof(char *));
            size -= (int)ignoreCount;
        }
        
        newBacktrace->_callStackSize = size;
        return newBacktrace;
    }
}

#pragma mark NSObject

- (NSString *)description
{
    NSString *str = [NSString stringWithFormat:@"%@", self.callStackSymbols];
    if (self.previousThreadBacktrace != nil) {
        str = [str stringByAppendingFormat:@"\n\n... asynchronously invoked from: %@", self.previousThreadBacktrace];
    }
    
    return str;
}

@end

@implementation CCDispatchInfo

#pragma mark Lifecycle

- (id)initWithQueue:(dispatch_queue_t)queue function:(dispatch_function_t)function context:(void *)context
{
    @autoreleasepool
    {
        NSCParameterAssert(queue != NULL);
        NSCParameterAssert(function != NULL);
        
        self = [super init];
        if (self == nil) return nil;
        
        _backtrace = [CCBacktrace backtraceIgnoringFrames:1];
        
        _queue = queue;
        
        _function = function;
        _context = context;
        
        return self;
    }
}

- (void)dealloc
{
    if (_queue != NULL) {
        _queue = NULL;
    }
}

@end

#endif
