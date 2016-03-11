//
//  CCKeyValueStore.h
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

@interface CCKeyValueItem : NSObject

@property(nonatomic, copy) NSString *itemId;
@property(nonatomic, copy) id itemObject;
@property(nonatomic, copy) NSDate *createdTime;

@end

@interface CCKeyValueStore : NSObject

- (id)initDBWithName:(NSString *)dbName;

- (id)initWithDBWithPath:(NSString *)dbPath;

- (void)createTableWithName:(NSString *)tableName;

- (void)clearTable:(NSString *)tableName;

- (BOOL)isExistTableWithName:(NSString *)tableName;

- (BOOL)deleteTable:(NSString *)tableName;

- (void)deleteDatabseWithDBName:(NSString *)DBName;

- (NSString *)getDBPath;

- (void)close;

- (void)putObject:(id)object withId:(NSString *)objectId intoTable:(NSString *)tableName;

- (id)getObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (CCKeyValueItem *)getYTKKeyValueItemById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)putString:(NSString *)string withId:(NSString *)stringId intoTable:(NSString *)tableName;

- (NSString *)getStringById:(NSString *)stringId fromTable:(NSString *)tableName;

- (void)putNumber:(NSNumber *)number withId:(NSString *)numberId intoTable:(NSString *)tableName;

- (NSNumber *)getNumberById:(NSString *)numberId fromTable:(NSString *)tableName;

- (NSArray *)getAllItemsFromTable:(NSString *)tableName;

- (void)deleteObjectById:(NSString *)objectId fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdArray:(NSArray *)objectIdArray fromTable:(NSString *)tableName;

- (void)deleteObjectsByIdPrefix:(NSString *)objectIdPrefix fromTable:(NSString *)tableName;

- (NSArray *)getItemsFromTable:(NSString *)tableName withRange:(NSRange)range;

@end
