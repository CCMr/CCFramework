//
//  CoreDataManager.m
//  CC
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
#import "CCNSManagedObject.h"

@interface CoreDataManager()

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, strong) NSManagedObjectContext *privateContext;

@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation CoreDataManager

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  单列模式
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
+ (id)sharedlnstance
{
    static CoreDataManager *_sharedlnstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedlnstance = [[self alloc] init];
    });
    return _sharedlnstance;
}

- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    self.managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [self.managedObjectContext setPersistentStoreCoordinator:coordinator];
    return self.managedObjectContext;
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
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

    return _persistentStoreCoordinator;
}

/**
 *  @author CC, 15-09-22
 *
 *  @brief  数据库名称
 *          继承子类必须实现
 *
 *  @return 返回数据库名称
 */
- (NSString *)coredataName
{
    return @"CoreData";
}

- (NSManagedObjectModel *)managedObjectModel
{
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil)
        return _managedObjectModel;

    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:[self coredataName] withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];

    return _managedObjectModel;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  保存对象
 */
- (void)saveContext
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - sqlile创建路径
- (NSString *)PathForDocuments:(NSString *)filename inDir:(NSString *)dir
{
    return [[self DirectoryForDocuments:dir] stringByAppendingPathComponent:filename];
}

- (NSString *)DirectoryForDocuments:(NSString *)dir
{
    NSError* error;
    NSString* path = [[self DocumentPath] stringByAppendingPathComponent:dir];

    if(![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
        NSLog(@"create dir error: %@",error.debugDescription);
    return path;
}

- (NSString *)DocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

#pragma mark - 初始化对象
/**
 *  @author CC, 2015-07-24
 *
 *  @brief  初始化查询对象
 *
 *  @param tableName 表名
 *
 *  @return 返回查询条件
 *
 *  @since 1.0
 */
- (NSFetchRequest *)InitFetchRequest:(NSString *)tableName
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext]];

    return fetchRequest;
}

#pragma mark - 增加
/**
 *  @author CC, 2015-07-24
 *
 *  @brief  数据库新增
 *
 *  @param tableName 表明
 *  @param dataDic   对象
 *
 *  @since 1.0
 */
- (void)insertCoreData:(NSString *)tableName DataDic:(NSDictionary *)dataDic
{
    NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.managedObjectContext];
    for (NSString *key in dataDic.allKeys) {
        if ([[dataDic objectForKey:key] isKindOfClass:[NSArray class]])
        {
            NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext] relationshipsByName] objectForKey:key];
            [self RecursiveCategory: entity
                       Relationship: relationship
                    ForeignKeyValue: [dataDic objectForKey:relationship.inverseRelationship.name]
                          DataArray: [dataDic objectForKey:key]
             inManagedObjectContext: self.managedObjectContext];
        }else{
            [entity setValue:[dataDic objectForKey:key] forKey:key];
        }
    }

    NSError *error = nil;
    if ([self.managedObjectContext hasChanges]) {
        if(![self.managedObjectContext save:&error])
            NSLog(@"%@ insertNewObject Error:%@",tableName,[error localizedDescription]);
    }
}

-(void)insertCoreDatas:(NSString *)tableName DataArray:(NSArray *)dataArray
{
    NSPersistentStoreRequest *request = [[NSPersistentStoreRequest alloc] init];
    request.affectedStores = dataArray;
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  数据库新增多个对象
 *
 *  @param tableName 表名
 *  @param dataArray 对象数组
 *
 *  @since 1.0
 */
-(void)insertCoreData: (NSString *)tableName
            DataArray: (NSArray *)dataArray
{
    if (!dataArray.count) return;

    self.privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.privateContext setParentContext:self.managedObjectContext];

    for (NSDictionary *dic in dataArray)
    {
        NSManagedObject *entity = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:self.privateContext];
        for (NSString *key in dic.allKeys) {
            if ([[dic objectForKey:key] isKindOfClass:[NSArray class]]){
                NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:self.privateContext] relationshipsByName] objectForKey:key];

                [self RecursiveCategory: entity
                           Relationship: relationship
                        ForeignKeyValue: [dic objectForKey:relationship.inverseRelationship.name]
                              DataArray: [dic objectForKey:key]
                 inManagedObjectContext: self.privateContext];
            }else{
                [entity setValue:[dic objectForKey:key] forKey:key];
            }
        }
    }

    [self.privateContext performBlock:^{
        NSError *error = nil;
        if ([self.privateContext hasChanges]) {
            if(![self.privateContext save:&error])
                NSLog(@"%@ insertNewObject Error:%@",tableName,[error localizedDescription]);
        }
    }];
}

