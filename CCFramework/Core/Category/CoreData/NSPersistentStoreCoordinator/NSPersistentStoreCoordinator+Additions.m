//
//  NSPersistentStoreCoordinator+Additions.m
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

#import "NSPersistentStoreCoordinator+Additions.h"

@implementation NSPersistentStoreCoordinator (Additions)

static NSPersistentStoreCoordinator *_sharedPersistentStore = nil;
static NSString *_dataModelName = nil;
static NSString *_storeFileName = nil;

+ (NSString *)applicationDocumentsDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

+ (void) setDataModelName: (NSString *) name withStoreName: (NSString *) storeFileName {
    _dataModelName = name;
    _storeFileName = storeFileName;
}

+(NSPersistentStoreCoordinator *) sharedPersisntentStoreCoordinator
{
    NSAssert(_dataModelName, @"Core Data model name has not been set. Use [NSPersistentStoreCoordinator setDataModelName:].");
    
    if (!_sharedPersistentStore) {
        NSString *storePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent: _storeFileName];
        NSURL *storeUrl = [NSURL fileURLWithPath:storePath];
        
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *resourcePath = [bundle resourcePath];
        NSString *modelFileName = [_dataModelName stringByAppendingPathExtension:@"momd"];
        NSString *modelPath = [resourcePath stringByAppendingPathComponent: modelFileName];
        
        NSURL *modelUrl = [NSURL fileURLWithPath: modelPath];
        
        NSManagedObjectModel *_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL: modelUrl];
        
        NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption: @(YES),
                                  NSInferMappingModelAutomaticallyOption : @(YES)};
    
        NSError *error;
        _sharedPersistentStore = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: _managedObjectModel];
        if (![_sharedPersistentStore addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
    
    return _sharedPersistentStore;
}

+ (void) setNewPresistentStore: (NSPersistentStoreCoordinator *) store
{
    _sharedPersistentStore = store;
}

@end
