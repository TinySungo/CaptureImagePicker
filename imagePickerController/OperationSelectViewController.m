//
//  OperationSelectViewController.m
//  BeautyDiary
//
//  Created by bilian shen on 2017/11/22.
//  Copyright © 2017年 Insigma HengTian Software Ltd. All rights reserved.
//

#import "OperationSelectViewController.h"
#import <TOCropViewController.h>

@interface OperationSelectViewController ()<UIScrollViewDelegate, TOCropViewControllerDelegate> {
    NSArray *items;
}

@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *headOperaView;
@property (nonatomic, strong) UIView *bottomOperaView;

@end

@implementation OperationSelectViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    items = @[@"pen", @"face", @"text", @"mosaic", @"crop"];
    
    [self.view addSubview:self.contentScrollView];
    [self.contentScrollView addSubview:self.imageView];
    self.contentScrollView.contentSize = self.imageView.frame.size;
    
    [self.view addSubview:self.headOperaView];
    [self.view addSubview:self.bottomOperaView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"%f, %f", self.headOperaView.center.x, self.headOperaView.center.y);
    [UIView animateWithDuration:0.25 animations:^{
        self.headOperaView.center = CGPointMake(_headOperaView.center.x, _headOperaView.frame.size.height/2.0);
        self.bottomOperaView.center = CGPointMake(_bottomOperaView.center.x,  self.view.frame.size.height - _bottomOperaView.frame.size.height/2.0);
    }];
}


#pragma mark - getter

- (UIScrollView *)contentScrollView {
    if (!_contentScrollView) {
        _contentScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _contentScrollView.delegate = self;
        _contentScrollView.maximumZoomScale = 2.5;
        _contentScrollView.minimumZoomScale = 1.0;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.showsHorizontalScrollIndicator = NO;        
    }
    return _contentScrollView;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.image = self.image;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeOperaViewHidden)];
        [_imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIView *)headOperaView {
    if (!_headOperaView) {
        _headOperaView = [[UIView alloc] initWithFrame:(CGRect){0, -44, self.view.frame.size.width, 44}];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:(CGRect){0, 0, 50, 44}];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_headOperaView addSubview:cancelButton];
        
        UIButton *completeButton = [[UIButton alloc] initWithFrame:(CGRect){self.view.frame.size.width-50, 0, 50, 44}];
        [completeButton setTitle:@"完成" forState:UIControlStateNormal];
        [completeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [completeButton addTarget:self action:@selector(completeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_headOperaView addSubview:completeButton];
    }
    return _headOperaView;
}

- (UIView *)bottomOperaView {
    if (!_bottomOperaView) {
        _bottomOperaView = [[UIView alloc] initWithFrame:(CGRect){0, self.view.frame.size.height, self.view.frame.size.width, 50}];
        
        CGSize buttonSize = CGSizeMake(25, 25);
        CGFloat padding = (_bottomOperaView.frame.size.width - buttonSize.width*items.count)/(items.count + 1);

        for (NSInteger index = 0; index < items.count; index++) {
            UIButton *operationButton = [[UIButton alloc] initWithFrame:(CGRect){padding*(index+1)+index*buttonSize.width, 10, buttonSize.width, buttonSize.height}];
            operationButton.tag = index;
            [operationButton setImage:[UIImage imageNamed:items[index]] forState:UIControlStateNormal];
            [operationButton addTarget:self action:@selector(operationButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomOperaView addSubview:operationButton];
        }
    }
    return _bottomOperaView;
}


#pragma mark - button clicked

- (void)cancelButtonClicked {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)completeButtonClicked {
    
}

- (void)operationButtonClicked:(UIButton *)button {
    switch (button.tag) {
        case 4: {
            TOCropViewController *cropViewController = [[TOCropViewController alloc] initWithImage:self.image];
            cropViewController.delegate = self;
            [self presentViewController:cropViewController animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }

}


#pragma mark - TOCropViewControllerDelegate

- (void)cropViewController:(TOCropViewController *)cropViewController didCropToImage:(UIImage *)image withRect:(CGRect)cropRect angle:(NSInteger)angle
{
    // 新的image
    [self reloadImageViewWithImage:image];
    [cropViewController dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark - 修改imageView的图片

- (void)reloadImageViewWithImage:(UIImage *)image {
    self.imageView.frame = self.view.bounds;
    self.imageView.image = image;
}



#pragma mark - 手势

- (void)changeOperaViewHidden {
    self.headOperaView.hidden = !self.headOperaView.hidden;
    self.bottomOperaView.hidden = !self.bottomOperaView.hidden;
}


#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    NSLog(@"%f", scale);
    NSLog(@"%lf", scrollView.contentScaleFactor);
    NSLog(@"%f", scrollView.bounds.size.width);
}

@end