/**
 *  @author CC, 2015-10-22
 *
 *  @brief  递归关联对象新增
 *
 *  @param entity          上级对象
 *  @param relationship    子对象
 *  @param foreignKeyValue 子对象键
 *  @param dataArray       子对象值
 *  @param context         核心处理对象
 */
- (void)RecursiveCategory: (NSManagedObject *)entity
             Relationship: (NSRelationshipDescription *)relationship
          ForeignKeyValue: (NSString *)foreignKeyValue
                DataArray: (NSArray *)dataArray
   inManagedObjectContext: (NSManagedObjectContext *)context
{
    NSMutableSet *SonCategory = [NSMutableSet set];
    //    NSInteger count = [[self selectCoreData:[[relationship destinationEntity] name]] count]; //自定义增长ID
    for (NSDictionary *dic in dataArray) {
        NSManagedObject *entitySon = [NSEntityDescription insertNewObjectForEntityForName:[[relationship destinationEntity] name] inManagedObjectContext:context];

        //有自定义关联外键
        if (foreignKeyValue)
            [entitySon setValue:foreignKeyValue forKey:relationship.name];//设置当前主键
        [entitySon setValue:entity forKey:relationship.inverseRelationship.name];

        for (NSString *key in dic.allKeys) {
            if ([[dic objectForKey:key] isKindOfClass:[NSArray class]])
            {
                NSRelationshipDescription *CategoryRelationship = [[[NSEntityDescription entityForName:[[relationship destinationEntity] name] inManagedObjectContext:context] relationshipsByName] objectForKey:key];

                [self RecursiveCategory: entitySon
                           Relationship: CategoryRelationship
                        ForeignKeyValue: [dic objectForKey:CategoryRelationship.inverseRelationship.name]
                              DataArray: [dic objectForKey:key]
                 inManagedObjectContext: context];
            }else{
                [entitySon setValue:[dic objectForKey:key] forKey:key];
            }
        }
        [SonCategory addObject:entitySon];
    }
    [entity setValue:SonCategory forKey:relationship.name];
}

#pragma mark - 删除
/**
 *  @author CC, 2015-07-24
 *
 *  @brief  清空表数据
 *
 *  @param tableName 表名
 *
 *  @since 1.0
 */
- (void)deleteCoreData:(NSString *)tableName
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    [fetchRequest setIncludesPropertyValues:NO];

    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.managedObjectContext deleteObject:obj];
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Clear %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  删除某条数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 *
 *  @since 1.0
 */
- (void)deleteCoreData:(NSString *)tableName Condition:(NSString *)condition
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    if (condition)
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];

    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [self.managedObjectContext deleteObject:obj];
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Delete %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

/**
 *  @author CC, 2015-05-21 14:05:14
 *
 *  @brief  ID主键删除对象
 *
 *  @param tableName   表名
 *  @param conditionID 对象主键ID
 *
 *  @since 0.1
 */
-(void)deleteCoreData:(NSString *)tableName ConditionID:(NSManagedObjectID *)conditionID
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((NSManagedObject *)obj).objectID isEqual:conditionID])
                [self.managedObjectContext deleteObject:obj];
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Delete %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

#pragma mark - 修改
/**
 *  @author CC, 15-09-25
 *
 *  @brief  批量修改属性值
 *
 *  @param tableName 表名
 *  @param key       字段名
 *  @param value     字段值
 */
-(void)batchUpdataCoredData: (NSString *)tableName
             ColumnKeyValue: (NSDictionary *)columnDic
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext];

    // Initialize Batch Update Request
    NSBatchUpdateRequest *batchUpdateRequest = [[NSBatchUpdateRequest alloc] initWithEntity:entityDescription];

    // Configure Batch Update Request
    [batchUpdateRequest setResultType:NSUpdatedObjectIDsResultType];
    [batchUpdateRequest setPropertiesToUpdate:columnDic];

    // Execute Batch Request
    NSError *batchUpdateRequestError = nil;
    NSBatchUpdateResult *batchUpdateResult = (NSBatchUpdateResult *)[self.managedObjectContext executeRequest:batchUpdateRequest error:&batchUpdateRequestError];

    if (batchUpdateRequestError) {
        NSLog(@"%@, %@", batchUpdateRequestError, batchUpdateRequestError.localizedDescription);
    } else {
        // Extract Object IDs
        NSArray *objectIDs = batchUpdateResult.result;

        for (NSManagedObjectID *objectID in objectIDs) {
            // Turn Managed Objects into Faults
            NSManagedObject *managedObject = [self.managedObjectContext objectWithID:objectID];

            if (managedObject) {
                [self.managedObjectContext refreshObject:managedObject mergeChanges:NO];
            }
        }
    }
}


