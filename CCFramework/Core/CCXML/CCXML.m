//
//  CCXML.m
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

#import "CCXML.h"

@interface CCXML () <NSXMLParserDelegate>

@property(nonatomic, copy) NSMutableDictionary *dictionary;
@property(nonatomic, copy) NSMutableString *contentString;
@property(nonatomic, copy) NSMutableArray *xmlElements;
@property(nonatomic, copy) NSXMLParser *xmlParser;

@end

@implementation CCXML

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  开始解析
 *
 *  @param data 解析数据
 */
- (void)startParse:(NSData *)data
{
    _dictionary = [NSMutableDictionary dictionary];
    _contentString = [NSMutableString string];
    //Demo XML解析实例
    _xmlElements = [[NSMutableArray alloc] init];
    
    _xmlParser = [[NSXMLParser alloc] initWithData:data];
    [_xmlParser setDelegate:self];
    [_xmlParser parse];
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  转换位键值
 */
- (NSMutableDictionary *)changeDictionary
{
    return _dictionary;
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  解析文档开始
 *
 *  @param parser <#parser description#>
 */
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    //NSLog(@"解析文档开始");
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //NSLog(@"遇到启始标签:%@",elementName);
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    //NSLog(@"遇到内容:%@",string);
    [_contentString setString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if (![_contentString isEqualToString:@"\n"] && ![elementName isEqualToString:@"root"])
        [_dictionary setObject:[_contentString copy] forKey:elementName];
}

/**
 *  @author C C, 2015-12-04
 *  
 *  @brief  解析文档结束
 *
 *  @param parser <#parser description#>
 */
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    _xmlElements = nil;
    _xmlParser = nil;
}


@end
