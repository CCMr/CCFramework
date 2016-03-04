//
//  NSManagedObjectContext+Extensions.m
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

#import "NSManagedObjectContext+Additions.h"

@implementation NSManagedObjectContext (Additions)

#pragma mark -
#pragma mark :. Extensions

- (NSManagedObjectModel *)objectModel
{
    return [[self persistentStoreCoordinator] managedObjectModel];
}

#pragma mark--- Sync methods
- (NSArray *)fetchObjectsForEntity:(NSString *)entity
{
    return [self fetchObjectsForEntity:entity predicate:nil sortDescriptors:nil];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate
{
    return [self fetchObjectsForEntity:entity predicate:predicate sortDescriptors:nil];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors
{
    return [self fetchObjectsForEntity:entity predicate:nil sortDescriptors:sortDescriptors];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    return [self fetchObjectsForEntity:entity predicate:predicate sortDescriptors:sortDescriptors fetchLimit:0];
}

- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)limit
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self] predicate:predicate sortDescriptors:sortDescriptors];
    if (limit > 0)
        [request setFetchLimit:limit];
    
    NSError *error = nil;
    @try {
        NSArray *results = [self executeFetchRequest:request error:&error];
        
        if (error) {
            @throw [NSString stringWithFormat:@"CoreData Fetch error: %@", [error userInfo]];
            return nil;
        }
        
        return results;
        
    }
    @catch (NSException *exception) {
        NSLog(@"Fetch Exception: %@", [exception description]);
    }
    
    return nil;
}

- (id)fetchObjectForEntity:(NSString *)entity
{
    return [self fetchObjectForEntity:entity predicate:nil sortDescriptors:nil];
}

- (id)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate
{
    return [self fetchObjectForEntity:entity predicate:predicate sortDescriptors:nil];
}

- (id)fetchObjectForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors
{
    return [self fetchObjectForEntity:entity predicate:nil sortDescriptors:sortDescriptors];
}

- (id)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors
{
    NSArray *results = [self fetchObjectsForEntity:entity predicate:predicate sortDescriptors:sortDescriptors];
    if (results.count < 1)
        return nil;
    
    return [results objectAtIndex:0];
}


#pragma mark--- Async Methods
- (void)fetchObjectsForEntity:(NSString *)entity callback:(FetchObjectsCallback)callback
{
    [self fetchObjectsForEntity:entity predicate:nil sortDescriptors:nil callback:callback];
}

- (void)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate callback:(FetchObjectsCallback)callback
{
    [self fetchObjectsForEntity:entity predicate:predicate sortDescriptors:nil callback:callback];
}

- (void)fetchObjectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectsCallback)callback
{
    [self fetchObjectsForEntity:entity predicate:nil sortDescriptors:sortDescriptors callback:callback];
}

- (void)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectsCallback)callback
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entity inManagedObjectContext:self];
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntity:entityDescription predicate:predicate sortDescriptors:sortDescriptors];
    
    [self fetchRequest:request withCallback:callback];
}

- (void)fetchObjectForEntity:(NSString *)entity callback:(FetchObjectCallback)callback
{
    [self fetchObjectForEntity:entity predicate:nil sortDescriptors:nil callback:callback];
}

- (void)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate callback:(FetchObjectCallback)callback
{
    [self fetchObjectForEntity:entity predicate:predicate sortDescriptors:nil callback:callback];
}

- (void)fetchObjectForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectCallback)callback
{
    [self fetchObjectForEntity:entity predicate:nil sortDescriptors:sortDescriptors callback:callback];
}

- (void)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectCallback)callback
{
    [self fetchObjectsForEntity:entity predicate:predicate sortDescriptors:sortDescriptors callback:^(NSArray *objects, NSError *error) {
        id object = nil;
        
        if(objects.count > 0)
            object = [objects objectAtIndex:0];
        
        callback(object, error);
    }];
}


- (void)fetchRequest:(NSFetchRequest *)fetchRequest withCallback:(FetchObjectsCallback)callback
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    [context setPersistentStoreCoordinator:[self persistentStoreCoordinator]];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSError *error = nil;
        NSArray *objects = [context executeFetchRequest:fetchRequest error:&error];
        NSMutableArray *objectIds = [NSMutableArray arrayWithCapacity:objects.count];
        
        
        [objects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [objectIds addObject:[(NSManagedObject *)obj objectID]];
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSMutableArray *resultObjects = [NSMutableArray arrayWithCapacity:objectIds.count];
            
            [objectIds enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                [resultObjects addObject:[self objectWithID:(NSManagedObjectID *)obj]];
                
            }];
            
            
            callback([NSArray arrayWithArray:resultObjects], error);
        });
    });
}