/**
 *  @author CC, 2015-07-24
 *
 *  @brief  根据条件修改对象及其子项
 *
 *  @param tableName     表名
 *  @param condition     查询条件
 *  @param editDataArray 修改条件
 *
 *  @since 1.0
 */
- (void)updateCoreData:(NSString *)tableName Condition:(NSString *)condition EditDataArray:(NSArray *)editDataArray
{
    for (NSDictionary *d in editDataArray)
        [self updateCoreData:tableName Condition:condition EditData:d];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  对整个对象修改
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *  @param editData  修改对象
 *
 *  @since 1.0
 */
- (void)updateCoreData:(NSString *)tableName Condition:(NSString *)condition EditData:(NSDictionary *)editData
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    [fetchRequest setReturnsObjectsAsFaults:NO];

    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            for (NSString *key in editData.allKeys) {
                if ([[editData objectForKey:key] isKindOfClass:[NSArray class]]){
                    NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext] relationshipsByName] objectForKey:key];
                    for (NSDictionary *childDic in [editData objectForKey:key])
                        [self updateCoreData:[[relationship destinationEntity] name] ConditionID:[childDic objectForKey:@"objectID"] EditData:childDic];
                }else
                    [obj setValue:[editData objectForKey:key] forKey:key];
            }
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Update %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  对查询的对象 针对属性修改
 *
 *  @param tableName      表名
 *  @param condition      查询条件
 *  @param attributeName  属性
 *  @param attributeValue 值
 *
 *  @since 1.0
 */
- (void)updateCoreData:(NSString *)tableName Condition:(NSString *)condition AttributeName:(NSString *)attributeName AttributeValue:(NSString *)attributeValue
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj setValue:attributeValue forKey:attributeName];
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Update %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  多个修改
 *
 *  @param tableName   表名
 *  @param editDataAry 数组对象
 *
 *  @since 1.0
 */
- (void)updateCoreData:(NSString *)tableName EditDataArray:(NSArray *)editDataAry
{
    for (NSDictionary *dic in editDataAry)
        [self updateCoreData:tableName ConditionID:[dic objectForKey:@"objectID"] EditData:dic];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  根据对象主键修改对象及其子项
 *
 *  @param tableName   表名
 *  @param conditionID 主键ID
 *  @param editData    对象
 *
 *  @since 1.0
 */
- (void)updateCoreData:(NSString *)tableName ConditionID:(NSManagedObjectID *)conditionID EditData:(NSDictionary *)editData
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    NSError *error = nil;
    NSArray *datas = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (!error && datas && [datas count]) {
        [datas enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([((NSManagedObject *)obj).objectID isEqual:conditionID]) {
                for (NSString *key in editData.allKeys) {
                    if ([[editData objectForKey:key] isKindOfClass:[NSArray class]]){
                        NSRelationshipDescription *relationship = [[[NSEntityDescription entityForName:tableName inManagedObjectContext:self.managedObjectContext] relationshipsByName] objectForKey:key];
                        for (NSDictionary *childDic in [editData objectForKey:key])
                            [self updateCoreData:[[relationship destinationEntity] name] ConditionID:[childDic objectForKey:@"objectID"] EditData:childDic];
                    }else{
                        if (![key isEqualToString:@"objectID"])
                            [obj setValue:[editData objectForKey:key] forKey:key];
                    }
                }
            }
        }];

        if (![self.managedObjectContext save:&error])
            NSLog(@"Update %@ CoreData Error : %@",tableName,[error localizedDescription]);
    }
}

#pragma mark - 查询
/**
 *  @author CC, 2015-07-24
 *
 *  @brief  查询所有对象
 *
 *  @param tableName 表名
 *
 *  @return 对象数组
 *
 *  @since 1.0
 */
