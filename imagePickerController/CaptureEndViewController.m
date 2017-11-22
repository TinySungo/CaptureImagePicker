//
//  CaptureEndViewController.m
//  BeautyDiary
//
//  Created by bilian shen on 2017/11/22.
//  Copyright © 2017年 Insigma HengTian Software Ltd. All rights reserved.
//

#import "CaptureEndViewController.h"
#import "OperationSelectViewController.h"

@interface CaptureEndViewController ()

@end

@implementation CaptureEndViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.menuButton];
    [self.view addSubview:self.checkButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.25 animations:^{
        CGFloat buttonWidth = self.menuButton.frame.size.width;
        CGFloat padding = (self.view.frame.size.width -  buttonWidth* 3)/4;
        
        self.backButton.center = CGPointMake(padding + buttonWidth/2, _backButton.center.y);
        self.checkButton.center = CGPointMake(self.view.frame.size.width - padding - buttonWidth/2, _checkButton.center.y);
    }];
}

#pragma mark - getter

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.image = self.image;
    }
    return _imageView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake((self.view.frame.size.width-50)/2, (self.view.frame.size.height-80), 50, 50);
        _backButton.layer.cornerRadius = 25;
        [_backButton setImage:[UIImage imageNamed:@"return"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)menuButton {
    if (!_menuButton) {
        _menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _menuButton.frame = CGRectMake((self.view.frame.size.width-50)/2, (self.view.frame.size.height-80), 50, 50);
        _menuButton.layer.cornerRadius = 25;
        [_menuButton setImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
        [_menuButton addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _menuButton;
}

- (UIButton *)checkButton {
    if (!_checkButton) {
        _checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkButton.frame = CGRectMake((self.view.frame.size.width-50)/2, (self.view.frame.size.height-80), 50, 50);
        _checkButton.layer.cornerRadius = 25;
        [_checkButton setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
        [_checkButton addTarget:self action:@selector(checkButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkButton;
}


#pragma mark - setter

- (void)setImage:(UIImage *)image {
    _image = image;
    self.imageView.image = image;
}


#pragma mark - button clicked

- (void)backButtonClicked {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)menuButtonClicked {
    OperationSelectViewController *vc = [[OperationSelectViewController alloc] init];
    vc.image = self.image;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)checkButtonClicked {
    
}


@end
