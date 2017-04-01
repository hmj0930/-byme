//
//  ViewController.m
//  蓝牙byme
//
//  Created by MJ on 2017/3/30.
//  Copyright © 2017年 韩明静. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "blueListTableViewCell.h"

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableview;

@property(nonatomic,strong)CBCentralManager *centeralManager;

@property(nonatomic,strong)NSArray *peripheralsArr;

@property(nonatomic,strong)CBPeripheral *peripheral;

@property(nonatomic,assign)BOOL isConnected;

@end

@implementation ViewController

-(UITableView *)tableview{
    
    if (_tableview==nil) {
        _tableview=[UITableView new];
        _tableview.delegate=self;
        _tableview.dataSource=self;
    }
    return _tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isConnected=NO;
    
    self.tableview.frame=[UIScreen mainScreen].bounds;
    [self.view addSubview:self.tableview];
    [self.tableview registerClass:[blueListTableViewCell class] forCellReuseIdentifier:NSStringFromClass([blueListTableViewCell class])];
    
    self.centeralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableview reloadData];
    });
    
//    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(abc)];
//    [self.tableview addGestureRecognizer:tap];
}

-(void)abc{
    
    [self.tableview reloadData];
}

#pragma mark----

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.peripheralsArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    blueListTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:NSStringFromClass([blueListTableViewCell class])];
    CBPeripheral *peripher=self.peripheralsArr[indexPath.row];
    cell.titleLabel.text=peripher.name;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
     CBPeripheral *peripher=self.peripheralsArr[indexPath.row];
    
    if (self.isConnected) {
        
        if (self.peripheral==peripher) {
            NSString *str=[NSString stringWithFormat:@"disconnect %@",peripher.name];
            UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *ok=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self disConnect:self.peripheral];
            }];
            
            [alertVC addAction:cancel];
            [alertVC addAction:ok];
            
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];

        }else{
            
            NSString *str=[NSString stringWithFormat:@"have connect %@",self.peripheral.name];
            UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            UIAlertAction *ok=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                [self disConnect:self.peripheral];
                [self.centeralManager connectPeripheral:peripher options:nil];
            }];
            
            [alertVC addAction:cancel];
            [alertVC addAction:ok];
            
            [self presentViewController:alertVC animated:YES completion:^{
                
            }];
        }
        
        
        
    }else{
        
        NSString *str=[NSString stringWithFormat:@"connect %@",peripher.name];
        UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancel=[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        UIAlertAction *ok=[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.centeralManager connectPeripheral:self.peripheralsArr[indexPath.row] options:nil];
        }];
        
        [alertVC addAction:cancel];
        [alertVC addAction:ok];
        
        [self presentViewController:alertVC animated:YES completion:^{
            
        }];
 
    }
    
    
}

#pragma mark----

-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    
    switch (central.state) {
        case CBManagerStatePoweredOn:
            [central scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
            break;
            
        default:
            NSLog(@"请打开蓝牙");
            break;
    }
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    if (peripheral) {
        
         NSMutableArray *arr=[NSMutableArray arrayWithArray:self.peripheralsArr];
    
        if (![self.peripheralsArr containsObject:peripheral]) {
           
            [arr addObject:peripheral];
        }
        
        self.peripheralsArr=[NSArray arrayWithArray:arr];
        
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    NSLog(@"success");
    self.peripheral=peripheral;
    peripheral.delegate=self;
    NSLog(@"%@",peripheral);
    NSLog(@"%@连接成功",peripheral.name);
    self.isConnected=YES;
    [peripheral discoverServices:nil];
}

-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSLog(@"fail");
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    
    if (error) {
        
    }
    
    for (CBService *service in peripheral.services) {
        NSLog(@"service%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:@"FFE0"]) {
            [peripheral discoverCharacteristics:nil forService:service];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    if (error) {
        
    }
    
    for (CBCharacteristic *character in service.characteristics) {
        NSLog(@"cgaracteric%@",character.UUID);
        if ([character.UUID.UUIDString isEqualToString:@"FFE4"]) {
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }
    }
}

-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        
    }
    
    if ([characteristic.UUID.UUIDString isEqualToString:@"FFE4"]) {
        
        [self read:characteristic.value];
    }
    
}

-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    NSString *str=[NSString stringWithFormat:@"已断开%@的连接，是否需要重新连接",peripheral.name];
    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [alertVC addAction:[UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self.centeralManager connectPeripheral:peripheral options:nil];
//        NSLog(@"%@重新连接成功",peripheral.name);
    }]];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

short angleX;
short angleY;
long ryhcurkey;
long ryhlastkey;
short pid;
short mylastKey,mylastspeed;


-(void)read:(NSData *)data{
    
    NSLog(@"========data%@",data);
    NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF32StringEncoding];
    NSLog(@"========str%@",str);
    
//    Byte *b=(Byte *)[data bytes];
//    for (int i=0; i<16; i++) {
//        NSLog(@"---%hhu",b[i]);
//    }
//   
//    
//    //<23000000 006f0000 00000000 d02425ff>
//    
//    if (data.length==16 && 0x23==b[0] && 0x25==b[14]) {
//        switch (b[12]) {
//            case 0xD0:
//                 ryhcurkey = b[4];
//                CGFloat tmpspeed=(int)b[1];
//                CGFloat hr = (int)b[2];
//                angleY = (signed char)b[9];
//                angleX = (signed char)b[10];
//                NSLog(@"speed===%lf",tmpspeed);
//                NSLog(@"heart===%lf",hr);
//                break;
//                
//            default:
//                break;
//        }
//    }
}

-(void)disConnect:(CBPeripheral *)peripher{
    
    [self.centeralManager cancelPeripheralConnection:peripher];
    peripher=nil;
}

@end
