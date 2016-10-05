//
//  ViewController.m
//  GCD
//
//  Created by QuangLoc on 10/5/16.
//  Copyright © 2016 QuangLoc. All rights reserved.
//

#import "ViewController.h"

typedef void (^finishBlock) (BOOL finish, id data);

typedef void (^name)(BOOL fnish, UIImage *img);

#define LINK @"http://weknowyourdreams.com/images/beautiful/beautiful-0%@.jpg"


@interface ViewController (){
    
}

@property (nonatomic, strong) IBOutlet UIImageView *imv;

@property (nonatomic, strong) NSMutableArray<UIImage*> *arrImg;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!_arrImg) {
        _arrImg = [NSMutableArray array];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onBtnDownload:(id)sender {
    
    NSOperationQueue *queue = [NSOperationQueue new];
    [queue setMaxConcurrentOperationCount:2];
    
    
    for (unsigned int i = 0; i < 5; i++) {
        
        NSBlockOperation *blockOper1 = [NSBlockOperation blockOperationWithBlock:^{
            
            NSLog(@"start sleep");
            unsigned int time = 2+i;
            sleep(time);
            NSLog(@"stop sleep");
            
        }];
        
        [blockOper1 setName:[NSString stringWithFormat:@"Name %d", i]];
        
        
        NSBlockOperation *blockOper2 = [NSBlockOperation blockOperationWithBlock:^{
            
            NSLog(@"start sleep");
            unsigned int time = 2+i;
            sleep(time);
            NSLog(@"stop sleep");
            
        }];
        
        [blockOper2 setName:[NSString stringWithFormat:@"Name %d", i]];
        [blockOper2 addDependency:blockOper1];
        
        
        
        [queue addOperation:blockOper1];
        [queue addOperation:blockOper2];
        
        NSLog(@"queue count: %ld", queue.operationCount);
        
        /*
        void  (^myBlock)(void) = ^{
            NSLog(@"");
        };
        NSBlockOperation *blockOper2 = [NSBlockOperation blockOperationWithBlock:myBlock];
        */
    }
    
    NSLog(@"Het for");
    
    for (NSOperation *object in queue.operations) {
        if ([object.name isEqualToString:@"Name 3"]) {
            
            
            if (object.isExecuting) {
                object.cancelled;
            }
            
        }
    }
    
    [queue setSuspended:YES];
    [queue setSuspended:NO];
    
    
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"CHAY XONG HET for");

    
//    NSOperationQueue *queue = [NSOperationQueue mainQueue];
//    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    
    
}


- (void)sync{
    __block dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        // block1
        
        dispatch_group_enter(group);
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:LINK]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSLog(@"Download xong 8");
            dispatch_group_leave(group);
            
        }] resume];
        
        NSLog(@"Block1 End");
        
    });
    
    
    dispatch_group_async(group,dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^ {
        
        dispatch_group_enter(group);
        [[[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:LINK]completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSLog(@"Download xong 9");
            dispatch_group_leave(group);
            
        }] resume];
        
        
        NSLog(@"Block2 End");
        
    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"End onBtnDownload");

}


- (void)twoBlock{
    //__block UIImage *img69;
    
    NSLog(@"Start");
    
    //__weak ViewController *weakSelf = self;
    
    [self downloadImageFromURL:@"http://weknowyourdreams.com/images/beautiful/beautiful-09.jpg" withCallback:^(BOOL fnish, UIImage *img) {
        if (fnish) {
            NSLog(@"Downlaod xong 8");
            
            @synchronized (_arrImg) {
                [_arrImg addObject:img];
            }
            
        }else{
            
            NSLog(@"Downlaod sff");
        }
    }];
    
    [self downloadImageFromURL:@"http://weknowyourdreams.com/images/beautiful/beautiful-09.jpg" withCallback:^(BOOL fnish, UIImage *img) {
        if (fnish) {
            NSLog(@"Downlaod xong 9");
            
            [_arrImg addObject:img];
            
        }else{
            
            NSLog(@"Downlaod sff");
        }
    }];
    
    
    NSLog(@"Download done !!!");
    
    
    NSLog(@"End");
}


- (void)downloadImageFromURL:(NSString*)str withCallback:(name)callback{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        
        UIImage *img = nil;
        
        NSURL *url = [NSURL URLWithString:str];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        if (data) {
            img = [UIImage imageWithData:data];
        }
        
        if (callback) {
            callback(YES, img);
        }
    });
}
















#pragma mark - NSOperationQueue, NSOperation...

- (void)useNSOperationQueue{
    
    NSOperationQueue *queue = [NSOperationQueue new];
    
//    NSOperationQueue *queue = [NSOperationQueue mainQueue];
//    NSOperationQueue *queue = [NSOperationQueue currentQueue];
    
    [queue setMaxConcurrentOperationCount:2];
    
//    [queue setSuspended:YES];
    
//    [queue cancelAllOperations];
    
//    [queue waitUntilAllOperationsAreFinished];
    
    
    
    for (NSInteger i=0; i<4; i++) {
        
        NSString *strURL = [NSString stringWithFormat:@"http://weknowyourdreams.com/images/beautiful/beautiful-0%@.jpg", [NSNumber numberWithInteger:i]];
        
        
        NSInvocationOperation *invo = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(downloadImageFromStrURL:) object:strURL];
        
        [queue addOperation:invo];
        
        
         NSBlockOperation *blockOper = [NSBlockOperation blockOperationWithBlock:^{
         
         }];
        
        [blockOper addExecutionBlock:^{
            
        }];
        
        //[blockOper addDependency:invo];
        
         
        [queue addOperationWithBlock:^{
            
        }];
        
    }
    
    [queue setSuspended:NO];
    
    
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"ALL DONE");
}











#pragma mark - Download function
- (UIImage *)downloadImageFromStrURL:(NSString*)strURL{
    UIImage *img = nil;
    
    NSURL *url = [NSURL URLWithString:strURL];
    if (url) {
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        img = [UIImage imageWithData:data];
    }
    
    return img;
}


- (void)downloadImageFromStrURL:(NSString*)strURL completion:(finishBlock)callback{
    UIImage *img = nil;
    
    NSURL *url = [NSURL URLWithString:strURL];
    if (url) {
        img = (UIImage*)[NSData dataWithContentsOfURL:url]; //lock here
    }
    
    if (callback) {
        callback(YES, img);
    }
}


- (UIImage *)downloadImage2FromStrURL:(NSString*)strURL{
    
    __block UIImage *img = nil;
    
    NSURL *url = [NSURL URLWithString:strURL];
    
    if (url) {
        
        [UIView animateWithDuration:1 animations:^{
            
        }];
        
        NSURLSession *mainSession = [NSURLSession sharedSession];
        
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if (!error) {
                
                if (response) {
                    
                }
                
                if (data) {
                    
                }
                
            }
            
        }] resume];
    }
    
    return img;
}

@end
