//
//  ViewController.m
//  客户端
//
//  Created by niuwan on 16/7/28.
//  Copyright © 2016年 niuwan. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

@interface ViewController ()<GCDAsyncSocketDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *textField;
- (IBAction)send;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**  <#Description#>  */
@property (nonatomic, strong) GCDAsyncSocket *clientSocket;
/**  数据源  */
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ViewController

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1.创建socket对象
    GCDAsyncSocket *socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    
    self.clientSocket = socket;
    
    //2.建立连接
    NSError *error = nil;
    [socket connectToHost:@"192.168.3.106" onPort:5288 error:&error];
    if (error) {
        NSLog(@"%@", error);
    }
    
}

#pragma mark - 连接到服务器
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {

    NSLog(@"成功与服务器建立连接");
    
    [sock readDataWithTimeout:-1 tag:0];
}
#pragma mark - 断开连接
- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    
    NSLog(@"与服务器断开连接%@", err);
}

#pragma mark - 接收到数据
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@", str);
    
    if (str) {
        [self.dataSource addObject:str];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            [self.tableView reloadData];
        }];
        
        [sock readDataWithTimeout:-1 tag:0];
    }
}
#pragma mark - 数据源
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *ID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID forIndexPath:indexPath];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;

}

- (IBAction)send {
    
    NSString *str = self.textField.text;
    if (str.length == 0) {
        return;
    }
    [self.dataSource addObject:str];
    
    self.textField.text = nil;
    //刷新数据
    [self.tableView reloadData];
    
    [self.clientSocket writeData:[str dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
}
@end