- (NSArray *)selectCoreData:(NSString *)tableName
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];

    NSMutableArray *DataArray = [NSMutableArray array];
    [[self.managedObjectContext executeFetchRequest:fetchRequest error:nil] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [DataArray addObject:[self RecursiveChildren:obj]];
    }];
    return DataArray;
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  查询对象
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *
 *  @return 符合条件的对象数组
 *
 *  @since 1.0
 */
- (NSArray *)selectCoreData:(NSString *)tableName Condition:(NSString *)condition
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];

    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    NSMutableArray *DataArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [DataArray addObject:[self RecursiveChildren:obj]];
    }];
    return [[NSSet setWithArray:DataArray] allObjects];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  分类查询 暂未测试
 *
 *  @param tableName 表名
 *  @param key       分类键
 *  @param ascending <#ascending description#>
 *
 *  @return <#return value description#>
 *
 *  @since 1.0
 */
- (NSArray *)selectCoreData:(NSString *)tableName sortWithKey:(NSString *)key ascending:(BOOL)ascending
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];

    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:key ascending:ascending]];
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSMutableArray *DataArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [DataArray addObject:[self RecursiveChildren:obj]];
    }];
    return [[NSSet setWithArray:DataArray] allObjects];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  递归查询外键表
 *
 *  @param entity 子对象
 *
 *  @return 符合条件的对象
 *
 *  @since 1.0
 */
- (NSDictionary *)RecursiveChildren:(NSManagedObject *)entity
{

    NSMutableDictionary *dic = [[entity ChangedDictionary] mutableCopy];
    for (NSString *key in dic.allKeys) {
        if ([[dic objectForKey:key] isKindOfClass:[NSArray class]]) {
            NSMutableArray *array = [[dic objectForKey:key] mutableCopy];
            NSRelationshipDescription *relationship = [[entity.entity relationshipsByName] objectForKey:key];
            id values = [dic objectForKey:relationship.inverseRelationship.name];
            //自定义关联外键使用
            if (values) {
                NSArray *dataArray = [self selectCoreData:relationship.destinationEntity.name Condition:[NSString stringWithFormat:@"%@ = '%@'",relationship.name,[dic objectForKey:relationship.inverseRelationship.name]]];

                //清理关联查询出来的数据
                if (dataArray.count > 0)
                    [array removeAllObjects];

                [dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSDictionary *childrenDic = obj;
                    if ([childrenDic isKindOfClass:[NSManagedObject class]])
                        childrenDic = [self RecursiveChildren:obj];
                    [array addObject:childrenDic];
                }];
                array = [[[NSSet setWithArray:array] allObjects] mutableCopy];
                [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    if ([obj1 objectForKey:@"objectID"] > [obj2 objectForKey:@"objectID"])
                        return NSOrderedAscending;
                    if ([obj1 objectForKey:@"objectID"] < [obj2 objectForKey:@"objectID"])
                        return NSOrderedDescending;
                    return NSOrderedSame;
                }];
            }

            [dic setObject:array forKey:key];
        }
    }
    return dic;
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param pageSize    查询数量
 *  @param currentPage 页数
 *
 *  @return 符合条件的对象数组
 *
 *  @since 1.0
 */
- (NSArray *)selectCoreData:(NSString *)tableName PageSize:(int)pageSize AndOffset:(int)currentPage
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    [fetchRequest setFetchLimit:pageSize];
    [fetchRequest setFetchOffset:currentPage];

    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    NSMutableArray *DataArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [DataArray addObject:[obj ChangedDictionary]];
    }];
    return [[NSSet setWithArray:DataArray] allObjects];
}

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  条件加分页
 *
 *  @param tableName   表名
 *  @param condition   查询条件
 *  @param pageSize    查询数量
 *  @param currentPage 页数
 *
 *  @return 符合条件的对象数组
 *
 *  @since 1.0
 */
- (NSArray *)selectCoreData:(NSString *)tableName Condition:(NSString *)condition PageSize:(int)pageSize AndOffset:(int)currentPage
{
    NSFetchRequest *fetchRequest = [self InitFetchRequest:tableName];
    if (pageSize != 0 && currentPage != 0){
        [fetchRequest setFetchLimit:pageSize];
        [fetchRequest setFetchOffset:currentPage];
    }
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:condition]];
    NSArray *array = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    NSMutableArray *DataArray = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [DataArray addObject:[obj ChangedDictionary]];
    }];
    return [[NSSet setWithArray:DataArray] allObjects];
}
@end
