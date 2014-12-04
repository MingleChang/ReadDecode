//
//  DownLoadManager.m
//  BaiduWeb
//
//  Created by admin001 on 14-9-30.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "DownLoadManager.h"
#import "DownloadCell.h"
#import "BookManager.h"
#import "Book.h"
#define MAX_DOWNLOADING_COUNT 3

#define DownloadPath    BOOK_FILE_PATH
#define DownloadTempPath    @"/Users/gaolong/Desktop/TempDownLoad"

@interface DownLoadManager()

@end

@implementation DownLoadManager
+(DownLoadManager *)share{
    static DownLoadManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance=[[DownLoadManager alloc]init];
    });
    return _sharedInstance;
}
-(instancetype)init{
    self=[super init];
    if (self) {
        [self checkAndCreateDir];
        
        self.downloadInfos=[[NSMutableArray alloc]init];
        
        self.ASIQueue=[[ASINetworkQueue alloc]init];
        self.ASIQueue.maxConcurrentOperationCount=MAX_DOWNLOADING_COUNT;
        [self.ASIQueue setShowAccurateProgress:YES];
        [self.ASIQueue setShouldCancelAllRequestsOnFailure:NO];
        [self.ASIQueue go];
    }
    return self;
}
-(void)checkAndCreateDir{
    if (![[NSFileManager defaultManager] fileExistsAtPath:DownloadPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DownloadPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:DownloadTempPath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:DownloadTempPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
}
-(void)startDownloadFileWithFileName:(NSString *)fileName andFileURLString:(NSString *)urlString{
    
    ASIHTTPRequest *lRequest=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    [lRequest setDownloadDestinationPath:[DownloadPath stringByAppendingPathComponent:fileName]];
    [lRequest setTemporaryFileDownloadPath:[DownloadTempPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"download"]]];
    [lRequest setDownloadProgressDelegate:self];
    [lRequest setDelegate:self];
    
    [lRequest setShouldContinueWhenAppEntersBackground:YES];
    [lRequest setAllowCompressedResponse:NO];
    [lRequest setAllowResumeForFileDownloads:YES];
    
    [lRequest setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:fileName,@"fileName",urlString,@"urlString",nil]];
    [self.ASIQueue addOperation:lRequest];
    [self.downloadInfos addObject:lRequest];
}
#pragma mark - ASIHTTPRequest Delegate
- (void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"%@:Started",[[request userInfo]objectForKey:@"fileName"]);
}
- (void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"%@:Finished",[[request userInfo]objectForKey:@"fileName"]);
    if (request.downloadProgressDelegate&&[request.downloadProgressDelegate isMemberOfClass:[DownloadCell class]]) {
        DownloadCell *lCell=(DownloadCell *)request.downloadProgressDelegate;
        [lCell downloadFinish];//下载成功将Cell移除
        
    }
    NSString *lFilePath=[BOOK_FILE_PATH stringByAppendingPathComponent:[request.userInfo objectForKey:@"fileName"]];
    Book *lBook=[[BookManager share]decoderBookWith:lFilePath];//对下载的书进行解析
    if (lBook==nil||lBook.error!=kNone) {
        [[NSFileManager defaultManager]removeItemAtPath:lFilePath error:nil];
        return;
    }
    [[BookManager share].books addObject:lBook];
    [[BookManager share]saveAllBooks];
}
- (void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"%@:Failed",[[request userInfo]objectForKey:@"fileName"]);
    if (request.downloadProgressDelegate&&[request.downloadProgressDelegate isMemberOfClass:[DownloadCell class]]) {
        DownloadCell *lCell=(DownloadCell *)request.downloadProgressDelegate;
        [lCell downloadFinish];
    }
}

- (void)setProgress:(float)newProgress{
    NSLog(@"%f",newProgress);
}
@end
