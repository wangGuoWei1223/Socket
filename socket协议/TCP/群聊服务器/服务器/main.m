//
//  main.m
//  服务器
//
//  Created by niuwan on 16/7/27.
//  Copyright © 2016年 niuwan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WgwServiceListener.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        //1、创建服务监听对象
        WgwServiceListener *serviceListener = [[WgwServiceListener alloc] init];
        
        //2、开始监听
        [serviceListener start];
        
        //3、开启主运行循环，让服务器不能听
        [[NSRunLoop mainRunLoop] run];
    }
    return 0;
}
