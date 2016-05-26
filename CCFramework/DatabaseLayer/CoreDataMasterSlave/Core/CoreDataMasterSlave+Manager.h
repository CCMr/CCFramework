//
//  CoreDataMasterSlave+Manager.h
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

#import "CoreDataMasterSlave.h"

@interface CoreDataMasterSlave (Manager)

@end

#pragma mark - Create 新增对象
@interface CoreDataMasterSlave (Create)

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
+ (void)cc_insertCoreData:(NSString *)tableName
                  DataDic:(NSDictionary *)dataDic;

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  数据库新增
 *
 *  @param tableName  表名
 *  @param dataDic    新增数据
 *  @param completion 完成回调函数
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                  DataDic:(NSDictionary *)dataDic
               completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                DataArray:(NSArray *)dataArray;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName  表名
 *  @param dataArray  新增数据
 *  @param completion 完成回调函数
 */
+ (void)cc_insertCoreData:(NSString *)tableName
                DataArray:(NSArray *)dataArray
               completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  新增对象并且返回
 *
 *  @param tableName 表名
 *  @param dataDic   新增数据
 *
 *  @return 返回当前对象
 */
+ (id)cc_insertCoreDataWithDic:(NSString *)tableName
                       DataDic:(NSDictionary *)dataDic;


/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  新增对象并且返回当前对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 *
 *  @return 返回对象集合
 */
+ (NSArray *)cc_insertCoreDataWithArray:(NSString *)tableName
                              DataArray:(NSArray *)dataArray;

/**
 *  @author CC, 16-05-25
 *  
 *  @brief   新增对象并且返回当前对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 *
 *  @return 返回对象集合
 */
+ (NSArray *)cc_insertCoreDataWithArrayObject:(NSString *)tableName
                                    DataArray:(NSArray *)dataArray;

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param data       数据源
 *
 *  @return 返回新增或更新对象
 */
+ (id)cc_insertOrUpdateWtihData:(NSString *)tableName
                     PrimaryKey:(NSString *)primaryKey
                       WithData:(NSDictionary *)data;

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param data       数据源
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象
 */
+ (id)cc_insertOrUpdateWtihData:(NSString *)tableName
                     PrimaryKey:(NSString *)primaryKey
                       WithData:(NSDictionary *)data
                      inContext:(NSManagedObjectContext *)context;

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArray:(NSString *)tableName
                                 PrimaryKey:(NSString *)primaryKey
                              WithDataArray:(NSArray *)dataArray;

/**
 *  @author CC, 2015-11-30
 *  
 *  @brief  新增或更新数据(字典)
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArray:(NSString *)tableName
                                 PrimaryKey:(NSString *)primaryKey
                              WithDataArray:(NSArray *)dataArray
                                  inContext:(NSManagedObjectContext *)context;

/**
 *  @author CC, 16-05-25
 *  
 *  @brief  新增或更新数据(返回对象模型)
 *
 *  @param tableName  表名
 *  @param primaryKey 主键
 *  @param dataArray  数据集合
 *  @param context    管理对象
 *
 *  @return 返回新增或更新对象集
 */
+ (NSArray *)cc_insertOrUpdateWtihDataArrayObject:(NSString *)tableName
                                       PrimaryKey:(NSString *)primaryKey
                                    WithDataArray:(NSArray *)dataArray
                                        inContext:(NSManagedObjectContext *)context;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对象及子对象
 *
 *  @param data        对象数据
 *  @param primaryKeys 主键
 *  @param context     管理对象
 *
 *  @return 返回新增对象
 */
+ (id)objctWithData:(NSString *)tableName
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context;


@end

#pragma mark - Removed 删除对象
@interface CoreDataMasterSlave (Removed)

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 */
+ (void)cc_RemovedAll:(NSString *)tableName;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除所有对象
 *
 *  @param completion 完成回调函数
 */
