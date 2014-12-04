//
//  DownLoadManager.h
//  BaiduWeb
//
//  Created by admin001 on 14-9-30.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"
@interface DownLoadManager : NSObject
@property(nonatomic,strong)ASINetworkQueue *ASIQueue;
@property(nonatomic,strong)NSMutableArray *downloadInfos;

+(DownLoadManager *)share;
-(void)startDownloadFileWithFileName:(NSString *)fileName andFileURLString:(NSString *)urlString;
@end
