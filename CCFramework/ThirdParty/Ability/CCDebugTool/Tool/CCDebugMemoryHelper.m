//
//  CCDebugMemoryHelper.m
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

#import "CCDebugMemoryHelper.h"
#include <mach/mach.h>
#include <malloc/malloc.h>

#define KB (1024)
#define MB (KB * 1024)
#define GB (MB * 1024)

static vm_size_t ccPageSize = 0;
static vm_statistics_data_t ccStats;

@implementation CCDebugMemoryHelper

/**
 *  @author CC, 16-03-05
 *  
 *  @brief 使用内存
 */
+ (NSString *)bytesOfUsedMemory
{
    struct mstats stat = mstats();
    return [self number2String:stat.bytes_used];
}

+ (NSString *)bytesOfTotalMemory
{
    [self updateHostStatistics];
    
    unsigned long long free_count = (unsigned long long)ccStats.free_count;
    unsigned long long active_count = (unsigned long long)ccStats.active_count;
    unsigned long long inactive_count = (unsigned long long)ccStats.inactive_count;
    unsigned long long wire_count = (unsigned long long)ccStats.wire_count;
    unsigned long long pageSize = (unsigned long long)ccPageSize;
    
    unsigned long long mem_free = (free_count + active_count + inactive_count + wire_count) * pageSize;
    return [self number2String:mem_free];
}

//for internal use
+ (BOOL)updateHostStatistics
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &ccPageSize);
    return (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&ccStats, &host_size) == KERN_SUCCESS);
}


+ (NSString *)number2String:(int64_t)n
{
    if (n < KB) {
        return [NSString stringWithFormat:@"%lldB", n];
    } else if (n < MB) {
        return [NSString stringWithFormat:@"%.1fK", (float)n / (float)KB];
    } else if (n < GB) {
        return [NSString stringWithFormat:@"%.1fM", (float)n / (float)MB];
    } else {
        return [NSString stringWithFormat:@"%.1fG", (float)n / (float)GB];
    }
}

/**
 *  @author CC, 16-03-05
 *  
 *  @brief  获取当前设备可用内存
 */
+ (NSString *)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    if (kernReturn != KERN_SUCCESS)
        return nil;
    
    return [self number2String:(vm_page_size * vmStats.free_count)];
}

/**
 *  @author CC, 16-03-05
 *  
 *  @brief 获取当前任务所占用的内存
 */
+ (NSString *)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS)
        return nil;
    
    return [self number2String:taskInfo.resident_size];
}

@end
