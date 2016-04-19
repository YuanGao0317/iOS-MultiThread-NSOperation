//
//  ImageDownloadOperation.m
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "ImageDownloadOperation.h"
#import "StaticConsts.h"


@implementation ImageDownloadOperation

-(instancetype) initWithPhoto:(Photo *)photo
{
    self = [self init];
    
    if (self) {
        _photo = photo;
    }
    
    return self;
}

-(void)main
{
    if (self.cancelled) {
        return;
    }
    
    NSData *imageData = [NSData dataWithContentsOfURL:self.photo.url];
    
    if (self.cancelled) {
        return;
    }
    
    if (imageData.length > 0) {
        self.photo.image = [UIImage imageWithData:imageData];
        self.photo.state = PhotoStateDownloaded;
    } else {
        self.photo.state = PhotoStateFailed;
        self.photo.image = [UIImage imageNamed:kNoImage];
    }
}

@end
