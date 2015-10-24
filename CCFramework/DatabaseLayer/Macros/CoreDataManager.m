//
//  CoreDataManager.m
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

#import "CoreDataManager.h"

@interface CoreDataManager()

@property (nonatomic, strong) NSURL *storeUrl;

@property (nonatomic, strong) NSPersistentStore *persistentStore;

@end

@implementation CoreDataManager

#pragma mark - init methods

-(instancetype)init
{
    if (self = [super init]) {
        [self addNotifications];
    }
    return self;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单例模式
 *
 *  @return 返回对象
 */
+ (instancetype)sharedlnstance
{
    static CoreDataManager *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

#pragma mark - merge notification methods

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  主线程管理对象保存通知
 *
 *  @param notification 通知
 */
- (void)mainManageObjectContextDidSaved:(NSNotification *)notification {
    @synchronized(self){
        [self.privateContext performBlock:^{
            [self.privateContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  子线程管理对象保存通知
 *
 *  @param notification 通知
 */
- (void)privateManageObjectContextDidSaved:(NSNotification *)notification {
    @synchronized(self){
        [self.mainContext performBlock:^{
            for(NSManagedObject *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
                [[self.mainContext objectWithID:[object objectID]] willAccessValueForKey:nil];
            }
            [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
        }];
    }
}

#pragma mark - Custom methods
/**
 *  @author CC, 2015-10-24
 *
 *  @brief  删除所有记录
 */
- (void)removeAllRecord {
    NSError *error = nil;
    NSPersistentStoreCoordinator *storeCoodinator = self.persistentStoreCoordinator;
    [storeCoodinator removePersistentStore:self.persistentStore error:&error];

    [self removeNotifications];
    _privateContext = nil;
    _mainContext = nil;
    if ([self removeSQLiteFilesAtStoreURL:self.storeUrl error:&error]) {
        self.persistentStore = [self.persistentStoreCoordinator
                                addPersistentStoreWithType:NSSQLiteStoreType
                                configuration:nil
                                URL:self.storeUrl
                                options:[self persistentStoreOptions]
                                error:&error];
        [self addNotifications];
    }
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  添加通知
 */
- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mainManageObjectContextDidSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[self mainContext]];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(privateManageObjectContextDidSaved:)
                                                 name:NSManagedObjectContextDidSaveNotification
                                               object:[self privateContext]];
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  删除通知
 */
- (void)removeNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Core Data stack

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  主线程管理对象
 *
 *  @return 返回主线程管理对象
 */
- (NSManagedObjectContext *)mainContext {
    if (_mainContext != nil) {
        return _mainContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        _mainContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _mainContext.undoManager = nil;
        [_mainContext setPersistentStoreCoordinator:coordinator];
    }

    return _mainContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  子线程管理对象
 *
 *  @return 返回子线程管理对象
 */
- (NSManagedObjectContext *)privateContext
{
    if (_privateContext != nil) {
        return _privateContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _privateContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
        _privateContext.undoManager = nil;
        [_privateContext setPersistentStoreCoordinator:coordinator];
    }
    return _privateContext;
}

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  读取数据实体模型
 *
 *  @return 返回数据实体模型
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];

    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }

    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

    NSError *error = nil;
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"coreData.sqlite"];
    self.storeUrl = storeURL;

    NSDictionary *persistentStoreOptions = [self persistentStoreOptions];

    NSPersistentStore *persistanceStore = [_persistentStoreCoordinator
                                           addPersistentStoreWithType:NSSQLiteStoreType
                                           configuration:nil
                                           URL:storeURL
                                           options:persistentStoreOptions
                                           error:&error];

    self.persistentStore = persistanceStore;

     NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (!persistanceStore) {
        error = nil;
        if ([self removeSQLiteFilesAtStoreURL:storeURL error:&error]) {
            self.persistentStore = [_persistentStoreCoordinator
                                    addPersistentStoreWithType:NSSQLiteStoreType
                                    configuration:nil
                                    URL:storeURL
                                    options:persistentStoreOptions
                                    error:&error];
        }else{
             NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setObject:@"Failed to initialize the application's saved data" forKey:NSLocalizedDescriptionKey];
            [dict setObject:failureReason forKey:NSLocalizedFailureReasonErrorKey];
            [dict setObject:error forKey:NSUnderlyingErrorKey];

             error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }

    return _persistentStoreCoordinator;
}

- (BOOL)removeSQLiteFilesAtStoreURL: (NSURL *)storeURL
                              error: (NSError * __autoreleasing *)error
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *storeDirectory = [storeURL URLByDeletingLastPathComponent];
    NSDirectoryEnumerator *enumerator = [fileManager enumeratorAtURL:storeDirectory
                                          includingPropertiesForKeys:nil
                                                             options:0
                                                        errorHandler:nil];

    NSString *storeName = [storeURL.lastPathComponent stringByDeletingPathExtension];
    for (NSURL *url in enumerator) {

        if ([url.lastPathComponent hasPrefix:storeName] == NO) {
            continue;
        }

        NSError *fileManagerError = nil;
        if ([fileManager removeItemAtURL:url error:&fileManagerError] == NO) {

            if (error != NULL) {
                *error = fileManagerError;
            }

            return NO;
        }
    }

    return YES;
}

- (NSDictionary *)persistentStoreOptions {
    return @{NSInferMappingModelAutomaticallyOption: @YES,
             NSMigratePersistentStoresAutomaticallyOption: @YES,
             NSSQLitePragmasOption: @{@"synchronous": @"NO"}};
}

#pragma mark - Application's Documents directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
