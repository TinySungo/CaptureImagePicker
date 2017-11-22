//
//  CapImagePickerViewController.h
//  BeautyDiary
//
//  Created by bilian shen on 2017/11/14.
//  Copyright © 2017年 Insigma HengTian Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CapImagePickerViewController : UIViewController

@property (nonatomic, strong) NSString *imageURL;

@end


@interface CaptureView : UIView

@property (nonatomic, strong) UIButton *toggleButton; // 前后摄像头切换按钮
@property (nonatomic, strong) UIButton *shutterButton; // 拍照按钮
@property (nonatomic, strong) UIButton *closeButton; // 关闭按钮
@property (nonatomic, strong) UIImageView *maskView; // 蒙版
@property (nonatomic, strong) UIView *focusCircle; // 聚焦的框

- (void)setFocusCursorAnimationWithPoint:(CGPoint)point; //focusCircle的位置修改


@end
