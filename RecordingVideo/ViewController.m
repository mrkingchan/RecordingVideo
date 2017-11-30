//
//  ViewController.m
//  RecordingVideo
//
//  Created by Chan on 2017/1/16.
//  Copyright © 2017年 Chan. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    BOOL _isVideo;
    UIImagePickerController *_picker;
    AVPlayer *_player;
    UIImageView *_imageView;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUI];
}

- (void)setUI {
    _isVideo = YES;
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 200, 200)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
    _imageView.userInteractionEnabled = YES;
    _imageView.backgroundColor = [UIColor orangeColor];
    [_imageView addGestureRecognizer:tap];
    [self.view addSubview:_imageView];
}

#pragma mark --private Method
- (void)buttonAction:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        _picker = [UIImagePickerController new];
        //相机可用
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //后置摄像头
            if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
                _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            }
            if (_isVideo) {
                //视频
                _picker.mediaTypes = @[@"public.movie"];
                _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;  //录制视频
                _picker.videoMaximumDuration = 100;
                _picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
            } else {
                _picker.mediaTypes = @[@"public.image"];
                _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;  //拍照
            }
            _picker.delegate = self;
            _picker.allowsEditing = YES;
        }
    }
    [self presentViewController:_picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaTypeStr = [info  objectForKey:UIImagePickerControllerMediaType];
    if ([mediaTypeStr containsString:@"image"]) {
        _imageView.image = [info  objectForKey:UIImagePickerControllerEditedImage];
        //保存相片
        UIImageWriteToSavedPhotosAlbum([info objectForKey:UIImagePickerControllerEditedImage], self, nil, nil);
    } else if ([mediaTypeStr containsString:@"movie"]) {
        //视频
        NSString *videoUrlStr = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoUrlStr)) {
            //保存视频
            UISaveVideoAtPathToSavedPhotosAlbum(videoUrlStr, self, nil, nil);
        }
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

/*#pragma mark --初始化UI
- (void)setUI {
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    _imageView.backgroundColor = [UIColor orangeColor];
    _imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonAction:)];
    [_imageView addGestureRecognizer:tap];
    [self.view addSubview:_imageView];
    _isVideo = YES;
    _picker = [UIImagePickerController new];
    //相机可用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;//前置摄像头
        }
        if (_isVideo) {
            _picker.mediaTypes = @[@"public.movie"];
            _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
            _picker.videoMaximumDuration = 100;
            _picker.videoQuality = UIImagePickerControllerQualityTypeIFrame1280x720;
        } else {
            _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            _picker.mediaTypes = @[@"public.image"];
        }
    }
    //自定义相机View
    UIView *overlayerview = [[UIView alloc] initWithFrame:self.view.bounds];
    overlayerview.layer.backgroundColor = [UIColor clearColor].CGColor;
    //相机按钮
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 20, [UIScreen mainScreen].bounds.size.height - 60, 40, 40);
    [cameraButton setImage:[UIImage imageNamed:@"start"] forState:UIControlStateNormal];
    [cameraButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateSelected];
    [cameraButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [overlayerview addSubview:cameraButton];
    _picker.cameraOverlayView = overlayerview;
    _picker.showsCameraControls = NO;
    _picker.delegate = self;
}

#pragma mark --private Method
- (void)buttonAction:(id)sender {
    if ([sender isKindOfClass:[UITapGestureRecognizer class]]) {
        [self presentViewController:_picker animated:YES completion:nil];
    } else if ([sender isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)sender;
        button.selected = !button.selected;
        if (button.selected) {
            //开始录制视频
            [_picker startVideoCapture];
        } else {
            [_picker stopVideoCapture];
        }
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = [info  objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType containsString:@"image"]) {
        //拿到相机拍摄的照片
        UIImage *editImage = [info objectForKey:UIImagePickerControllerEditedImage];
        _imageView.image = editImage;
    } else if ([mediaType containsString:@"movie"]) {
        NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum([videoUrl path])) {
            //将视频保存相册
            UISaveVideoAtPathToSavedPhotosAlbum([videoUrl  path], self, nil, nil);
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        //录制完之后自动播放
        NSURL *url=[NSURL fileURLWithPath:videoPath];
        _player=[AVPlayer playerWithURL:url];
        AVPlayerLayer *playerLayer=[AVPlayerLayer playerLayerWithPlayer:_player];
        playerLayer.frame=_imageView.frame;
        [_imageView.layer addSublayer:playerLayer];
        [_player play];
    }
}*/
@end