+ (void)cc_RemovedAll:(NSString *)tableName
           completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 */
+ (void)cc_RemovedManagedObjectID:(NSString *)tableName
                  ManagedObjectID:(NSManagedObjectID *)conditionID;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param conditionID 对象ID
 *  @param completion  完成回调函数
 */
+ (void)cc_RemovedManagedObjectID:(NSString *)tableName
                  ManagedObjectID:(NSManagedObjectID *)conditionID
                       completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-11-16
 *  
 *  @brief  删除对象
 *
 *  @param tableName     表名
 *  @param arrayObjectID 集合对象ObjectID
 */
+ (void)cc_RemovedManagedObjectIds:(NSString *)tableName
                   ManagedObjectId:(NSArray *)arrayObjectID;

/**
 *  @author CC, 2015-11-16
 *  
 *  @brief  删除对象
 *
 *  @param tableName     表名
 *  @param arrayObjectID 集合对象ObjectID
 *  @param completion    完成回调
 */
+ (void)cc_RemovedManagedObjectIds:(NSString *)tableName
                   ManagedObjectId:(NSArray *)arrayObjectID
                        completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  条件删除数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 */
+ (void)cc_RemovedWithCondition:(NSString *)tableName
                      Condition:(NSString *)condition;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  条件删除数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 */
+ (void)cc_RemovedWithCondition:(NSString *)tableName
                      Condition:(NSString *)condition
                     Completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  删除对象
 *
 *  @param propertyName 属性名
 *  @param value        属性值
 */
+ (void)cc_RemovedProperty:(NSString *)tableName
              PropertyName:(NSString *)propertyName
                   toValue:(id)value;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 */
+ (void)cc_RemovedMultiProperty:(NSString *)tableName
                  MultiProperty:(NSDictionary *)propertyKeyValues;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  多属性删除
 *
 *  @param propertyKeyValues 属性名与值
 *  @param completion        完成回调函数
 */
+ (void)cc_RemovedMultiProperty:(NSString *)tableName
                  MultiProperty:(NSDictionary *)propertyKeyValues
                     completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 16-05-20
 *  
 *  @brief  删除多条数据(根据key与value)
 *
 *  @param tableName          表名
 *  @param conditionKeyValues 属性名与值
 */
+ (void)cc_RemovedMultipleCondition:(NSString *)tableName
                     MultiCondition:(NSArray *)conditionKeyValues;

/**
 *  @author CC, 16-05-20
 *  
 *  @brief  删除多条数据(根据key与value)
 *
 *  @param tableName          表名
 *  @param conditionKeyValues 属性名与值
 *  @param completion         完成回调函数
 */
+ (void)cc_RemovedMultipleCondition:(NSString *)tableName
                     MultiCondition:(NSArray *)conditionKeyValues
                         completion:(void (^)(NSError *error))completion;

@end

#pragma mark - Modify 修改对象

@interface CoreDataMasterSlave (Modify)

/**
 *  @author 2015-10-25
 *
 *  @brief  批量修改属性值
 *
 *  @param tableName 表名
 *  @param key       字段名
 *  @param value     字段值
 */
+ (void)cc_batchUpdataCoredData:(NSString *)tableName
                 ColumnKeyValue:(NSDictionary *)columnDic;

/**
 *  @author CC, 2015-10-25
 *
 *  @brief  修改对象及子项
 *          操作方式 属性 条件 值（editDataArray 对象中获取Key值）
 *
 *  @param tableName      表名
 *  @param conditionKey   条件字段
 *  @param condition      条件
 *  @param conditionValue 条件值的Key
 *  @param editDataArray  编辑的对象
 */
+ (void)cc_updateCoreData:(NSString *)tableName
             ConditionKey:(NSString *)conditionKey
                Condition:(NSString *)condition
           ConditionValue:(NSString *)conditionValue
            EditDataArray:(NSArray *)editDataArray;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象及子项
 *
 *  @param tableName      表名
 *  @param conditionKey   条件字段
 *  @param condition      条件
 *  @param conditionValue 条件值
 *  @param editDataArray  编辑属性
 *  @param completion     完成回调函数
 */
