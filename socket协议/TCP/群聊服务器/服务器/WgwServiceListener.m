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
    NSLog(@"clientSocket:%@ host:%@ port:%d address:%@", clientSocket, clientSocket.connectedHost, clientSocket.connectedPort, clientSocket.connectedAddress);
    
    //1、保存客户端socket
    [self.clientSockets addObject:clientSocket];
    
    //2、监听客户端有没有数据上传
    [clientSocket readDataWithTimeout:-1 tag:0];

    NSLog(@"当前有%ld 客户已经连接到服务器",self.clientSockets.count);
}

#pragma mark - 读取客户端请求的数据

- (void)socket:(GCDAsyncSocket *)clientSocket didReadData:(NSData *)data withTag:(long)tag {

    //1、把NSData转NSString
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"接收客服的上传的数据:%@", str);

    for (GCDAsyncSocket *socket in self.clientSockets) {
        
        if (socket != clientSocket) {
            // 不用发给自己
            [socket writeData:data withTimeout:-1 tag:0];
        }
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
