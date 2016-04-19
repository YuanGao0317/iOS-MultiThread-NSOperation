//
//  ImageFiltrationOperation.h
//  MultiThreadExample
//
//  Created by GaoYuan on 16/2/28.
//  Copyright © 2016年 GaoYuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface ImageFiltrationOperation : NSOperation
@property (nonatomic,strong) Photo *photo;

-(instancetype) initWithPhoto:(Photo *)photo;
@end
