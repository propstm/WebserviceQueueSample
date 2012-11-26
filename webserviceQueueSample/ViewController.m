//
//  ViewController.m
//  WebserviceQueueSample
//
//  Created by Matthew Propst on 10/24/12.
//  Copyright (c) 2012 http://prop.st All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()
-(void)reachabilityChanged:(NSNotification*)note;
@end

@implementation ViewController
@synthesize triggerServiceBtn = _triggerServiceBtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_triggerServiceBtn addTarget:self action:@selector(triggeredService) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(reachabilityChanged:) 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    Reachability * reach = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    reach.reachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            isReachable = YES;
        });
    };
    
    reach.unreachableBlock = ^(Reachability * reachability)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            isReachable = NO;
        });
    };
    
    [reach startNotifier];

    hasQueue = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    
    if([reach isReachable])
    {
        isReachable = TRUE;
        [self sendQueueToServer];
    }
    else
    {
        isReachable = NO;
    }
}

- (void)triggeredService{
    NSString *timeServiceTriggered = [NSString stringWithFormat:@"%.0f", [[NSDate date] timeIntervalSince1970]]; 
    if(!isReachable){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *queueArray = [[NSMutableArray alloc] init];
        
        if([[defaults arrayForKey:@"serviceQueue"] count] != 0){
            queueArray = [[defaults arrayForKey:@"serviceQueue"] mutableCopy];
            [queueArray addObject:timeServiceTriggered];
        }else{
            [queueArray addObject:timeServiceTriggered];
        }
        
        [defaults setObject:queueArray forKey:@"serviceQueue"];  
        hasQueue = YES;
    }else{
        NSLog(@"TIME SENT TO SERVICE: %@", timeServiceTriggered);
    }
}

- (void)sendQueueToServer{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *queueArray = [[defaults arrayForKey:@"serviceQueue"] mutableCopy];
    if(hasQueue && isReachable){
        if([queueArray count]>0){
            for (int i = 0; i<[queueArray count]; i++) {
                NSLog(@"TIME SENT TO SERVICE - CONNECTION RETURNED: %@", [queueArray objectAtIndex:i]);
            }
            //Clear the queue everything's been logged
            [defaults removeObjectForKey:@"serviceQueue"];
        }
    }
}

@end
