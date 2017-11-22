//
//  CapImagePickerViewController.m
//  BeautyDiary
//
//  Created by bilian shen on 2017/11/14.
//  Copyright © 2017年 Insigma HengTian Software Ltd. All rights reserved.
//

#import "CapImagePickerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CaptureEndViewController.h"
//#import <SDWebImage/UIImageView+WebCache.h>

@implementation CaptureView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubViews];
        [self setFocusCursorAnimationWithPoint:self.center];
    }
    return self;
}

- (void)initSubViews {
    CGFloat viewHeight = self.frame.size.height;
    CGFloat viewWidth = self.frame.size.width;
    
    self.toggleButton = [[UIButton alloc] initWithFrame:(CGRect){ viewWidth-50, 20, 30, 30 }];
    [self.toggleButton setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [self addSubview:self.toggleButton];
    
    self.shutterButton = [[UIButton alloc] initWithFrame:(CGRect){(viewWidth-50)/2, (viewHeight-100), 50, 50 }];
    [self.shutterButton setBackgroundImage:[UIImage imageNamed:@"button_shutter"] forState:UIControlStateNormal];
    [self addSubview:self.shutterButton];
    
    self.closeButton = [[UIButton alloc] initWithFrame:(CGRect){ (_shutterButton.frame.origin.x - 30)/2, _shutterButton.frame.origin.y + (_shutterButton.frame.size.height-30)/2 , 30, 30 }];
    [self.closeButton setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    [self addSubview:_closeButton];
    
    self.maskView = [[UIImageView alloc] initWithFrame:(CGRect){0, viewHeight/2, viewWidth, viewWidth*0.3}];
    self.maskView.userInteractionEnabled = NO;
    [self addSubview:_maskView];
    
    self.focusCircle = [[UIView alloc] initWithFrame:(CGRect){0, 0, 100, 100}];
    _focusCircle.layer.borderWidth = 1.0;
    _focusCircle.layer.borderColor = [UIColor greenColor].CGColor;
    [self addSubview:self.focusCircle];
}

- (void)setFocusCursorAnimationWithPoint:(CGPoint)point {
    // 修改就叫框的位置
    _focusCircle.hidden = NO;
    self.focusCircle.center = point;
    self.focusCircle.transform = CGAffineTransformIdentity;
    
    [UIView animateWithDuration:0.25 animations:^{
        _focusCircle.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _focusCircle.hidden = YES;
        });
    }];
}

@end


static CGFloat maxScale = 10.0;

@interface CapImagePickerViewController ()

@property (nonatomic, strong) AVCaptureSession *session; // 在 input 和 output 之间传递数据
@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureLayer;
@property (nonatomic, strong) AVCaptureDeviceInput *deviceInput;

@property (nonatomic, strong) CaptureView *captureView;

@end

@implementation CapImagePickerViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.captureView = [[CaptureView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_captureView];
    [self captureViewAddAction];
    
    [self initCapture];
    [self addGestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.session startRunning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.session stopRunning];
}


#pragma mark - 初始化视图

- (void)initCapture {
    self.session = [[AVCaptureSession alloc] init];
    self.deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:nil];
    
    NSDictionary *stillImageOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil];
    self.imageOutput = [[AVCaptureStillImageOutput alloc] init];
    [self.imageOutput setOutputSettings:stillImageOutputSettings];
    
    [self.session addInput:self.deviceInput];
    [self.session addOutput:self.imageOutput];
    
    // layer
    self.captureLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    _captureLayer.frame = _captureView.bounds;
    _captureLayer.zPosition = -1;
    [self.captureView.layer addSublayer:_captureLayer];
}


#pragma mark - 根据position获取input

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position {
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            self.captureDevice = device;
            return device;
        }
    }
    return nil;
}

- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}


#pragma mark - 手势

- (void)addGestureRecognizer {
    // 单击聚焦
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    [self.captureView addGestureRecognizer:singleTap];
    // 双击切换摄像头
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.captureView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // pinch手势放大缩小 -- 修改焦距
    UIPinchGestureRecognizer *pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeZoom:)];
    [self.captureView addGestureRecognizer:pinchGes];
}

#pragma mark - 按钮点击事件

- (void)captureViewAddAction {
    [_captureView.toggleButton addTarget:self action:@selector(toggleButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [_captureView.closeButton addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [_captureView.shutterButton addTarget:self action:@selector(shutterButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)toggleButtonClicked {
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        // 可以切换
        NSError *error;
        AVCaptureDeviceInput *newInput;
        AVCaptureDevicePosition position = [[self.deviceInput device] position];
        if (position == AVCaptureDevicePositionFront) {
            newInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        }
        else if (position == AVCaptureDevicePositionBack) {
            newInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        }
        else {
            return;
        }
        
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.deviceInput];

            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.deviceInput = newInput;
            }
            else {
                [self.session addInput:self.deviceInput];
            }
            [self.session commitConfiguration];
        }
        else {
            NSLog(@"toggle error: %@", error);
        }
    }
}

- (void)closeBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)shutterButtonClicked {
    AVCaptureConnection *videoConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        return;
    }
    // 拍照获取图片，是一个异步过程
    
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        if (imageDataSampleBuffer == NULL) {
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [UIImage imageWithData:imageData];
        [self jumpToCaptureEndWithImage:image];
    }];
}


- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(reSize);
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}

- (void)jumpToCaptureEndWithImage:(UIImage *)image {
    CaptureEndViewController *vc = [[CaptureEndViewController alloc] init];
    vc.image = image;
    [self presentViewController:vc animated:NO completion:nil];
}


#pragma mark - 单击聚焦

- (void)singleTap:(UITapGestureRecognizer *)ges {
    if (!_captureView.focusCircle.hidden) {
        return;
    }
    CGPoint point = [ges locationInView:self.view];
    CGPoint cameraPoint = [_captureLayer captureDevicePointOfInterestForPoint:point];
    [_captureView setFocusCursorAnimationWithPoint:point];
    
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:cameraPoint];
        }
    }];
}


//更改设备属性前一定要锁上
-(void)changeDevicePropertySafety:(void (^)(AVCaptureDevice *captureDevice))propertyChange{
    AVCaptureDevice *captureDevice= [_deviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    }else{
        [_session beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [_session commitConfiguration];
    }
}


#pragma mark - 双击切换摄像头

- (void)doubleTap:(UITapGestureRecognizer *)ges {
    [self toggleButtonClicked];
}


#pragma mark - 缩放修改焦距

- (void)changeZoom:(UIPinchGestureRecognizer *)ges {
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
//        CGFloat maxZoom = captureDevice.activeFormat.videoMaxZoomFactor;
        CGFloat current = captureDevice.videoZoomFactor;
        CGFloat gesScale = ges.scale;
        CGFloat nextFactor = 1.0;
        if (gesScale > 1.0) {
            nextFactor = MIN(gesScale*current, maxScale);
        }
        else {
            nextFactor = MAX(gesScale*current, 1.0);
        }
        [captureDevice rampToVideoZoomFactor:nextFactor withRate:10];
    }];
}

@end