+ (void)cc_updateCoreData:(NSString *)tableName
             ConditionKey:(NSString *)conditionKey
                Condition:(NSString *)condition
           ConditionValue:(NSString *)conditionValue
            EditDataArray:(NSArray *)editDataArray
               completion:(void (^)(NSError *error))completion;

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
+ (void)cc_updateCoreData:(NSString *)tableName
                Condition:(NSString *)condition
                 EditData:(NSDictionary *)editData;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象及子项
 *
 *  @param tableName  表名
 *  @param condition  条件
 *  @param editData   编辑属性
 *  @param completion 完成回调函数
 */
+ (void)cc_updateCoreData:(NSString *)tableName
                Condition:(NSString *)condition
                 EditData:(NSDictionary *)editData
               completion:(void (^)(NSError *error))completion;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象属性
 *
 *  @param tableName      表名
 *  @param condition      条件
 *  @param attributeName  属性名
 *  @param attributeValue 属性值
 */
+ (void)cc_updateCoreData:(NSString *)tableName
                Condition:(NSString *)condition
            AttributeName:(NSString *)attributeName
           AttributeValue:(id)attributeValue;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  修改对象属性
 *
 *  @param tableName      表名
 *  @param condition      条件
 *  @param attributeName  属性名
 *  @param attributeValue 属性值
 *  @param completion     完成回调函数
 */
+ (void)cc_updateCoreData:(NSString *)tableName
                Condition:(NSString *)condition
            AttributeName:(NSString *)attributeName
           AttributeValue:(id)attributeValue
               completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-10-23
 *
 *  @brief  主键修改数据对象及子项
 *
 *  @param context     操作对象
 *  @param tableName   表名
 *  @param conditionID 主键ID
 *  @param editData    编辑的数据集
 */
+ (void)cc_updateCoreData:(NSString *)tableName
              ConditionID:(NSManagedObjectID *)conditionID
                 EditData:(NSDictionary *)editData;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  主键ID修改对象及子项
 *
 *  @param tableName   表名
 *  @param conditionID 主键ID
 *  @param editData    编辑属性
 *  @param completion  完成回调函数
 */
+ (void)cc_updateCoreData:(NSString *)tableName
              ConditionID:(NSManagedObjectID *)conditionID
                 EditData:(NSDictionary *)editData
               completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  更新或者添加数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param data        数据源
 *
 *  @return 返回更新或者添加之后的对象
 */
+ (id)cc_updateORInsertCoreData:(NSString *)tableName
                    PrimaryKeys:(NSString *)primaryKeys
                           Data:(NSDictionary *)data;

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  更新或者添加数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param data        数据源
 *  @param completion  完成回调
 *
 *  @return 返回更新或者添加之后的对象
 */
+ (id)cc_updateORInsertCoreData:(NSString *)tableName
                    PrimaryKeys:(NSString *)primaryKeys
                           Data:(NSDictionary *)data
                     completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  更新或者添加数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param dataAry     数据源
 *
 *  @return 返回更新或者添加之后的对象集合
 */
+ (NSArray *)cc_updateORInsertCoreData:(NSString *)tableName
                           PrimaryKeys:(NSString *)primaryKeys
                               DataAry:(NSArray *)dataAry;

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  更新或者添加数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param dataAry     数据源
 *  @param completion  完成回调
 *
 *  @return 返回更新或者添加之后的对象集合
 */
+ (NSArray *)cc_updateORInsertCoreData:(NSString *)tableName
                           PrimaryKeys:(NSString *)primaryKeys
                               DataAry:(NSArray *)dataAry
                            completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-11-23
 *  
 *  @brief   更新或添加数据
 *
 *  @param tableName    表名
 *  @param primaryKey   主键
 *  @param primaryValue 主键值
 *  @param dataAry      数据
 *  @param completion   完成回调
 *
 *  @return 返回更新或创建之后的对象集合
 */
