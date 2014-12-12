//
//  ViewController.h
//  s3-objectiveC
//
//  Created by Barrett Breshears on 12/5/14.
//  Copyright (c) 2014 Barrett Breshears. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AWSCore.h"
#import "S3.h"

@interface ViewController : UIViewController < UIImagePickerControllerDelegate, UINavigationControllerDelegate >

@property (nonatomic, strong) IBOutlet UIImageView *selectedImage;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIView *loadingBg;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *progressLabel;

@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest;
@property (nonatomic) uint64_t filesize;
@property (nonatomic) uint64_t amountUploaded;


- (IBAction)cameraBtnClicked:(id)sender;
- (IBAction)galleryBtnClicked:(id)sender;
- (IBAction)uploadBtnClicked:(id)sender;

@end

