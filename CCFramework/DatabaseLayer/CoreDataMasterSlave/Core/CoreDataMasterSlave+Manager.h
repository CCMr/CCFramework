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
- (void)insertCoreData: (NSString *)tableName
               DataDic: (NSDictionary *)dataDic;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName 表名
 *  @param dataArray 新增数据
 */
-(void)insertCoreData: (NSString *)tableName
            DataArray: (NSArray *)dataArray;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  新增对个对象
 *
 *  @param tableName  表名
 *  @param dataArray  新增数据
 *  @param completion 完成回调函数
 */
- (void)insertCoreData: (NSString *)tableName
             DataArray: (NSArray *)dataArray
            completion: (void(^)(NSError *error))completion;

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
-(void)batchUpdataCoredData: (NSString *)tableName
             ColumnKeyValue: (NSDictionary *)columnDic;

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
- (void)updateCoreData: (NSString *)tableName
          ConditionKey: (NSString *)conditionKey
             Condition: (NSString *)condition
        ConditionValue: (NSString *)conditionValue
         EditDataArray: (NSArray *)editDataArray;

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
- (void)updateCoreData: (NSString *)tableName
          ConditionKey: (NSString *)conditionKey
             Condition: (NSString *)condition
        ConditionValue: (NSString *)conditionValue
         EditDataArray: (NSArray *)editDataArray
            completion: (void(^)(NSError *error))completion;

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
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
              EditData: (NSDictionary *)editData;

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
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
              EditData: (NSDictionary *)editData
            completion: (void(^)(NSError *error))completion;

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
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
         AttributeName: (NSString *)attributeName
        AttributeValue: (NSString *)attributeValue;

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
- (void)updateCoreData: (NSString *)tableName
             Condition: (NSString *)condition
         AttributeName: (NSString *)attributeName
        AttributeValue: (NSString *)attributeValue
            completion: (void(^)(NSError *error))completion;

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
- (void)updateCoreData: (NSString *)tableName
           ConditionID: (NSManagedObjectID *)conditionID
              EditData: (NSDictionary *)editData;

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
- (void)updateCoreData: (NSString *)tableName
           ConditionID: (NSManagedObjectID *)conditionID
              EditData: (NSDictionary *)editData
            completion: (void(^)(NSError *error))completion;

@end