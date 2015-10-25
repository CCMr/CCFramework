//
//  CoreDataManager.h
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

#import "CCCoreData.h"

@interface CoreDataManager : NSObject

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  私有管理对象
 */
@property (nonatomic, strong) NSManagedObjectContext *privateContext;
/**
 *  @author C C, 2015-10-25
 *
 *  @brief  主管理对象
 */
@property (nonatomic, strong) NSManagedObjectContext *mainContext;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  模型对象
 */
@property (nonatomic, strong) NSManagedObjectModel *managedObjectModel;

/**
 *  @author C C, 2015-10-25
 *
 *  @brief  对象管理
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  单例模式
 *
 *  @return 返回对象
 */
+ (instancetype)sharedlnstance;

/**
 *  @author CC, 2015-10-24
 *
 *  @brief  删除所有记录
 */
-(void)removeAllRecord;

@end
