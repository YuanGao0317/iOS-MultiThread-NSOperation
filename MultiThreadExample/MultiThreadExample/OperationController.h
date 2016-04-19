//
//  OperationController.h
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OperationController : NSObject
@property (nonatomic,strong) NSMutableDictionary *downloadsInProgress;  //[NSIndexPath:NSOperation]
@property (nonatomic,strong) NSMutableDictionary *filtrationsInProgress;  //[NSIndexPath:NSOperation]

@property (nonatomic,strong) NSOperationQueue *imageDownloadQueue;
@property (nonatomic,strong) NSOperationQueue *downloadDataSourceQueue;
@property (nonatomic,strong) NSOperationQueue *imageFiltrationQueue;


-(instancetype)initOperationController;
@end
