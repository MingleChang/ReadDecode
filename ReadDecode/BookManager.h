//
//  BookManager.h
//  ReadDecode
//
//  Created by admin001 on 14-10-13.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Book;
@interface BookManager : NSObject

@property(nonatomic,retain)NSMutableArray *books;

+(BookManager *)share;

-(void)saveAllBooks;
-(void)readAllBooks;

-(Book *)decoderBookWith:(NSString *)path;
-(Book *)decoderEpubWith:(NSString *)path;
-(Book *)decoderUMDWith:(NSString *)path;
-(Book *)decoderUMD:(NSData *)data andFileName:(NSString *)fileName;
-(Book *)decoderEBK2With:(NSString *)path;
-(Book *)decoderEBK2:(NSData *)data andFileName:(NSString *)fileName;
-(Book *)decoderTxtWith:(NSString *)path;
@end
