//
//  NSManagedObject+Convenience.m
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

#import <UIKit/UIKit.h>
#import "BaseManagedObject.h"
#import "config.h"

@implementation NSManagedObject (Queries)

/**
 *  find a local object
 *
 *  @return the anyone object
 */
+ (id)cc_Anyone
{
    return [self cc_AnyoneWithPredicate:nil];
}

/**
 *  sync find all objects
 *
 *  @return all local objects
 */
+ (NSArray *)cc_All
{
    return [self cc_AllWithPredicate:nil];
}

/**
 *  async find all objects
 *
 *  @param handler finished handler block
 */
+ (void)cc_AllWithHandler: (void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self cc_AllRequest];
    NSManagedObjectContext *context = [self currentContext];
    __block NSError *error = nil;
    if (CURRENT_SYS_VERSION > 8.0) {
        [context performBlock:^{
            NSAsynchronousFetchRequest *asyncRequest = [[NSAsynchronousFetchRequest alloc] initWithFetchRequest:request completionBlock:^(NSAsynchronousFetchResult *result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handler) {
                        handler(error,[result.finalResult copy]);
                    }
                });
            }];
            [context executeRequest:asyncRequest error:&error];
        }];
    }else{
        [context performBlock:^{
            NSArray *results = [context executeFetchRequest:request error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (handler) {
                    handler(error,results);
                }
            });
        }];
    }
}

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return all objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property
                      equalTo: (id)value
{
    return [self cc_WhereProperty: property
                          equalTo: value
                    sortedKeyPath: nil
                        ascending: NO];
}

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property property name
 *  @param value    expect value
 *  @param handler  finished handler block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
                 handler: (void (^)(NSError *, NSArray *))handler
{
    return [self cc_WhereProperty:property equalTo:value sortedKeyPath:nil ascending:NO handler:handler];
}

/**
 *  sync find objects where property is equal to a specification value
 *
 *  @param property priperty name
 *  @param value    expect value
 *
 *  @return an object fit in this condition
 */
+ (id)cc_FirstWhereProperty: (NSString *)property
                    equalTo: (id)value
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:1
                                                   batchSize:1];

    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    NSManagedObjectContext *context = [self currentContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSArray *objs = [context executeFetchRequest:request error:nil];
        if (objs.count > 0) {
            obj = objs[0];
        }
    }];
    return obj;
}

/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     expect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *
 *  @return objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending
{
    return [self cc_WhereProperty:property
                          equalTo:value
                    sortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:0
                       fetchLimit:0
                      fetchOffset:0];
}

/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property property name
 *  @param value    expect value
 *  @param keyPath  keypath
 *  @param ascendng ascending
 *  @param handler  finished fetch block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
                 handler: (void (^)(NSError *, NSArray *))handler
{
    return [self cc_WhereProperty: property
                          equalTo: value
                    sortedKeyPath: keyPath
                        ascending: ascending
                   fetchBatchSize: 0
                       fetchLimit: 0
                      fetchOffset: 0
                          handler: handler];
}

/**
 *  find all objects fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return all objects fit this predicate
 */
+ (NSArray *)cc_AllWithPredicate: (NSPredicate *)predicate
{
    NSFetchRequest *request = [self cc_AllRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;

}

/**
 *  find an object fit this predicate
 *
 *  @param predicate a specification NSPredicate
 *
 *  @return an objects fit this predicate
 */
+ (id)cc_AnyoneWithPredicate: (NSPredicate *)predicate
{
    NSFetchRequest *request = [self cc_AnyoneRequest];
    if (predicate != nil) {
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block id obj = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        obj = [[context executeFetchRequest:request error:&error] lastObject];
    }];
    return obj;
}

/**
 *  sync find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *
 *  @return objects fit in this condition
 */
