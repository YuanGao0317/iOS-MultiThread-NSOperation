//
//  ViewController.h
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"
#import "OperationController.h"
#import "ImageDownloadOperation.h"
#import "ImageFiltrationOperation.h"

@interface ViewController : UIViewController


@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray <Photo *> *photos;

@property (nonatomic,strong) OperationController *operationController;

@end

