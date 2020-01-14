//
//  LocalCameraView.m
//  TestPushStream
//
//  Created by huxiaowei on 2017/5/9.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "LocalCameraView.h"
#import "Common.h"
#import "UIColor+hexColor.h"
#import <Masonry.h>
#import "SpreadButton.h"

#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)

@interface LocalCameraView () <VCSessionDelegate>
@property (strong, nonatomic) UIViewController *curViewController;
@property (assign, nonatomic) BOOL cameraIsOK;
@property (assign, nonatomic) BOOL micIsOK;
@end

@implementation LocalCameraView

- (instancetype)initWithOrientation:(BOOL)isProtrait {
    _isProtrait = isProtrait;
    self = [super init];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    CGRect curFrame;
    if (_isProtrait) {
        curFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);;
    } else {
        curFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    
    self = [super initWithFrame:curFrame];
    
    if(self) {
        [self initUIAndCheckDevice];
    }
    
    return self;
}

- (void)initUIAndCheckDevice {
    //判断摄像头
    
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        NSLog(@"Camera AVAuthorizationStatusAuthorized");
        _cameraIsOK = YES;
    }
    else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        NSLog(@"Camera AVAuthorizationStatusDenied");
    }
    else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
        NSLog(@"Camera AVAuthorizationStatusDenied");
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Camera Granted access to %@", mediaType);
                _cameraIsOK = YES;
            }
            else {
                NSLog(@"Camera Not granted access to %@", mediaType);
            }
        }];
    }
    else {
        // impossible, unknown authorization status
    }
    
    //判断麦克风
    mediaType = AVMediaTypeAudio;
    authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus == AVAuthorizationStatusAuthorized) {
        // do your logic
        NSLog(@"Mic AVAuthorizationStatusAuthorized");
        _micIsOK =  YES;
        
//        if(_cameraIsOK && _micIsOK) {
//            [self initSessionConfiguration];
//        }
    }
    else if(authStatus == AVAuthorizationStatusDenied){
        // denied
        NSLog(@"Mic AVAuthorizationStatusDenied");
    }
    else if(authStatus == AVAuthorizationStatusRestricted){
        // restricted, normally won't happen
        NSLog(@"Mic AVAuthorizationStatusDenied");
    }
    else if(authStatus == AVAuthorizationStatusNotDetermined){
        // not determined?!
        [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
            if(granted){
                NSLog(@"Mic Granted access to %@", mediaType);
                _micIsOK =  YES;
//                if(_cameraIsOK && _micIsOK) {
//                    [self initSessionConfiguration];
//                }
            }
            else {
                NSLog(@"Mic Not granted access to %@", mediaType);
            }
        }];
    }
    else {
        // impossible, unknown authorization status
    }
    if (_cameraIsOK&&_micIsOK) {
        [self initSessionConfiguration];
    } else {
        [self checkDeviceAndJumpToSetting];
    }
}

- (void)initSessionConfiguration {
    NSLog(@"initSessionConfiguration");
    VCSimpleSessionConfiguration* configuration = [[VCSimpleSessionConfiguration alloc] init];
    NSLog(@"isprotrait:%d",_isProtrait);
    if (!_isProtrait) {
        configuration.cameraOrientation = AVCaptureVideoOrientationLandscapeLeft;
        configuration.videoSize = CGSizeMake(1280, 720);
    }else {
        configuration.videoSize = CGSizeMake(720, 1280);
    }
    
    configuration.bitrate = 1200 * 1000;
    configuration.cameraDevice = VCCameraStateFront;
    configuration.profile = VCH264ProfileBaseline;
    configuration.continuousAutofocus = NO;
    configuration.continuousExposure = NO;
    
    self.session = [[VCSimpleSession alloc] initWithConfiguration:configuration];
    self.session.aspectMode = VCAspectModeFill;
    self.session.delegate = self;
    self.session.torch = YES;
    
    self.session.previewView.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)startStream:(NSString *)streamUrl {
    [self.session startRtmpSessionWithURL:streamUrl];
}

- (void)endStream {
    [self.session endRtmpSession];
}

#pragma mark - 闪光灯按钮点击
- (void)torchButtonClicked:(UIButton *)sender {
    if(self.session.cameraState == VCCameraStateFront) {
        if(!self.curViewController) {
            self.curViewController = [Common getViewController:self];
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"当前为前置摄像头，无法开启闪光灯" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self.curViewController presentViewController:alert animated:YES completion:nil];
    }
    else {
        sender.selected = !sender.selected;
        [self turnTorch];
    }
    
}

#pragma mark - 翻转摄像头按钮点击
- (void)switchCameraButtonClicked:(UIButton *)sender {
    NSLog(@"switchCameraButtonClicked");
    sender.selected = !sender.selected;
    [self.session switchCamera];
    if (!_isProtrait) {
        if (self.session.cameraState == 1) {
            self.transform = CGAffineTransformMakeRotation(2*M_PI);
        } else {
            self.transform = CGAffineTransformMakeRotation(M_PI);
        }
    }
}

