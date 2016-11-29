//
//  ViewController.m
//  GZCircleSlider
//
//  Created by armada on 2016/11/24.
//  Copyright © 2016年 com.zlot.gz. All rights reserved.
//

#import "ViewController.h"
#import "GZCircleSlider.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    GZCircleSlider *slider = [[GZCircleSlider alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    slider.center = self.view.center;
    [self.view addSubview:slider];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
