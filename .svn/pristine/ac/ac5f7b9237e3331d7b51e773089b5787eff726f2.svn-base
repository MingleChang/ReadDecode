//
//  DownloadCell.m
//  BaiduWeb
//
//  Created by admin001 on 14-10-8.
//  Copyright (c) 2014年 MingleChang. All rights reserved.
//

#import "DownloadCell.h"
@interface DownloadCell()
@property (strong, nonatomic) IBOutlet UIProgressView *downloadProgress;
@property (strong, nonatomic) IBOutlet UILabel *nameText;
@property (strong, nonatomic) IBOutlet UILabel *progressText;

@end
@implementation DownloadCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setCellRequest:(ASIHTTPRequest *)request{
    [request setDownloadProgressDelegate:self];
    NSDictionary *lDic=[request userInfo];
    self.nameText.text=[lDic objectForKey:@"fileName"];
}

- (void)setProgress:(float)newProgress{
    NSLog(@"%f",newProgress);
    self.downloadProgress.progress=newProgress;
    int value=(int)(newProgress*100);
    self.progressText.text=[NSString stringWithFormat:@"%i%%",value];
}
-(void)downloadFinish{
    UITableView *lTableView=(UITableView *)self.superview.superview;
    NSIndexPath *lIndexPath=[lTableView indexPathForCell:self];
    [lTableView deleteRowsAtIndexPaths:@[lIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    
}
@end
