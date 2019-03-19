//
//  RCTAppleHealthKit+Background.m
//  RCTAppleHealthKit
//
//  Created by Eric Chavez on 2/25/19.
//  Copyright © 2019 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit+Background.h"
#import "RCTAppleHealthKit+Queries.h"
#import "RCTAppleHealthKit+Utils.h"

#import <React/RCTBridgeModule.h>
#import <React/RCTEventDispatcher.h>

@implementation RCTAppleHealthKit (Background)

NSArray *kTypes = nil;

- (void)background_enableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    if (!kTypes)
    {
        kTypes = @[
                   [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount],
                   [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass],
                   [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyTemperature]
                   ];
    }
    
    dispatch_group_t group = dispatch_group_create();
    __block BOOL completedSuccessfully = YES;
    
    dispatch_group_notify(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (completedSuccessfully)
        {
            [self background_initializeListenersWithCallback:callback];
        }
    });
    
    for (HKSampleType *type in kTypes)
    {
        dispatch_group_enter(group);
        [self.healthStore enableBackgroundDeliveryForType:type
                                                frequency:HKUpdateFrequencyHourly
                                           withCompletion:^(BOOL success, NSError * _Nullable error) {
                                               dispatch_group_leave(group);
                                               completedSuccessfully = completedSuccessfully && success;
                                           }];
    }
}

- (void)background_disableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    [self.healthStore disableAllBackgroundDeliveryWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

- (void)background_initializeListenersWithCallback:(RCTResponseSenderBlock)callback
{
    for (HKSampleType *type in kTypes)
    {
        HKObserverQuery *query =
        [[HKObserverQuery alloc]
         initWithSampleType:type
         predicate:nil
         updateHandler:^(HKObserverQuery *query,
                         HKObserverQueryCompletionHandler completionHandler,
                         NSError *error) {
             
             if (error)
             {
                 // Perform Proper Error Handling Here...
                 NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***", error.localizedDescription);
                 callback(@[RCTMakeError(@"An error occured while setting up the stepCount observer", error, nil)]);
                 return;
             }
             
             NSString *name = [NSString stringWithFormat:@"change:%@", type.identifier];
             NSLog(@"*** Firing event named: %@", name);
             
             [self.bridge.eventDispatcher sendAppEventWithName:name
                                                          body:@{@"name": name}];
             
             completionHandler();
         }];
        
        [self.healthStore executeQuery:query];
    }
}

@end
