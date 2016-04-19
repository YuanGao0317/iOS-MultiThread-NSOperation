//
//  ImageDownloadOperation.h
//  MultiThread
//
//  Created by GaoYuan on 16/2/27.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import "Photo.h"

@interface ImageDownloadOperation : NSOperation
@property (nonatomic,strong) Photo *photo;

-(instancetype) initWithPhoto:(Photo *)photo;

@end
