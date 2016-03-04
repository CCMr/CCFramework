//
//  NSManagedObjectContext+Additions.h
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
#import <CoreData/CoreData.h>
#import "NSFetchRequest+Additions.h"

@interface NSManagedObjectContext (Additions)

#pragma mark -
#pragma mark :. Extensions

typedef void (^ContextCallback)(NSManagedObjectContext *context);
typedef void (^ContextObjectCallback)(NSManagedObjectContext *context, id object);
typedef void (^ContextObjectsCallback)(NSManagedObjectContext *context, NSArray *objects);

#pragma mark--- Conveince Property
@property(nonatomic, readonly) NSManagedObjectModel *objectModel;

#pragma mark - Sync methods
- (NSArray *)fetchObjectsForEntity:(NSString *)entity;
- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate;
- (NSArray *)fetchObjectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;
- (NSArray *)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors fetchLimit:(NSUInteger)limit;
- (id)fetchObjectForEntity:(NSString *)entity;
- (id)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate;
- (id)fetchObjectForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors;
- (id)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors;

#pragma mark--- Async Methods
- (void)fetchObjectsForEntity:(NSString *)entity callback:(FetchObjectsCallback)callback;
- (void)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate callback:(FetchObjectsCallback)callback;
- (void)fetchObjectsForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectsCallback)callback;
- (void)fetchObjectsForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectsCallback)callback;

- (void)fetchObjectForEntity:(NSString *)entity callback:(FetchObjectCallback)callback;
- (void)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate callback:(FetchObjectCallback)callback;
- (void)fetchObjectForEntity:(NSString *)entity sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectCallback)callback;
- (void)fetchObjectForEntity:(NSString *)entity predicate:(NSPredicate *)predicate sortDescriptors:(NSArray *)sortDescriptors callback:(FetchObjectCallback)callback;

- (void)fetchRequest:(NSFetchRequest *)fetchRequest withCallback:(FetchObjectsCallback)callback;

#pragma mark--- Insert New Entity
- (id)insertEntity:(NSString *)entity;
- (void)deleteEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate;


/* Delete all given objects*/
- (void)deleteObjects:(id <NSFastEnumeration>)objects;

#pragma mark-
#pragma mark :. Fetching

/* Fetch one object using given key and value. Usefull to fetch objects on their uid key 
 * /!\ Warning, errors are ignored /!\
 */
- (id)fetchObject:(NSString *)entityName usingValue:(id)value forKey:(NSString *)key returningAsFault:(BOOL)fault;

/* Fetch one object using given predicate 
 * /!\ Warning, errors are ignored /!\
 */
- (id)fetchObject:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault;

/* Count all objects for given entity.
 * /!\ Warning, errors are ignored /!\
 */
- (NSInteger)countObjects:(NSString *)entityName;

/* Count all objects using given predicate
 * /!\ Warning, errors are ignored /!\
 */
- (NSInteger)countObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate;

/* Fetch all objects for given entity.
 * /!\ Warning, errors are ignored /!\
 */
- (NSArray *)fetchObjects:(NSString *)entityName returningAsFault:(BOOL)fault;

/* Fetch all objects using given predicate
 * /!\ Warning, errors are ignored /!\
 */
- (NSArray *)fetchObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate returningAsFault:(BOOL)fault;

/* Fetch all objects for given entity and sort them.
 * /!\ Warning, errors are ignored /!\
 */
- (NSArray *)fetchObjects:(NSString *)entityName usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault;

/* Fetch all objects for given entity, using predicate and sort them.
 * /!\ Warning, errors are ignored /!\
 */
- (NSArray *)fetchObjects:(NSString *)entityName usingPredicate:(NSPredicate *)predicate usingSortDescriptors:(NSArray *)sortDescriptors returningAsFault:(BOOL)fault;

#pragma mark-
#pragma mark :. FetchRequestsConstructors

/* Create fetch request to fetch one object using given key and value. Usefull to fetch objects on their uid key  */
- (NSFetchRequest*)fetchRequestForEntityObject:(NSString*)entityName usingValue:(id)value forKey:(NSString*)key returningAsFault:(BOOL)fault;

/* Create fetch request to fetch one object using given predicate 
 */
- (NSFetchRequest*)fetchRequestForEntityObject:(NSString*)entityName usingPredicate:(NSPredicate*)predicate returningAsFault:(BOOL)fault;

/* Create fetch request to fetch all objects for given entity.
 */
- (NSFetchRequest*)fetchRequestForEntityObjects:(NSString*)entityName returningAsFault:(BOOL)fault;

/* Create fetch request to fetch all objects using given predicate
 */
- (NSFetchRequest*)fetchRequestForEntityObjects:(NSString*)entityName usingPredicate:(NSPredicate*)predicate returningAsFault:(BOOL)fault;

/* Create fetch request to fetch all objects for given entity and sort them.
 */
- (NSFetchRequest*)fetchRequestForEntityObjects:(NSString*)entityName usingSortDescriptors:(NSArray*)sortDescriptors returningAsFault:(BOOL)fault;

/* Create fetch request to fetch all objects for given entity, using predicate and sort them.
 */
- (NSFetchRequest*)fetchRequestForEntityObjects:(NSString*)entityName usingPredicate:(NSPredicate*)predicate usingSortDescriptors:(NSArray*)sortDescriptors returningAsFault:(BOOL)fault;

@end