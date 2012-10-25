//
//  ViewController.h
//  webserviceQueueSample
//
//  Created by Matthew Propst on 10/24/12.
//  Copyright (c) 2012 http://prop.st All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController{
    BOOL isReachable;
    BOOL hasQueue;
}

@property (weak) IBOutlet UIButton *triggerServiceBtn;

- (void)triggeredService;
- (void)sendQueueToServer;

@end
