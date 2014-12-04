//
//  BookManager.m
//  ReadDecode
//
//  Created by admin001 on 14-10-13.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "BookManager.h"
#import "Book.h"
#import "ZipArchive.h"
#import "NSString+encode.h"
#import "CXMLDocument.h"
#import "CXMLElement.h"
#import "CXMLNode_XPathExtensions.h"

#define MAX_BUFFER_UMD_SIZE 1024*32
#define MAX_BUFFER_EBK2_SIZE 1024*64
#define TXT_CHAPTER_LENGTH 10000

@interface BookManager()
@end
@implementation BookManager
+(BookManager *)share{
    static BookManager *readerManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (readerManager == nil)
        {
            readerManager = [[BookManager alloc] init];
        }
    });
    return readerManager;
}
-(instancetype)init{
    self=[super init];
    if (self) {
        [self readAllBooks];
    }
    return self;
}
-(void)saveAllBooks{
    NSString *lFilePath=[BOOK_INFO_PATH stringByAppendingPathComponent:@"bookInfo"];
    [NSKeyedArchiver archiveRootObject:self.books toFile:lFilePath];
}
-(void)readAllBooks{
    NSString *lFilePath=[BOOK_INFO_PATH stringByAppendingPathComponent:@"bookInfo"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:lFilePath]) {
        NSArray *lArray=[NSKeyedUnarchiver unarchiveObjectWithFile:lFilePath];
        self.books=[lArray mutableCopy];
    }else{
        self.books=[NSMutableArray array];
    }
}

