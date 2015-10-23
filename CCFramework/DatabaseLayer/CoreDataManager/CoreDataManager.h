//
//  CoreDataManager.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^CoreDataManagerBlock)(NSObject *requestData,BOOL IsError);

@interface CoreDataManager : NSObject

//单列模式
+(id)sharedlnstance;

#pragma mark - Core Data Saving support
-(void)saveContext;

/**
 *  @author CC, 15-09-22
 *
 *  @brief  数据库名称
            继承子类必须实现
 *
 *  @return 返回数据库名称
 */
- (NSString *)coredataName;

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
-(void)insertCoreData:(NSString *)tableName DataDic:(NSDictionary *)dataDic;

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
-(void)insertCoreData:(NSString *)tableName DataArray:(NSArray *)dataArray;

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
-(void)deleteCoreData:(NSString *)tableName;

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
-(void)deleteCoreData:(NSString *)tableName Condition:(NSString *)condition;

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
-(void)deleteCoreData:(NSString *)tableName ConditionID:(NSManagedObjectID *)conditionID;

#pragma mark - 修改
/**
 *  @author CC, 15-09-25
 *
 *  @brief  批量修改属性值
 *
 *  @param tableName      表名
 *  @param ColumnKeyValue 字段名 value 字段值
 */
-(void)batchUpdataCoredData: (NSString *)tableName
             ColumnKeyValue: (NSDictionary *)columnDic;

/**
 *  @author CC, 2015-10-23
 *
 *  @brief  修改对象及子项
 *          操作方式 属性 条件 值（editDataArray 对象中获取Key值）
 *
 *  @param tableName      表名
 *  @param conditionKey   条件字段
 *  @param condition      调价今年
 *  @param conditionValue 条件值的Key
 *  @param editDataArray  编辑的对象
 */
- (void)updateCoreData: (NSString *)tableName
          ConditionKey: (NSString *)conditionKey
             Condition: (NSString *)condition
        ConditionValue: (NSString *)conditionValue
         EditDataArray: (NSArray *)editDataArray;

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  对整个对象修改
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *  @param editData  字段名 value 字段值
 *
 *  @since 1.0
 */
-(void)updateCoreData: (NSString *)tableName
            Condition: (NSString *)condition
             EditData: (NSDictionary *)editData;

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
-(void)updateCoreData: (NSString *)tableName
            Condition: (NSString *)condition
        AttributeName: (NSString *)attributeName
       AttributeValue: (NSString *)attributeValue;

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
-(void)updateCoreData: (NSString *)tableName
        EditDataArray: (NSArray *)editDataAry;

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
-(NSArray *)selectCoreData: (NSString *)tableName;

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
-(NSArray *)selectCoreData: (NSString *)tableName
                 Condition: (NSString *)condition;

/**
 *  @author CC, 2015-10-23
 *
 *  @brief  查询对象
 *          条件查询与排序
 *
 *  @param tableName 表名
 *  @param condition 查询条件
 *  @param key       排序字段
 *  @param ascending 是否升序
 *
 *  @return 返回结果集
 */
- (NSArray *)selectCoreData: (NSString *)tableName
                  Condition: (NSString *)condition
                sortWithKey: (NSString *)key
                  ascending: (BOOL)ascending;

/**
 *  @author CC, 2015-07-24
 *
 *  @brief  查询表所有信息排序
 *
 *  @param tableName 表名
 *  @param key       分类键
 *  @param ascending 是否升序
 *
 *  @return 返回结果集
 *
 *  @since 1.0
 */
-(NSArray *)selectCoreData: (NSString *)tableName
               sortWithKey: (NSString *)key
                 ascending: (BOOL)ascending;

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
-(NSArray *)selectCoreData: (NSString *)tableName
                  PageSize: (int)pageSize
                 AndOffset: (int)currentPage;

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
-(NSArray *)selectCoreData: (NSString *)tableName
                 Condition: (NSString *)condition
                  PageSize: (int)pageSize
                 AndOffset: (int)currentPage;
@end