#pragma mark--- Insert New Entity
- (id)insertEntity:(NSString *)entity
{
    return [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:self];
}

- (void)deleteEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate
{
    NSError __block *error = nil;
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self] predicate:predicate];
    
    NSArray *results = [self executeFetchRequest:fetchRequest error:&error];
    
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSManagedObject *object = (NSManagedObject *)obj;
        if([object validateForDelete:&error])
            NSLog(@"CoreData Delete error: %@", [error userInfo]);
        else
            [self deleteObject:object];
        
    }];
    
    [self save:&error];
}

- (void)deleteObjects:(id<NSFastEnumeration>)objects
{
    for (id obj in objects)
        [self deleteObject:obj];
}

#pragma mark -
#pragma mark :. Fetching

- (id)fetchObject:(NSString *)entityName usingValue:(id)value forKey:(NSString *)key returningAsFault:(BOOL)fault
{
    return [self fetchObject:entityName
              usingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", key, value]
            returningAsFault:fault];
}

- (id)fetchObject:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.predicate = predicate;
    req.fetchLimit = 1;
    req.returnsObjectsAsFaults = fault;
    
    // Execute request
    return [[self executeFetchRequest:req
                                error:nil] lastObject];
}

- (NSArray *)fetchObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.predicate = predicate;
    req.returnsObjectsAsFaults = fault;
    
    // Execute request
    return [self executeFetchRequest:req
                               error:nil];
}

- (NSArray *)fetchObjects:(NSString *)entityName usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.sortDescriptors = sortDescriptors;
    req.returnsObjectsAsFaults = fault;
    
    // Execute request
    return [self executeFetchRequest:req
                               error:nil];
}

- (NSArray *)fetchObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.sortDescriptors = sortDescriptors;
    req.predicate = predicate;
    req.returnsObjectsAsFaults = fault;
    
    // Execute request
    return [self executeFetchRequest:req
                               error:nil];
}

- (NSArray *)fetchObjects:(NSString *)entityName returningAsFault:(BOOL)fault
{
    return [self fetchObjects:entityName usingSortDescriptors:nil returningAsFault:fault];
}

#pragma mark--- Count
- (NSInteger)countObjects:(NSString *)entityName
{
    return [self countObjects:entityName usingPredicate:nil];
}

- (NSInteger)countObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.resultType = NSDictionaryResultType;
    req.predicate = predicate;
    req.returnsObjectsAsFaults = YES;
    
    // Execute request
    return [self countForFetchRequest:req error:nil];
}

#pragma mark -
#pragma mark :. FetchRequestsConstructors

- (NSFetchRequest *)fetchRequestForEntityObject:(NSString *)entityName usingValue:(id)value forKey:(NSString *)key returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.predicate = [NSPredicate predicateWithFormat:@"%K == %@", key, value];
    req.fetchLimit = 1;
    req.returnsObjectsAsFaults = fault;
    
    return req;
}

- (NSFetchRequest *)fetchRequestForEntityObject:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.predicate = predicate;
    req.fetchLimit = 1;
    req.returnsObjectsAsFaults = fault;
    
    return req;
}

- (NSFetchRequest *)fetchRequestForEntityObjects:(NSString *)entityName returningAsFault:(BOOL)fault
{
    return [self fetchRequestForEntityObjects:entityName
                               usingPredicate:nil
                         usingSortDescriptors:nil
                             returningAsFault:fault];
}

- (NSFetchRequest *)fetchRequestForEntityObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault
{
    return [self fetchRequestForEntityObjects:entityName
                               usingPredicate:predicate
                         usingSortDescriptors:nil
                             returningAsFault:fault];
}

- (NSFetchRequest *)fetchRequestForEntityObjects:(NSString *)entityName usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault
{
    return [self fetchRequestForEntityObjects:entityName
                               usingPredicate:nil
                         usingSortDescriptors:sortDescriptors
                             returningAsFault:fault];
}

- (NSFetchRequest *)fetchRequestForEntityObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault
{
    // Create request
    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    
    req.entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:self];
    req.sortDescriptors = sortDescriptors;
    req.predicate = predicate;
    req.returnsObjectsAsFaults = fault;
    
    return req;
}

@end