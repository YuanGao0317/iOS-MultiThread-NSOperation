//
//  OperationController.m
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "OperationController.h"
#import "StaticConsts.h"


@implementation OperationController

-(instancetype)initOperationController
{
    self = [self init];
    
    if (self) {
        NSOperationQueue *imageDownloadQueue = [[NSOperationQueue alloc] init];
        imageDownloadQueue.name = kImageDownloadQueue;
        _imageDownloadQueue = imageDownloadQueue;
        
        NSOperationQueue *downloadDataSourceQueue = [[NSOperationQueue alloc] init];
        downloadDataSourceQueue.name = kDownloadDataSourceQueue;
        // maxConcurrentOperationCount = 1, serial queue
        downloadDataSourceQueue.maxConcurrentOperationCount = 1;
        _downloadDataSourceQueue = downloadDataSourceQueue;
        
        NSOperationQueue *imageFiltrationQueue = [[NSOperationQueue alloc] init];
        imageFiltrationQueue.name = kImageFiltrationQueue;
        _imageFiltrationQueue = imageFiltrationQueue;
        
        _downloadsInProgress = [NSMutableDictionary new];
        _filtrationsInProgress = [NSMutableDictionary new];
    }
    
    return self;
}



@end