#pragma mark - 推流按钮点击
- (void)streamStartButtonClicked:(UIButton *)sender {
//    if(_isPreview) {
//        return;
//    }
    
    if(!self.curViewController) {
        self.curViewController = [Common getViewController:self];
    }
    
    NSLog(@"streamStartButtonClicked,%d,%d,%@",_cameraIsOK,_micIsOK,self.curViewController);
    
    NSString *noticeMessage = @"开启直播";
    if(self.session.rtmpSessionState == VCSessionStateStarted) {
        noticeMessage = @"结束直播";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:noticeMessage preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self checkDeviceAndJumpToSetting];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }]];
    [self.curViewController presentViewController:alert animated:YES completion:nil];
}

- (void)checkDeviceAndJumpToSetting {
    if(!self.curViewController) {
        self.curViewController = [Common getViewController:self];
    }
    
    if(!_cameraIsOK) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法启动相机" message:@"请为OFweek开放相机权限：手机设置>隐私>相机>OFweek(打开)" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        
        [self.curViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    if(!_micIsOK) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法启动麦克风" message:@"请为OFweek开放麦克风权限：手机设置>隐私>麦克风>OFweek(打开)" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        
        [self.curViewController presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self.delegate localCameraViewStartButtonClicked];
}

// 判断设备是否有摄像头
- (BOOL) isCameraAvailable{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

// 前面的摄像头是否可用
- (BOOL) isFrontCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

// 后面的摄像头是否可用
- (BOOL) isRearCameraAvailable{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
}

#pragma mark - 闪光灯打开/关闭
- (void)turnTorch {
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch] && [device hasFlash]){
            NSError *error;
            if ([device lockForConfiguration:&error]) {
                if(device.flashMode == AVCaptureFlashModeOff) {
                    [device setTorchMode:AVCaptureTorchModeOn];
                    [device setFlashMode:AVCaptureFlashModeOn];
                }
                else if (device.flashMode == AVCaptureFlashModeOn) {
                    [device setTorchMode:AVCaptureTorchModeOff];
                    [device setFlashMode:AVCaptureFlashModeOff];
                }
                
                [device unlockForConfiguration];
            }
        }
    }
}

- (void)onError:(VCErrorCode)error {
    //    NSLog(@"onError:%@",error);
    
    
}

- (void)didAddCameraSource:(VCSimpleSession *)session {
    NSLog(@"didAddCameraSource");
    
    if (self.session) {
        NSLog(@"添加:%@",NSStringFromCGRect(self.session.previewView.frame));
        
        [self insertSubview:self.session.previewView atIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.session.previewView.frame = self.bounds;
            for (UIView* subview in self.session.previewView.subviews) {
                subview.frame = self.bounds;
            }
        });
        if (!_isProtrait) {
            self.transform = CGAffineTransformMakeRotation(M_PI);
        }
//        if (_delegate && [_delegate respondsToSelector:@selector(respondeTransfer)]) {
//            [_delegate respondeTransfer];
//        }
    }
    
}

#pragma mark - VCSessionDelegate
- (void) connectionStatusChanged: (VCSessionState) sessionState {
    BOOL isLived = NO;
    switch(sessionState) {
        case VCSessionStatePreviewStarted:
            NSLog(@"A");
            //            [_streamStartButton setImage:[UIImage imageNamed:@"streamStart"] forState:UIControlStateNormal];
            isLived = NO;
            break;
        case VCSessionStateStarting:
            NSLog(@"B");
            //            NSLog(@"Current state is VCSessionStateStarting\n");
            //            [_streamStartButton setImage:[UIImage imageNamed:@"streamStart"] forState:UIControlStateNormal];
            isLived = NO;
            break;
        case VCSessionStateStarted:
            NSLog(@"C");
            NSLog(@"Current state is VCSessionStateStarted\n");
            //            [_streamStartButton setImage:[UIImage imageNamed:@"streamStop"] forState:UIControlStateNormal];
            isLived = YES;
            break;
        case VCSessionStateError:
            NSLog(@"D");
            NSLog(@"Current state is VCSessionStateError\n");
            //            [_streamStartButton setImage:[UIImage imageNamed:@"streamStart"] forState:UIControlStateNormal];
            isLived = NO;
            break;
        case VCSessionStateEnded:
            NSLog(@"E");
            NSLog(@"Current state is VCSessionStateEnded\n");
            //            [_streamStartButton setImage:[UIImage imageNamed:@"streamStart"] forState:UIControlStateNormal];
            isLived = NO;
            break;
        default:
            NSLog(@"F");
            break;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(ExpoIsLive:)]) {
        [_delegate ExpoIsLive:isLived];
    }
}

@end