+ (NSArray *)cc_updateORInsertCoreData:(NSString *)tableName
                            PrimaryKey:(NSString *)primaryKey
                          PrimaryValue:(id)primaryValue
                               DataDic:(NSDictionary *)data;

/**
 *  @author CC, 2015-11-23
 *  
 *  @brief   更新或添加数据
 *
 *  @param tableName    表名
 *  @param primaryKey   主键
 *  @param primaryValue 主键值
 *  @param dataAry      数据
 *  @param completion   完成回调
 *
 *  @return 返回更新或创建之后的对象集合
 */
+ (NSArray *)cc_updateORInsertCoreData:(NSString *)tableName
                            PrimaryKey:(NSString *)primaryKey
                          PrimaryValue:(id)primaryValue
                               DataAry:(NSArray *)dataAry;
/**
 *  @author CC, 2015-11-23
 *  
 *  @brief   更新或添加数据
 *
 *  @param tableName    表名
 *  @param primaryKey   主键
 *  @param primaryValue 主键值
 *  @param dataAry      数据
 *  @param completion   完成回调
 *
 *  @return 返回更新或创建之后的对象集合
 */
+ (NSArray *)cc_updateORInsertCoreData:(NSString *)tableName
                            PrimaryKey:(NSString *)primaryKey
                          PrimaryValue:(id)primaryValue
                               DataAry:(NSArray *)dataAry
                            completion:(void (^)(NSError *error))completion;

/**
 *  @author CC, 2015-11-23
 *  
 *  @brief  更新或新增数据
 *
 *  @param tableName    表名
 *  @param primaryKey   主键
 *  @param primaryValue 主键值
 *  @param data         数据源
 *  @param context      管理对象
 *
 *  @return 返回更新或创建
 */
+ (id)objctWithData:(NSString *)tableName
         PrimaryKey:(NSString *)primaryKey
       PrimaryValue:(id)primaryValue
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context;

/**
 *  @author CC, 2015-11-05
 *  
 *  @brief  更新或新增数据
 *
 *  @param tableName   表名
 *  @param primaryKeys 主键
 *  @param data        数据源
 *  @param context     管理对象
 *
 *  @return 返回更新或创建
 */
+ (id)objctWithData:(NSString *)tableName
        PrimaryKeys:(NSString *)primaryKeys
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context;

/**
 *  @author CC, 2015-11-23
 *  
 *  @brief  更新或新增数据
 *
 *  @param tableName     表名
 *  @param subPredicates 条件
 *  @param data          数据源
 *  @param context       管理对象
 *
 *  @return 返回更新或创建
 */
+ (id)objctWithData:(NSString *)tableName
      SubPredicates:(NSArray *)subPredicates
               Data:(NSDictionary *)data
          inContext:(NSManagedObjectContext *)context;

@end

#pragma mark - Queries 查询
@interface CoreDataMasterSlave (Queries)

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询表所有数据量
 *
 *  @param tableName 表名
 *
 *  @return 返回数量
 */
+ (NSUInteger)cc_count:(NSString *)tableName;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据量
 *
 *  @param tableName 表名
 *  @param condition 条件
 *
 *  @return 返回数量
 */
+ (NSUInteger)cc_countWhere:(NSString *)tableName
             WhereCondition:(NSPredicate *)condition;

/**
 *  @author CC, 2015-10-30
 *  
 *  @brief  自增长ID
 *
 *  @param tableName    表名
 *  @param propertyName 自增长字段
 *
 *  @return 返回增长ID
 */
+ (NSInteger)cc_autoincrement:(NSString *)tableName
        AutoincrementProperty:(NSString *)propertyName;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询所有数据
 *
 *  @param tableName 表名
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                     Condition:(NSPredicate *)condition;