-(void)createBookDirectory{
    BOOL isDirectory;
    if ([[NSFileManager defaultManager]fileExistsAtPath:BOOK_FILE_PATH isDirectory:&isDirectory]) {
        if (isDirectory==NO) {
            [[NSFileManager defaultManager]removeItemAtPath:BOOK_FILE_PATH error:nil];
            [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_FILE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }else{
        [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_FILE_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:BOOK_INFO_PATH isDirectory:&isDirectory]) {
        if (isDirectory==NO) {
            [[NSFileManager defaultManager]removeItemAtPath:BOOK_INFO_PATH error:nil];
            [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_INFO_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }else{
        [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_INFO_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    if ([[NSFileManager defaultManager]fileExistsAtPath:BOOK_CONTENT_PATH isDirectory:&isDirectory]) {
        if (isDirectory==NO) {
            [[NSFileManager defaultManager]removeItemAtPath:BOOK_CONTENT_PATH error:nil];
            [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_CONTENT_PATH withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }else{
        [[NSFileManager defaultManager]createDirectoryAtPath:BOOK_CONTENT_PATH withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
#pragma mark - Book decode
-(Book *)decoderBookWith:(NSString *)path{
    NSString *lString=[[path pathExtension]lowercaseString];
    if ([lString isEqualToString:@"epub"]) {
        return [self decoderEpubWith:path];
    }else if ([lString isEqualToString:@"umd"]){
        return [self decoderUMDWith:path];
    }else if ([lString isEqualToString:@"ebk2"]){
        return [self decoderEBK2With:path];
    }else if ([lString isEqualToString:@"txt"]){
        return [self decoderTxtWith:path];
    }else{
        return nil;
    }
}
#pragma mark - Epub decode
-(void)unzipFile:(NSString *)filePath toPath:(NSString *)toPath{
    ZipArchive *zip=[[ZipArchive alloc]init];
    [zip UnzipOpenFile:filePath];
    [zip UnzipFileTo:toPath overWrite:YES];
}
-(Book *)decoderEpubWith:(NSString *)path{
    [self createBookDirectory];
    Book *lBook=[[Book alloc]init];
    lBook.type=kEpub;
    @try {
        lBook.fileName=path.lastPathComponent;
        NSString *contentPath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:[lBook.fileName md5]];
        [self unzipFile:path toPath:contentPath];
        lBook.contentPath=[lBook.fileName md5];
        NSString *lOpfName=[self getOpfFileNameWith:contentPath];
        if (lOpfName==nil||[lOpfName isEqualToString:@""]) {
            lBook.error=kFileError;
            return lBook;
        }
        NSString *lNcxName=[self getNcxFileNameWithOpfName:lOpfName];
        if (lNcxName==nil||[lNcxName isEqualToString:@""]) {
            lBook.error=kFileError;
            return lBook;
        }
        NSString *lOpfPath=[contentPath stringByAppendingPathComponent:lOpfName];
        NSString *lNcxPath=[contentPath stringByAppendingPathComponent:lNcxName];
        if (!([[NSFileManager defaultManager]fileExistsAtPath:lOpfPath]&&[[NSFileManager defaultManager]fileExistsAtPath:lNcxPath])) {
            lBook.error=kFileError;
            return lBook;
        }
        NSString *lOpfRootPath=[lOpfPath stringByDeletingLastPathComponent];
        [self setEpubBookObject:lBook andOpfPath:lOpfPath];
        [self setEpubBookCover:lBook andOpfRootPath:lOpfRootPath];
        lBook.contentPath=[lBook.contentPath stringByAppendingPathComponent:[lOpfName stringByDeletingLastPathComponent]];
        lBook.chapterTitles=[self getBookInfoFrom:lNcxPath and:lOpfPath];
        lBook.chapterNumber=lBook.chapterTitles.count;
    }
    @catch (NSException *exception) {
        lBook.error=kException;
    }
    @finally {
        
        return lBook;
    }
    
}
-(void)setBookTitlesArray:(NSMutableArray *)titles withNavpoints:(NSArray *)navPoints andChapterInfo:(NSDictionary *)mainDic andChapterNameFormat:(NSString *)nameFormat andChapterContentFormat:(NSString *)contentFormat andPointFormat:(NSString *)pointFormat andNameSpace:(NSDictionary *)ns{
    for (int i=0; i<navPoints.count; i++) {
        CXMLElement *pointElement=[navPoints objectAtIndex:i];
        NSString *title=[[[pointElement nodesForXPath:nameFormat namespaceMappings:ns error:nil]objectAtIndex:0]stringValue];
        NSString *path=[[[[pointElement nodesForXPath:contentFormat namespaceMappings:ns error:nil]objectAtIndex:0]attributeForName:@"src"]stringValue];
        NSNumber *objOrder=[mainDic objectForKey:[path stringByAppendingString:@"-order"]];
        if (objOrder) {
            NSMutableDictionary *ns=[NSMutableDictionary dictionaryWithObjectsAndKeys:title ,@"chaptertitle",@"",@"chapterhash",path,@"chapterFileName",nil];
            [titles addObject:ns];
        } else {//考虑
//            NSArray *pathAry=[path componentsSeparatedByString:@"#"];
//            if ([pathAry count]>1 ) {
//                NSString *orderKey = [[pathAry objectAtIndex:0] stringByAppendingString:@"-order"];
//                objOrder=[mainDic objectForKey:orderKey];
//                if (objOrder) {
//                    NSMutableDictionary *ns=[NSMutableDictionary dictionaryWithObjectsAndKeys:title ,@"chaptertitle",[pathAry objectAtIndex:1],@"chapterhash",[pathAry objectAtIndex:0],@"chapterFileName",nil];
//                    [titles addObject:ns];
//                }
//            }
        }
        NSArray *childNodes= [pointElement nodesForXPath:pointFormat namespaceMappings:ns error:nil] ;
        
        if (childNodes && [childNodes count]>0) {
            [self setBookTitlesArray:titles withNavpoints:childNodes andChapterInfo:mainDic andChapterNameFormat:nameFormat andChapterContentFormat:contentFormat andPointFormat:pointFormat andNameSpace:ns];
        }
    }
}
-(NSArray *)getBookInfoFrom:(NSString *)ncxPath and:(NSString *)opfPath{
    
    NSData* opfData = [NSData dataWithContentsOfFile: opfPath];
    CXMLDocument* opfDoc=[[CXMLDocument alloc] initWithData:opfData options:0 error:nil];
    CXMLElement* opfRootElement = [opfDoc rootElement];
    NSArray *manifestArray=[opfRootElement nodesForXPath:@"//*[local-name()='manifest']/*[local-name()='item']"  error:nil];
    NSMutableDictionary *manifestDic=[[NSMutableDictionary alloc] init];
    for (CXMLElement *node in manifestArray) {
        NSString *lChapterHref=[[node attributeForName:@"href"] stringValue];
        NSString *lChapterId=[[node attributeForName:@"id"] stringValue];
        NSString *lType=[[node attributeForName:@"media-type"] stringValue];
        if ([lType isEqualToString:@"application/xhtml+xml"]) {
            [manifestDic setObject:lChapterHref forKey:lChapterId];
        }
    }
    NSArray *spineArray=[opfRootElement nodesForXPath:@"//*[local-name()='spine']/*[local-name()='itemref']"  error:nil];
    NSMutableArray *lChapterOffsets=[NSMutableArray array];
    for (int i = 0 ; i<[spineArray count] ; i++) {
        NSString *idref=[[[spineArray objectAtIndex:i] attributeForName:@"idref"] stringValue];
        NSString *cpath = [manifestDic objectForKey:idref];
        NSMutableDictionary *ns=[NSMutableDictionary dictionaryWithObjectsAndKeys: idref ,@"chaptername",
                                 cpath ,@"chapterfilename",
                                 [NSString stringWithFormat:@"%d", i+1],@"chapterid",
                                 nil];
        [lChapterOffsets addObject:ns];
        [manifestDic setObject:[NSNumber numberWithInt:i] forKey:[cpath stringByAppendingString:@"-order"]];
    }
    
    NSData *ncxData=[NSData dataWithContentsOfFile:ncxPath options:0 error:nil];
    
    
    CXMLDocument* tmpDoc=[[CXMLDocument alloc] initWithData:ncxData options:0 error:nil];
    CXMLElement *rootElement = [tmpDoc rootElement];
    NSString *chapterNameFormat;
    NSString *chapterContentFormat;
    NSString *navPointFormat;
    NSString *titleFormat;
    NSDictionary *ns = nil;
    NSArray *navPoints=[rootElement nodesForXPath:@"navMap/navPoint" namespaceMappings:nil error:nil];
    if ([navPoints count]>0) {
        titleFormat=@"//docTitle/text";
        chapterNameFormat=@"navLabel/text";
        chapterContentFormat=@"content";
        navPointFormat=@"navPoint";
    }else{
        titleFormat=@"//ncx:docTitle/ncx:text";
        chapterNameFormat=@"ncx:navLabel/ncx:text";
        chapterContentFormat=@"ncx:content";
        navPointFormat=@"ncx:navPoint";
        ns=[NSDictionary dictionaryWithObjectsAndKeys:@"http://www.daisy.org/z3986/2005/ncx/",@"ncx", nil];
        navPoints=[rootElement nodesForXPath:@"ncx:navMap/ncx:navPoint" namespaceMappings:ns error:nil];
    }
    NSMutableArray *lTitles=[NSMutableArray array];
    [self setBookTitlesArray:lTitles withNavpoints:navPoints andChapterInfo:manifestDic andChapterNameFormat:chapterNameFormat andChapterContentFormat:chapterContentFormat andPointFormat:navPointFormat andNameSpace:ns];
    
//    for (NSDictionary *dic in lTitles) {
//        NSString *lString=[dic objectForKey:@"chaptertitle"];
//        NSLog(@"%@",lString);
//    }
    return lTitles;
}
-(void)setEpubBookCover:(Book *)book andOpfRootPath:(NSString *)path{
    NSArray *coverSuffix =[NSArray arrayWithObjects:@"iTunesArtwork",@"images/cover.png",@"images/cover.jpg",@"images/cover.jpeg",@"cover.png",@"cover.jpg",@"cover.jpeg",@"cover1.png",@"cover1.jpg",@"cover1.jpeg",nil];
    for (NSString *lsuffix in coverSuffix) {
        NSString *FilePath=[path stringByAppendingPathComponent:lsuffix];
        if ([[NSFileManager defaultManager]fileExistsAtPath:FilePath]) {
            NSString *lCoverPath=[BOOK_INFO_PATH stringByAppendingPathComponent:[book.fileName md5]];
            [[NSFileManager defaultManager]copyItemAtPath:FilePath toPath:lCoverPath error:nil];
//            book.coverPath=lCoverPath;
            return;
        }
    }
}
-(void)setEpubBookObject:(Book *)book andOpfPath:(NSString *)path{
    NSData *lOpfData=[NSData dataWithContentsOfFile:path options:0 error:nil];
    CXMLDocument *lOpfDoc=[[CXMLDocument alloc] initWithData:lOpfData options:CXMLDocumentTidyXML error:nil];
    CXMLElement *lOpfRootElement= [lOpfDoc rootElement];
    NSDictionary *lOpfDic = [NSDictionary dictionaryWithObjectsAndKeys:@"http://purl.org/dc/elements/1.1/",@"dc", nil];
    NSArray *authorArray=[lOpfRootElement nodesForXPath:@"//dc:creator" namespaceMappings:lOpfDic error:nil];
    if ([authorArray count]>0) {
        book.author=[[authorArray objectAtIndex:0] stringValue];
    }
    NSArray *titleArray=[lOpfRootElement nodesForXPath:@"//dc:title" namespaceMappings:lOpfDic error:nil];
    if ([titleArray count]>0) {
        book.title=[[titleArray objectAtIndex:0] stringValue];
    }
}
-(NSString *)getOpfFileNameWith:(NSString *)contentPath{
    NSString *lPath=[self getContanerPathWith:contentPath];
    if (lPath==nil||[lPath isEqualToString:@""]) {
        return nil;
    }
    NSData *lOpfData=[NSData dataWithContentsOfFile:lPath];
    NSString *lOpfString=[[NSString alloc]initWithData:lOpfData encoding:NSUTF8StringEncoding];
    if (lOpfString==nil) {
        return nil;
    }
    NSScanner *lScanner=[NSScanner scannerWithString:lOpfString];
    NSString *lOpfName;
    [lScanner scanUpToString:@"full-path=\"" intoString:nil];
    [lScanner scanString:@"full-path=\"" intoString:nil];
    [lScanner scanUpToString:@"\"" intoString:&lOpfName];
    return lOpfName;
}
-(NSString *)getNcxFileNameWithOpfName:(NSString *)contentPath{
    NSString *lNcxName=contentPath;
    if ([contentPath rangeOfString: @"metadata."].length >0) {
        lNcxName=[contentPath stringByReplacingOccurrencesOfString:@"metadata." withString:@"toc."];
    }else if ([contentPath rangeOfString: @"content."].length>0)  {
        
        lNcxName=[contentPath stringByReplacingOccurrencesOfString:@"content." withString:@"toc."];
    }
    lNcxName=[lNcxName stringByReplacingOccurrencesOfString:@".opf" withString:@".ncx"];
    return lNcxName;
}
#pragma mark - UMD decode
-(Book *)decoderUMDWith:(NSString *)path{
    NSData *lData=[NSData dataWithContentsOfFile:path];
    NSString *lFileName=[path lastPathComponent];
    return [self decoderUMD:lData andFileName:lFileName];
}
-(Book *)decoderUMD:(NSData *)data andFileName:(NSString *)fileName{
    [self createBookDirectory];
    NSString *lFileContentPath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:[fileName md5]];
    [[NSFileManager defaultManager]createFileAtPath:lFileContentPath contents:nil attributes:nil];
    NSFileHandle *lHandle=[NSFileHandle fileHandleForUpdatingAtPath:lFileContentPath];
    Book *lBook=[[Book alloc]init];
    lBook.fileName=fileName;
    lBook.contentPath=[fileName md5];
    lBook.type=kUMD;
    @try {
        NSInteger currentIndex=0;
        currentIndex+=4;
        BOOL flag=YES;
        while (flag) {
            NSInteger funType=[self getShortInt:data withIndex:currentIndex];
            currentIndex++;
            switch (funType) {
                case 0x23:{
                    NSInteger type=[self getShortInt:data withIndex:currentIndex];
                    currentIndex+=2;
                    switch (type) {
                        case 0x01:{//umd类型
                            currentIndex+=2;
                            NSInteger value=[self getShortInt:data withIndex:currentIndex];
                            if (value!=1) {
                                lBook.error=kFileError;
                                [lHandle closeFile];
                                return lBook;
                            }
                            currentIndex++;
                            currentIndex+=2;
                        }break;
                        case 0x02:{//标题
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            lBook.title=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x03:{//作者
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            lBook.author=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x04:{//年
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lBook.year=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x05:{//月
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lBook.mouth=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x06:{//日
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lBook.day=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x07:{//分类
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lUMD.gender=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x08:{//出版商
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lBook.publisher=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x09:{//发行商
                            currentIndex++;
                            NSInteger length=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            //                        lBook.vendor=[self getString:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                        }break;
                        case 0x0a:{
                            currentIndex++;
                            NSInteger lContentID=[self getShortInt:data withIndex:currentIndex]-5;
                            currentIndex++;
                            currentIndex+=lContentID;
                        }break;
                        case 0xf1:{
                            currentIndex+=16;
                        }break;
                        case 0x0b:{//长度
                            currentIndex+=2;
                            NSInteger length=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            lBook.contentLength=length;
                        }break;
                        case 0x83:{//章节偏移量
                            currentIndex+=2;
                            NSInteger random1=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex++;
                            NSInteger random2=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            if (random1!=random2) {
                                lBook.error=kFileError;
                                return lBook;
                            }
                            
                            lBook.chapterNumber=([self getInt:data withIndex:currentIndex]-9)/4;
                            currentIndex+=4;
                            
                            NSMutableArray *lOffsets=[NSMutableArray arrayWithCapacity:lBook.chapterNumber];
                            for (int i=0; i<lBook.chapterNumber; i++) {
                                NSInteger offsets=[self getInt:data withIndex:currentIndex];
                                currentIndex+=4;
                                [lOffsets addObject:[NSNumber numberWithInteger:offsets/2]];
                            }
                            lBook.chapterOffset=lOffsets;
                        }break;
                        case 0x84:{//章节名
                            currentIndex+=2;
                            NSInteger random1=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex++;
                            NSInteger random2=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            if (random1!=random2) {
                                lBook.error=kFileError;
                                return lBook;
                            }
                            
                            currentIndex+=4;
                            NSMutableArray *lTitles=[NSMutableArray arrayWithCapacity:lBook.chapterNumber];
                            for (int i=0; i<lBook.chapterNumber; i++) {
                                NSInteger length=[self getShortInt:data withIndex:currentIndex];
                                currentIndex++;
                                
                                NSString *lTitle=[self getString:data withIndex:currentIndex andLength:length];
                                currentIndex+=length;
                                [lTitles addObject:lTitle];
                            }
                            lBook.chapterTitles=lTitles;
                        }break;
                        case 0x81:{
                            currentIndex+=2;
                            NSInteger random1=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex++;
                            NSInteger random2=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            if (random1!=random2) {
                                lBook.error=kFileError;
                                return lBook;
                            }
                            
                            NSInteger lBlockNumber=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex+=(lBlockNumber-9);
                        }break;
                        case 0x82:{
                            currentIndex+=3;
                            NSInteger random1=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex++;
                            NSInteger random2=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            if (random1!=random2) {
                                lBook.error=kFileError;
                                return lBook;
                            }
                            
                            NSInteger length=[self getInt:data withIndex:currentIndex]-9;
                            currentIndex+=4;
                            
                            NSData *lImageData=[self getData:data withIndex:currentIndex andLength:length];
                            currentIndex+=length;
                            NSString *lImagePath=[BOOK_INFO_PATH stringByAppendingPathComponent:[fileName md5]];
                            [lImageData writeToFile:lImagePath atomically:YES];
                        }break;
                        case 0x87:{
                            currentIndex+=4;
                            NSInteger random1=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex++;
                            NSInteger random2=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            if (random1!=random2) {
                                lBook.error=kFileError;
                                [lHandle closeFile];
                                return lBook;
                            }
                            
                            NSInteger offsetLength=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            currentIndex+=(offsetLength-9);
                        }break;
                        case 0x0c:{//结束标识
                            currentIndex+=2;
                            NSInteger lFileSize=[self getInt:data withIndex:currentIndex];
                            currentIndex+=4;
                            lBook.fileSize=lFileSize;
                            [lHandle closeFile];
                            flag=NO;
                            return lBook;
                        }
                        default:
                            break;
                    }
                }break;
                case 0x24:{
                    currentIndex+=4;
                    NSInteger length=[self getInt:data withIndex:currentIndex]-9;
                    currentIndex+=4;
                    
                    NSData *lContentData=[self getData:data withIndex:currentIndex andLength:length];
                    unsigned long deslen = MAX_BUFFER_UMD_SIZE;
                    Byte buffer[MAX_BUFFER_UMD_SIZE];
                    int value=uncompress(buffer, &deslen, [lContentData bytes], length);
                    if (value==Z_OK) {
                        NSData *lData=[NSData dataWithBytes:buffer length:deslen];
                        [lHandle seekToEndOfFile];
                        [lHandle writeData:lData];
                    }else{
                        [lHandle closeFile];
                        lBook.error=kFileError;
                        return lBook;
                    }
                    currentIndex+=length;
                }
                    break;
                default:
                    break;
            }
        }
    }
    @catch (NSException *exception) {
        [lHandle closeFile];
        lBook.error=kException;
        return lBook;
    }
    @finally {
        [lHandle closeFile];
        return lBook;
    }
}

#pragma mark - EBK2 decode
-(Book *)decoderEBK2With:(NSString *)path{
    if (![[NSFileManager defaultManager]fileExistsAtPath:path]) {
        return nil;
    }
    NSData *lData=[NSData dataWithContentsOfFile:path];
    NSString *lFileName=[path lastPathComponent];
    return [self decoderEBK2:lData andFileName:lFileName];
}
-(Book *)decoderEBK2:(NSData *)data andFileName:(NSString *)fileName{
    [self createBookDirectory];
    Book *lBook=[[Book alloc]init];
    lBook.type=kEBK2;
    lBook.fileName=fileName;
    lBook.contentPath=[fileName md5];
    NSString *lFileContentPath=[BOOK_CONTENT_PATH stringByAppendingPathComponent:[fileName md5]];
    [[NSFileManager defaultManager]createFileAtPath:lFileContentPath contents:nil attributes:nil];
    NSFileHandle *lHandle=[NSFileHandle fileHandleForUpdatingAtPath:lFileContentPath];
    @try {
        NSInteger bookID=[self getInt:data withIndex:0];//书本ID
        NSLog(@"%li",bookID);
        NSInteger headSize=[self getMediumInt:data withIndex:4];//head字节数
        NSLog(@"%li",headSize);
        NSInteger ebkVersion=[self getMediumInt:data withIndex:6];//ebk版本
        NSLog(@"%li",ebkVersion);
        NSInteger ebkSize=[self getInt:data withIndex:8];//ebk文件的大小
        NSLog(@"%li",ebkSize);
        lBook.title=[self getString:data withIndex:12 andLength:64];//图书的标题
        NSLog(@"%@",lBook.title);
        lBook.contentLength=[self getInt:data withIndex:76];//小说正文解压后大小
        NSLog(@"%li",lBook.contentLength);
        NSInteger sectionCompressSize=[self getInt:data withIndex:80];//章节信息压缩后大小
        NSLog(@"%li",sectionCompressSize);
        NSInteger firstCompressSize=[self getInt:data withIndex:84];//第一段正文压缩后大小
        NSLog(@"%li",firstCompressSize);
        lBook.chapterNumber=[self getMediumInt:data withIndex:88];//图书章节数
        NSLog(@"%li",lBook.chapterNumber);
        NSInteger compressCount=[self getMediumInt:data withIndex:90];//正文压缩包数量
        NSLog(@"%li",compressCount);
        NSInteger mediaCount=[self getInt:data withIndex:92];
        NSLog(@"%li",mediaCount);
        NSInteger mediaLength=[self getInt:data withIndex:96];
        NSLog(@"%li",mediaLength);
        NSInteger contentCompressSize=[self getInt:data withIndex:100];//正文压缩后大小
        NSLog(@"%li",contentCompressSize);
        
        if (contentCompressSize+sectionCompressSize+headSize!=ebkSize) {//判断文件是否完整
            lBook.error=kFileError;
            return lBook;
        }
        
        NSData *lSectionData=[data subdataWithRange:NSMakeRange(headSize, sectionCompressSize)];
        NSMutableArray *lTitles=[NSMutableArray arrayWithCapacity:lBook.chapterNumber];
        NSMutableArray *lOffsets=[NSMutableArray arrayWithCapacity:lBook.chapterNumber];
        NSMutableArray *lSectionOffsets=[NSMutableArray arrayWithCapacity:compressCount];
        unsigned long deslen = 72*lBook.chapterNumber+8*compressCount;
        Byte buffer[72*lBook.chapterNumber+8*compressCount];
        int value=uncompress(buffer, &deslen, [lSectionData bytes], sectionCompressSize);
        if (value==Z_OK) {
            NSData *lData=[NSData dataWithBytes:buffer length:deslen];
            for (int i=0; i<lBook.chapterNumber; i++) {//获取章节标题以及章节偏移量
                NSString *lTitle=[self getString:lData withIndex:72*i andLength:64];
                NSInteger location=[self getInt:lData withIndex:72*i+64];
                NSInteger length=[self getInt:lData withIndex:72*i+68];
                [lTitles addObject:lTitle];
                [lOffsets addObject:NSStringFromRange(NSMakeRange(location, length))];
            }
            lBook.chapterTitles=lTitles;
            lBook.chapterOffset=lOffsets;
            NSData *lSegmentData=[lData subdataWithRange:NSMakeRange(72*lBook.chapterNumber, lData.length-72*lBook.chapterNumber)];
            for (int i=0; i<compressCount; i++) {//或者正文压缩的分段偏移量
                NSInteger location=[self getInt:lSegmentData withIndex:8*i];
                NSInteger length=[self getInt:lSegmentData withIndex:8*i+4];
                [lSectionOffsets addObject:NSStringFromRange(NSMakeRange(location, length))];
            }
        }else{
            lBook.error=kFileError;
            return lBook;
        }
        
        NSData *lContentData=[data subdataWithRange:NSMakeRange(headSize+sectionCompressSize, contentCompressSize)];
        for (int i=0; i<compressCount; i++) {//将正文解压写入文件
            NSRange lRange=NSRangeFromString([lSectionOffsets objectAtIndex:i]);
            NSData *lCompressData=[lContentData subdataWithRange:lRange];
            unsigned long deslen = MAX_BUFFER_EBK2_SIZE;
            Byte buffer[MAX_BUFFER_EBK2_SIZE];
            int value=uncompress(buffer, &deslen, [lCompressData bytes], lRange.length);
            if (value==Z_OK) {
                NSData *lData=[NSData dataWithBytes:buffer length:deslen];
                [lHandle seekToEndOfFile];
                [lHandle writeData:lData];
            }else{
                [lHandle closeFile];
                lBook.error=kFileError;
                return lBook;
            }
        }
    }
    @catch (NSException *exception) {
        [lHandle closeFile];
        lBook.error=kException;
        return lBook;
    }
    @finally {
        [lHandle closeFile];
        return lBook;
    }
}
#pragma mark - Txt decode
-(Book *)decoderTxtWith:(NSString *)path{
    Book *lBook=[[Book alloc]init];
    lBook.type=kTxt;
    @try {
        NSString *lFileName=[path lastPathComponent];
        lBook.fileName=lFileName;
        lBook.title=[lFileName stringByDeletingPathExtension];
        NSString *lContent=[NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
        lBook.codeType=NSUTF8StringEncoding;
        if (nil==lContent || [lContent isEqualToString:@""]){
            lContent=[NSString stringWithContentsOfFile:path encoding: 0x80000421  error:nil];
            lBook.codeType=0x80000421;
        }
        if (nil==lContent || [lContent isEqualToString:@""]){
            lContent=[NSString stringWithContentsOfFile:path encoding: 0x80000631  error:nil];
            lBook.codeType=0x80000631;
        }
        if (nil==lContent || [lContent isEqualToString:@""]){
            lContent=[NSString stringWithContentsOfFile:path encoding: 0x80000632  error:nil];
            lBook.codeType=0x80000632;
        }
        if (nil==lContent || [lContent isEqualToString:@""]){
            lContent=[NSString stringWithContentsOfFile:path encoding: 0x80000930  error:nil];
            lBook.codeType=0x80000930;
        }
        if (nil==lContent || [lContent isEqualToString:@""]){
            lBook.error=kFileError;
            return lBook;
        }
        NSLog(@"%lx",lBook.codeType);
        NSInteger chapterNumber=lContent.length/TXT_CHAPTER_LENGTH;
        if (lContent.length%TXT_CHAPTER_LENGTH>0) {
            chapterNumber+=1;
        }
        lBook.chapterNumber=chapterNumber;
        NSMutableArray *lChapterTitles=[NSMutableArray arrayWithCapacity:chapterNumber];
        NSMutableArray *lChapterOffsets=[NSMutableArray arrayWithCapacity:chapterNumber];
        NSInteger curLoction=0;
        for (int i=0; i<chapterNumber; i++) {
            if (i==chapterNumber-1) {
                NSString *lString=[lContent substringWithRange:NSMakeRange(i*TXT_CHAPTER_LENGTH, lContent.length-i*TXT_CHAPTER_LENGTH)];
                NSData *lData=[lString dataUsingEncoding:lBook.codeType];
                NSString *lTitle=[lBook.title stringByAppendingFormat:@"-%i",i];
                NSRange lRange=NSMakeRange(curLoction, lData.length);
                curLoction+=lData.length;
                [lChapterTitles addObject:lTitle];
                [lChapterOffsets addObject:NSStringFromRange(lRange)];
            }else{
                NSString *lString=[lContent substringWithRange:NSMakeRange(i*TXT_CHAPTER_LENGTH, TXT_CHAPTER_LENGTH)];
                NSData *lData=[lString dataUsingEncoding:lBook.codeType];
                NSString *lTitle=[lBook.title stringByAppendingFormat:@"-%i",i];
                NSRange lRange=NSMakeRange(curLoction, lData.length);
                curLoction+=lData.length;
                [lChapterTitles addObject:lTitle];
                [lChapterOffsets addObject:NSStringFromRange(lRange)];
            }
        }
        lBook.chapterOffset=[lChapterOffsets copy];
        lBook.chapterTitles=[lChapterTitles copy];
    }
    @catch (NSException *exception) {
        lBook.error=kException;
    }
    @finally {
        return lBook;
    }
    
}
#pragma mark - Private Method
-(NSString *)getContanerPathWith:(NSString *)contentPath{
    NSString *lPath=[contentPath stringByAppendingPathComponent:@"META-INF/container.xml"];
    if ([[NSFileManager defaultManager]fileExistsAtPath:lPath]==NO) {
        return nil;
    }
    return lPath;
}
-(NSInteger)getShortInt:(NSData *)data withIndex:(NSInteger)index{
    NSData *lData=[data subdataWithRange:NSMakeRange(index, 1)];
    NSInteger value=0;
    [lData getBytes:&value length:sizeof(value)];
    return value;
}
-(NSInteger)getMediumInt:(NSData *)data withIndex:(NSInteger)index{
    NSData *lData=[data subdataWithRange:NSMakeRange(index, 2)];
    NSInteger value=0;
    [lData getBytes:&value length:sizeof(value)];
    return value;
}
-(NSInteger)getInt:(NSData *)data withIndex:(NSInteger)index{
    NSData *lData=[data subdataWithRange:NSMakeRange(index, 4)];
    NSInteger value=0;
    [lData getBytes:&value length:sizeof(value)];
    return value;
}
-(NSString *)getString:(NSData *)data withIndex:(NSInteger)index andLength:(NSInteger)length{
    NSData *lData=[data subdataWithRange:NSMakeRange(index, length)];
    return [NSString stringWithCharacters:[lData bytes] length:length];
}
-(NSData *)getData:(NSData *)data withIndex:(NSInteger)index andLength:(NSInteger)length{
    NSData *lData=[data subdataWithRange:NSMakeRange(index, length)];
    return lData;
}
@end
