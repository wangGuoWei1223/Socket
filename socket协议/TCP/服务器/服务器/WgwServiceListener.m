//
//  WgwServiceListener.m
//  服务器
//
//  Created by niuwan on 16/7/27.
//  Copyright © 2016年 niuwan. All rights reserved.
//

#import "WgwServiceListener.h"
#import "GCDAsyncSocket.h"

@interface WgwServiceListener ()<GCDAsyncSocketDelegate>

@property (nonatomic, strong) GCDAsyncSocket *serverSocket;
/**  保存客户端socket  */
@property (nonatomic, strong) NSMutableArray *clientSockets;

@end

@implementation WgwServiceListener

- (NSMutableArray *)clientSockets {
    
    if (!_clientSockets) {
        _clientSockets = [NSMutableArray array];
    }
    return _clientSockets;
}
- (void)start {

    //1、创建一个Socket对象
    //服务器socket只有监听 有没有客户端请求连接
    GCDAsyncSocket *serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    //2、绑定端口号，并开启监听
    NSError *error = nil;
    [serverSocket acceptOnPort:5288 error:&error];
    if (!error) {
        
        NSLog(@"服务器开启成功");
    }else {
    
        NSLog(@"服务器开启失败");
    }
    
    self.serverSocket = serverSocket;
    
}

#pragma mark - 有客户端的socket连接到服务器
- (void)socket:(GCDAsyncSocket *)serverSocket didAcceptNewSocket:(GCDAsyncSocket *)clientSocket {
    
    NSLog(@"serverSocket:%@",serverSocket);
    NSLog(@"clientSocket:%@",clientSocket);
    
    //1、保存客户端socket
    [self.clientSockets addObject:clientSocket];
    
    //提供服务
    NSMutableString *serviceStr = [NSMutableString string];
    [serviceStr appendString:@"欢迎来到10086在线服务，请输入下面的数字选择服务\n"];
    [serviceStr appendString:@"[0]在线充值\n"];
    [serviceStr appendString:@"[1]在线投诉\n"];
    [serviceStr appendString:@"[2]优惠信息\n"];
    [serviceStr appendString:@"[3]special services\n"];
    [serviceStr appendString:@"[4]退出\n"];
    
    [clientSocket writeData:[serviceStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    //2、监听客户端有没有数据上传
    [clientSocket readDataWithTimeout:-1 tag:0];

}

#pragma mark - 读取客户端请求的数据

- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag {

    //1、把NSData转NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"接收客服的上传的数据:%@", str);

    //2、字符转数字
    NSInteger code = [str integerValue];
    NSString *responseStr = nil;
    switch (code) {
        case 0:
            responseStr = @"充值服务暂停中....\n";
            break;
        case 1:
            responseStr = @"投诉服务暂停中....\n";
            break;
        case 2:
            responseStr = @"优惠信息没有....\n";
            break;
        case 3:
            responseStr = @"别SB 怎么可能会有特殊服务....\n";
            break;
        case 4:
            responseStr = @"恭喜你退出成功....\n";
            break;
            
        default:
            break;
    }
    
    [clientSocket writeData:[responseStr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    
    if (code == 4) {
        //移除客户端
        [self.clientSockets removeObject:clientSocket];
    }
    
    [clientSocket readDataWithTimeout:-1 tag:0];
}

/******************************************************/

/*
 
- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag {

    //1、把NSData转NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"接收客服的上传的数据:%@", str);
    
    //2、处理请求,返回给客户端
    [clientSocket writeData:data withTimeout:-1 tag:0];
    
    //3、每次读完数据，都要调用一次监听数据的方法
    [clientSocket readDataWithTimeout:-1 tag:0];

}
 
*/

@end