/**
 *  @author CC, 2015-11-27
 *  
 *  @brief  查询数据跟对象ID
 *
 *  @param tableName       表名
 *  @param managedObjectId 对象ID
 *
 *  @return 返回匹配结果
 */
+ (id)cc_selectCoreData:(NSString *)tableName
        ManagedObjectId:(NSManagedObjectID *)managedObjectId;

/**
 *  @author CC, 2015-11-27
 *  
 *  @brief  查询数据根据对象ID
 *
 *  @param tableName     表名
 *  @param arrayObjectID 对象ID集合
 *
 *  @return 返回匹配结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
           WithManagedObjectId:(NSArray *)arrayObjectID;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据
 *
 *  @param tableName 表名
 *  @param condition 条件
 *  @param handler   完成回调函数
 */
+ (void)cc_selectCoreData:(NSString *)tableName
                Condition:(NSPredicate *)condition
                  Handler:(void (^)(NSError *error, NSArray *requestResults))handler;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询所有数据并且排序
 *
 *  @param tableName 表名
 *  @param key       排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询数据并排序
 *
 *  @param tableName 表名
 *  @param key       排序字段
 *  @param ascending 是否升序
 *  @param condition 条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending
                     Condition:(NSPredicate *)condition;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询分页
 *
 *  @param tableName   表名
 *  @param pageSize    页数
 *  @param currentPage 页码
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询分页
 *
 *  @param tableName   表名
 *  @param pageSize    页数
 *  @param currentPage 页码
 *  @param condition   查询条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage
                     Condition:(NSPredicate *)condition;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  查询排序分页
 *
 *  @param tableName   表名
 *  @param key         排序字段
 *  @param ascending   是否升序
 *  @param pageSize    页数
 *  @param currentPage 页码
 *  @param condition   查询条件
 *
 *  @return 返回结果集
 */
+ (NSArray *)cc_selectCoreData:(NSString *)tableName
                   sortWithKey:(NSString *)key
                     ascending:(BOOL)ascending
                    fetchLimit:(NSInteger)pageSize
                   fetchOffset:(NSInteger)currentPage
                     Condition:(NSPredicate *)condition;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  属性查询
 *
 *  @param tableName 表名
 *  @param property  条件属性
 *  @param value     属性值
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty:(NSString *)tableName
                 PropertyName:(NSString *)property
                      equalTo:(id)value;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  属性查询排序
 *
 *  @param tableName 表名
 *  @param property  条件属性
 *  @param value     属性值
 *  @param keyPath   排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty:(NSString *)tableName
                 PropertyName:(NSString *)property
                      equalTo:(id)value
                sortedKeyPath:(NSString *)keyPath
                    ascending:(BOOL)ascending;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param property    条件属性
 *  @param value       属性值
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   加载筛选数据数
 *  @param fetchLimit  限定查询结果数据量
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_whereProperty: (NSString *)tableName
                 PropertyName: (NSString *)property
                      equalTo: (id)value
                sortedKeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset;

/**
 *  @author CC, 2015-10-26
 *
 *  @brief  分页查询
 *
 *  @param tableName   表名
 *  @param keyPath     排序字段
 *  @param ascending   是否升序
 *  @param batchSize   加载筛选数据数
 *  @param fetchLimit  限定查询结果数据量
 *  @param fetchOffset 游标偏移量，从游标开始读取数据
 *  @param condition   条件
 *
 *  @return 返回查询结果集
 */
+ (NSArray *)cc_sortedKeyPath: (NSString *)tableName
                      KeyPath: (NSString *)keyPath
                    ascending: (BOOL)ascending
               fetchBatchSize: (NSUInteger)batchSize
                   fetchLimit: (NSUInteger)fetchLimit
                  fetchOffset: (NSUInteger)fetchOffset
                        where: (NSPredicate *)condition;

@end