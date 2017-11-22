//
//  imageSelectViewController.m
//  BeautyDiary
//
//  Created by bilian shen on 2017/11/20.
//  Copyright © 2017年 Insigma HengTian Software Ltd. All rights reserved.
//

#import "ImageSelectViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "CapImagePickerViewController.h"

@interface ImageSelectViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *mViews;
@property (nonatomic, strong) NSMutableDictionary *indexToImageDic;

@end

@implementation ImageSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.collectionView];
    // 获取蒙版
    [self getMViews];
}

- (void)getMViews {
    [self.mViews addObjectsFromArray:@[@"http://pic.58pic.com/58pic/13/79/29/70V58PICjch_1024.jpg", @"http://pic40.nipic.com/20140416/9840082_121313466133_2.jpg", @"http://pic43.nipic.com/20140705/6608733_161118038000_2.jpg"]];
    [self.collectionView reloadData];
}

-(NSMutableArray *)mViews {
    if (!_mViews) {
        _mViews = [NSMutableArray array];
    }
    return _mViews;
}

- (NSMutableDictionary *)indexToImageDic {
    if (!_indexToImageDic) {
        _indexToImageDic = [NSMutableDictionary dictionary];
    }
    return _indexToImageDic;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 5;
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.itemSize = CGSizeMake(120, 120);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height - 64) collectionViewLayout:layout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"imageCollectionCell"];
        
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.mViews.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"imageCollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
    imageView.backgroundColor = [UIColor yellowColor];
    NSLog(@"%@", self.mViews[indexPath.row]);
    [imageView sd_setImageWithURL:[NSURL URLWithString:self.mViews[indexPath.row]] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (!error && image) {
            imageView.image = image;
        }
        else {
            NSLog(@"%@", error);
        }
    }];
    [cell addSubview:imageView];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    CapImagePickerViewController *imagePicker = [[CapImagePickerViewController alloc] init];
    imagePicker.imageURL = self.mViews[indexPath.row];
    [self presentViewController:imagePicker animated:YES completion:nil];
}



@end
