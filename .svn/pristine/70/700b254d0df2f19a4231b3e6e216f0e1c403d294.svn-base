//
//  Book.h
//  ReadDecode
//
//  Created by admin001 on 14-10-13.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum BookError{
    kNone=0,
    kFileError,
    kException
}BookError;
typedef enum BookType{
    kTxt=100,
    kEpub,
    kUMD,
    kEBK2
}BookType;

#define BOOK_FILE_PATH @"/Users/gaolong/Desktop/Book"
#define BOOK_INFO_PATH @"/Users/gaolong/Desktop/BookInfo"
#define BOOK_CONTENT_PATH @"/Users/gaolong/Desktop/BookContent"

@interface Book : NSObject<NSCoding>
@property(nonatomic,assign)BookError error;//图书解析状态
@property(nonatomic,assign)BookType type;//图书类型
@property(nonatomic,copy)NSString *fileName;//文件名
@property(nonatomic,copy)NSString *bookID;//图书ID
@property(nonatomic,copy)NSString *title;//图书书名
@property(nonatomic,copy)NSString *author;//图书作者
@property(nonatomic,assign)NSInteger contentLength;//图书正文长度,epub没有该信息
@property(nonatomic,assign)NSInteger chapterNumber;//图书章节数
@property(nonatomic,copy)NSArray *chapterTitles;//图书章节标题数组
@property(nonatomic,copy)NSArray *chapterOffset;//图书章节偏移量
@property(nonatomic,copy)NSString *contentPath;//图书正文的路径
@property(nonatomic,assign)NSInteger fileSize;//图书文件大小
@property(nonatomic,assign)NSInteger codeType;//文本编码格式，目前只用于Txt

-(NSString *)getHtmlStringByChapterIndex:(NSInteger)index;
@end
