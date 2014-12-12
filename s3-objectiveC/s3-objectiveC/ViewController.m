//
//  ViewController.m
//  s3-objectiveC
//
//  Created by Barrett Breshears on 12/5/14.
//  Copyright (c) 2014 Barrett Breshears. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark S3 stuff
- (void)uploadToS3{
    // get the image
    UIImage *img = _selectedImage.image;
    
    // create a local image that we can use to upload to s3
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"image.png"];
    NSData *imageData = UIImagePNGRepresentation(img);
    [imageData writeToFile:path atomically:YES];
    
    // once the image is saved we can use the path to create a local fileurl
    NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
    
    // next we set up the S3 upload request manager
    _uploadRequest = [AWSS3TransferManagerUploadRequest new];
    // set the bucket
    _uploadRequest.bucket = @"s3-demo-objectivec";
    // I want this image to be public to anyone to view it so I'm setting it to Public Read
    _uploadRequest.ACL = AWSS3ObjectCannedACLPublicRead;
    // set the image's name that will be used on the s3 server. I am also creating a folder to place the image in
    _uploadRequest.key = @"foldername/image.png";
    // set the content type
    _uploadRequest.contentType = @"image/png";
    // we will track progress through an AWSNetworkingUploadProgressBlock
    _uploadRequest.body = url;
    
    __weak ViewController *weakSelf = self;
    
    _uploadRequest.uploadProgress =^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.amountUploaded = totalBytesSent;
            weakSelf.filesize = totalBytesExpectedToSend;
            [weakSelf update];
            
        });
    };
    
    // now the upload request is set up we can creat the transfermanger, the credentials are already set up in the app delegate
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    // start the upload
    [[transferManager upload:_uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        
        // once the uploadmanager finishes check if there were any errors
        if (task.error) {
            NSLog(@"%@", task.error);
        }else{// if there aren't any then the image is uploaded!
            // this is the url of the image we just uploaded
            NSLog(@"https://s3.amazonaws.com/s3-demo-objectivec/foldername/image.png");
        }
        
        return nil;
    }];
    
}

- (void) update{
    _progressLabel.text = [NSString stringWithFormat:@"Uploading:%.0f%%", ((float)self.amountUploaded/ (float)self.filesize) * 100];
}


#pragma mark camera and ibaction stuff
- (IBAction)cameraBtnClicked:(id)sender{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)galleryBtnClicked:(id)sender{
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)uploadBtnClicked:(id)sender{
    [self createLoadingView];
    [self uploadToS3];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.selectedImage.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
}

- (void)createLoadingView{
    _loadingBg = [[UIView alloc] initWithFrame:self.view.frame];
    [_loadingBg setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
    [self.view addSubview:_loadingBg];
    
    _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    _progressView.center = self.view.center;
    [_progressView setBackgroundColor:[UIColor whiteColor]];
     [_loadingBg addSubview:_progressView];
    
    _progressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
    [_progressLabel setTextAlignment:NSTextAlignmentCenter];
    [_progressView addSubview:_progressLabel];
    
    _progressLabel.text = @"Uploading:";
    
}

- (void)removeLoadingView{
 
    [_loadingBg removeFromSuperview];
    
}

@end