+ (NSArray *)cc_WhereProperty: (NSString *)property
                      equalTo: (id)value
                sortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
{
    return [self cc_SortedKeyPath:keyPath
                        ascending:ascending
                   fetchBatchSize:batchSize
                       fetchLimit:fetchLimit
                      fetchOffset:fetchOffset
                            where:@"%K == %@",property,value];
}

/**
 *  async find objects where property is equal to a specification value and sorted using a keypath
 *
 *  @param property  property name
 *  @param value     exect value
 *  @param keyPath   keypath
 *  @param ascending ascending
 *  @param batchSize  batchSize to fetch
 *  @param fetchLimit fetch limit
 *  @param handler    finished fetch handler block
 */
+ (void)cc_WhereProperty: (NSString *)property
                 equalTo: (id)value
           sortedKeyPath: (NSString *)keyPath
               ascending: (BOOL)ascending
          fetchBatchSize: (NSUInteger)batchSize
              fetchLimit: (NSUInteger)fetchLimit
             fetchOffset: (NSUInteger)fetchOffset
                 handler: (void (^)(NSError *, NSArray *))handler
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:fetchLimit
                                                   batchSize:batchSize
                                                 fetchOffset:fetchOffset];

    [request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@",property,value]];
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    [context performBlock:^{
        NSError *error = nil;
        NSArray *objs = [context executeFetchRequest:request error:&error];
        if (handler) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(error,objs);
            });
        }
    }];
}

/**
 *  sync find objects with vargars paramaters
 *
 *  @param condition like [NSString stringWithFormat:]
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_Where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_AllRequest];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
                    batchSize: (NSUInteger)batchSize
                        where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:0
                                                   batchSize:batchSize];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  sync find objects with vargars paramaters
 *
 *  @param keyPath     sorted keyPath
 *  @param ascending   ascending
 *  @param batchSize   perform fetch batch size
 *  @param fetchLimit  max count of objects one time to fetch
 *  @param fetchOffset fetch offset
 *  @param condition   vargars paramaters conditons
 *
 *  @return objects fit this condition
 */
+ (NSArray *)cc_SortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
                        where: (NSString *)condition, ...
{
    NSFetchRequest *request = [self cc_RequestWithFetchLimit:fetchLimit
                                                   batchSize:batchSize
                                                 fetchOffset:fetchOffset];
    if (condition != nil) {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
    }
    if (keyPath != nil) {
        NSSortDescriptor *sorted = [NSSortDescriptor sortDescriptorWithKey:keyPath ascending:ascending];
        [request setSortDescriptors:@[sorted]];
    }
    NSManagedObjectContext *context = [self currentContext];
    __block NSArray *objs = nil;
    [context performBlockAndWait:^{
        NSError *error = nil;
        objs = [context executeFetchRequest:request error:&error];
    }];
    return objs;
}

/**
 *  fetch count of all objects
 *
 *  @return the entity's count
 */
+ (NSUInteger)cc_Count
{
    return [self cc_CountWhere:nil];
}

/**
 *  fetch count of all objects in this condition
 *
 *  @param condition filter condition
 *
 *  @return count of objects
 */
+ (NSUInteger)cc_CountWhere: (NSString *)condition, ...
{
    NSManagedObjectContext *manageObjectContext = [self currentContext];
    __block NSInteger count = 0;

    NSFetchRequest *request = [self cc_AllRequest];
    request.resultType = NSCountResultType;
    [request setIncludesSubentities:NO]; //Omit subentities. Default is YES (i.e. include subentities)

    if (condition)
    {
        va_list arguments;
        va_start(arguments, condition);
        NSPredicate *predicate = [NSPredicate predicateWithFormat:condition arguments:arguments];
        va_end(arguments);
        [request setPredicate:predicate];
        request.predicate = predicate;
    }

    [manageObjectContext performBlockAndWait:^{
        NSError *err;
        count = [manageObjectContext countForFetchRequest:request error:&err];
    }];

    return count;
}

@end
