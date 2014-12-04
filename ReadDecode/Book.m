//
//  Book.m
//  ReadDecode
//
//  Created by admin001 on 14-10-13.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "Book.h"
#import "NSString+encode.h"
#import "BookManager.h"

#define BOOK_ERROR @"BookError"
#define BOOK_TYPE @"BookType"
#define BOOK_FILE_NAME @"BookFileName"
#define BOOK_ID @"BookID"
#define BOOK_TITLE @"BookTitle"
#define BOOK_AUTHOR @"BookAuthor"
#define BOOK_CONTENT_LENGTH @"BookContentLength"
#define BOOK_CHAPTER_NUMBER @"BookChapterNumber"
#define BOOK_CHAPTER_TITLES @"BookChapterTitles"
#define BOOK_CHAPTER_OFFSET @"BookChapterOffset"
#define BOOK_CONTENT_FILE_PATH @"BookContentFilePath"
#define BOOK_FILE_SIZE @"BookFileSize"
#define BOOK_CODE_TYPE @"BookCodeType"

@implementation Book

#pragma mark - NSCoding
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self=[super init];
    if (self) {
        self.error=[aDecoder decodeIntForKey:BOOK_ERROR];
        self.type=[aDecoder decodeIntForKey:BOOK_TYPE];
        self.fileName=[aDecoder decodeObjectForKey:BOOK_FILE_NAME];
        self.bookID=[aDecoder decodeObjectForKey:BOOK_ID];
        self.title=[aDecoder decodeObjectForKey:BOOK_TITLE];
        self.author=[aDecoder decodeObjectForKey:BOOK_AUTHOR];
        self.contentLength=[aDecoder decodeIntegerForKey:BOOK_CONTENT_LENGTH];
        self.chapterNumber=[aDecoder decodeIntegerForKey:BOOK_CHAPTER_NUMBER];
        self.chapterTitles=[aDecoder decodeObjectForKey:BOOK_CHAPTER_TITLES];
        self.chapterOffset=[aDecoder decodeObjectForKey:BOOK_CHAPTER_OFFSET];
        self.contentPath=[aDecoder decodeObjectForKey:BOOK_CONTENT_FILE_PATH];
        self.fileSize=[aDecoder decodeIntegerForKey:BOOK_FILE_SIZE];
        self.codeType=[aDecoder decodeIntegerForKey:BOOK_CODE_TYPE];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    if (aCoder) {
        [aCoder encodeInt:self.error forKey:BOOK_ERROR];
        [aCoder encodeInt:self.type forKey:BOOK_TYPE];
        [aCoder encodeObject:self.fileName forKey:BOOK_FILE_NAME];
        [aCoder encodeObject:self.bookID forKey:BOOK_ID];
        [aCoder encodeObject:self.title forKey:BOOK_TITLE];
        [aCoder encodeObject:self.author forKey:BOOK_AUTHOR];
        [aCoder encodeInteger:self.contentLength forKey:BOOK_CONTENT_LENGTH];
        [aCoder encodeInteger:self.chapterNumber forKey:BOOK_CHAPTER_NUMBER];
        [aCoder encodeObject:self.chapterTitles forKey:BOOK_CHAPTER_TITLES];
        [aCoder encodeObject:self.chapterOffset forKey:BOOK_CHAPTER_OFFSET];
        [aCoder encodeObject:self.contentPath forKey:BOOK_CONTENT_FILE_PATH];
        [aCoder encodeInteger:self.fileSize forKey:BOOK_FILE_SIZE];
        [aCoder encodeInteger:self.codeType forKey:BOOK_CODE_TYPE];
    }
}
#pragma mark - Get HTML String
-(NSString *)getHtmlStringByChapterIndex:(NSInteger)index{
    switch (self.type) {
        case kUMD:{
            return [self getUMDHtmlStringByChapterIndex:index];
        }break;
        case kEBK2:{
            return [self getEBK2HtmlStringByChapterIndex:index];
        }break;
        case kEpub:{
            return [self getEpubHtmlStringByChapterIndex:index];
        }break;
        case kTxt:{
            return [self getTxtHtmlStringByChapterIndex:index];
        }break;
        default:
            break;
    }
    return nil;
}
-(NSString *)getUMDHtmlStringByChapterIndex:(NSInteger)index{
    if (index>=self.chapterNumber) {
        return nil;
    }
    NSString *lFilePath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    if (![[NSFileManager defaultManager]fileExistsAtPath:lFilePath]) {
        Book *lBook=[[BookManager share]decoderBookWith:[BOOK_FILE_PATH stringByAppendingPathComponent:self.fileName]];
        if (lBook==nil||lBook.error!=kNone) {
            return nil;
        }
        self.contentPath=lBook.contentPath;
        lFilePath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    }
    NSFileHandle *lFileHandle=[NSFileHandle fileHandleForUpdatingAtPath:lFilePath];
    for (int i=0; i<self.chapterNumber; i++) {
        
        NSData *lData;
        if (i!=self.chapterNumber-1) {
            NSInteger length=[[self.chapterOffset objectAtIndex:i+1]integerValue];
            lData=[lFileHandle  readDataOfLength:length*2-lFileHandle.offsetInFile];
        }else{
            lData=[lFileHandle  readDataToEndOfFile];
        }
        if (i==index) {
            NSString *lString=[[NSString alloc]initWithData:lData encoding:NSUTF16LittleEndianStringEncoding];
            
            [lFileHandle closeFile];
            return [self getFinalHtmlStringWith:[self getHtmlStringWithText:lString]];
        }
    }
    [lFileHandle closeFile];

    return nil;
}
-(NSString *)getEBK2HtmlStringByChapterIndex:(NSInteger)index{
    if (index>=self.chapterNumber) {
        return nil;
    }
    NSString *lFilePath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    if (![[NSFileManager defaultManager]fileExistsAtPath:lFilePath]) {
        Book *lBook=[[BookManager share]decoderBookWith:[BOOK_FILE_PATH stringByAppendingPathComponent:self.fileName]];
        if (lBook==nil||lBook.error!=kNone) {
            return nil;
        }
        self.contentPath=lBook.contentPath;
        lFilePath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    }
    NSFileHandle *lFileHandle=[NSFileHandle fileHandleForUpdatingAtPath:lFilePath];
    NSRange lRange=NSRangeFromString([self.chapterOffset objectAtIndex:index]);
    [lFileHandle seekToFileOffset:lRange.location];
    NSData *lData=[lFileHandle readDataOfLength:lRange.length];
    NSString *lString=[[NSString alloc]initWithData:lData encoding:NSUTF16LittleEndianStringEncoding];
    [lFileHandle closeFile];
    return [self getFinalHtmlStringWith:[self getHtmlStringWithText:lString]];
}
-(NSString *)getEpubHtmlStringByChapterIndex:(NSInteger)index{
    if (index>=self.chapterNumber) {
        return nil;
    }
    NSDictionary *lDic=[self.chapterTitles objectAtIndex:index];
    NSString *lFileName=[lDic objectForKey:@"chapterFileName"];
    NSString *lContentPath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    if (![[NSFileManager defaultManager]fileExistsAtPath:lContentPath]) {
        Book *lBook=[[BookManager share]decoderBookWith:[BOOK_FILE_PATH stringByAppendingPathComponent:self.fileName]];
        if (lBook==nil||lBook.error!=kNone) {
            return nil;
        }
        self.contentPath=lBook.contentPath;
        lContentPath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:self.contentPath];
    }
    NSString *lString=[NSString stringWithContentsOfFile:[lContentPath stringByAppendingPathComponent:lFileName] encoding:NSUTF8StringEncoding error:nil];
    return [self getFinalHtmlStringWith:lString];
}
-(NSString *)getTxtHtmlStringByChapterIndex:(NSInteger)index{
    if (index>=self.chapterNumber) {
        return nil;
    }
    NSString *lFilePath=[BOOK_FILE_PATH stringByAppendingPathComponent:self.fileName];
    NSFileHandle *lFileHandle=[NSFileHandle fileHandleForUpdatingAtPath:lFilePath];
    NSRange lRange=NSRangeFromString([self.chapterOffset objectAtIndex:index]);
    [lFileHandle seekToFileOffset:lRange.location];
    NSData *lData=[lFileHandle readDataOfLength:lRange.length];
    NSString *lString=[[NSString alloc]initWithData:lData encoding:self.codeType];
    [lFileHandle closeFile];
    return [self getFinalHtmlStringWith:[self getHtmlStringWithText:lString]];
}
-(NSString *)getHtmlStringWithText:(NSString *)text{
    NSMutableString *lString=[text mutableCopy];
    [lString replaceOccurrencesOfString:@"\n" withString:@"</p><p>" options:0 range:NSMakeRange(0, [lString length])];
    [lString replaceOccurrencesOfString:@"\U00002029" withString:@"</p><p>" options:0 range:NSMakeRange(0, [lString length])];
    [lString insertString:@"<p>" atIndex:0];
    [lString appendString:@"</p>"];
    return [lString copy];
}
-(NSString *)getFinalHtmlStringWith:(NSString *)body{
    NSString* urlAddress = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"xhtml"];
    NSMutableString *htmlTemplate = [NSMutableString stringWithContentsOfFile:urlAddress encoding:NSUTF8StringEncoding error:nil];
    
    NSString *cssStr = [self getCssAndHighlightCss];
    [htmlTemplate replaceOccurrencesOfString:@"@@@" withString:cssStr options:0 range:NSMakeRange(0, [htmlTemplate length])] ;
    
    [htmlTemplate replaceOccurrencesOfString:@"%%%" withString:@"" options:0 range:NSMakeRange(0, [htmlTemplate length])] ;
    
    [htmlTemplate replaceOccurrencesOfString:@"%@" withString:body options:0 range:NSMakeRange(0, [htmlTemplate length])];
    [htmlTemplate appendString:[self getJavaScriptString]];
    
    return htmlTemplate;
}
-(NSString *)getCssAndHighlightCss{//设置Css样式
//    NSString *highLightCss= @".Noteclass{background:darkgray;text-decoration:underline} .MyAppHighlight{background:darkgray;}";
//    NSString *headerColorCss=@"h1,h2,h3,h4,h5,h6{color:yellow;margin-top:0px;padding: 0px;}";
    NSString *tmpStrin =  [NSString stringWithFormat:@"p {text-indent: 2em; line-height:138%%;} img{max-width:100%%; width:auto; max-height:100%%;}"];
    NSString *lFyCssString=@"html {width:-spicBookWidthAdd1-px ;height: -spicHeight-px;margin: 0px;padding: 0px;font-size:18px;}"
    "body {margin: 0px ;padding: 0px;}"
    "#book {width: -spicBookWidth-px;height:-spicHeight-px;padding:-spicPageGapTop-px 0px 0px 0px ; -webkit-column-width:-spicBookWidth-px; -webkit-column-gap:0px; text-align:justify; }"
    "p {text-indent: 2em; line-height:-spicRowGap-%%;}"
    "img{max-width:100%%; width:auto; max-height:100%%;}"
    "#viewer {width: -spicBookWidth-px;  height: -spicHeight-px;}";
    NSMutableString *lFyCss=[lFyCssString mutableCopy];
    [lFyCss replaceOccurrencesOfString:@"-spicRowGap-" withString:[NSString stringWithFormat:@"%d",138] options:0 range:NSMakeRange(0, [lFyCss length])];
    //	[fyCss replaceOccurrencesOfString:@"-spicPageGap-" withString:[NSString stringWithFormat:@"%d",currPageGag] options:0 range:NSMakeRange(0, [fyCss length])];
    [lFyCss replaceOccurrencesOfString:@"-spicPageGapTop-" withString:[NSString stringWithFormat:@"%d",20] options:0 range:NSMakeRange(0, [lFyCss length])];
    [lFyCss replaceOccurrencesOfString:@"-spicHeight-" withString:[NSString stringWithFormat:@"%d",548] options:0 range:NSMakeRange(0, [lFyCss length])];
    [lFyCss replaceOccurrencesOfString:@"-spicBookWidth-" withString:[NSString stringWithFormat:@"%d",300] options:0 range:NSMakeRange(0, [lFyCss length])];
    [lFyCss replaceOccurrencesOfString:@"-spicBookWidthAdd1-" withString:[NSString stringWithFormat:@"%d",301] options:0 range:NSMakeRange(0, [lFyCss length])];
    return [tmpStrin stringByAppendingFormat:@"%@",lFyCss];
}
-(NSString *)getJavaScriptString{
    NSString *javaStr = [NSString stringWithFormat:@"document.body.style.fontSize='18px';"];
//    javaStr = [javaStr stringByAppendingFormat:@"document.body.style.fontFamily =\" %@\"; ", [GenaricClass getFontNameForIndex:[[bSettings objectForKey:@"fontname"] intValue]]];
    javaStr = [javaStr stringByAppendingFormat:@"document.body.style.color =\" balck\"; "];
    javaStr=[javaStr stringByAppendingString:@"document.body.style.backgroundColor=\"transparent\";"];
//    javaStr=[javaStr stringByAppendingFormat:@"document.body.style.backgroundImage =\"url('file:%@')\";",[[[NSBundle mainBundle]resourcePath]stringByAppendingPathComponent:@"Guide04.png"]];
    
    javaStr=[NSString stringWithFormat:@"<script language=\"javascript\"> %@ </script> ",javaStr];
    return javaStr;
}
@end
