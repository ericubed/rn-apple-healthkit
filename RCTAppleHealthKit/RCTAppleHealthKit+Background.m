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

- (void)background_enableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    HKSampleType *sampleType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    [self.healthStore enableBackgroundDeliveryForType:sampleType
                                            frequency:HKUpdateFrequencyHourly
                                       withCompletion:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [self background_initializeListenersWithCallback:callback];
        } else if (error) {
            
        }
    }];
}

- (void)background_disableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback
{
    [self.healthStore disableAllBackgroundDeliveryWithCompletion:^(BOOL success, NSError * _Nullable error) {
        
    }];
}

- (void)background_initializeListenersWithCallback:(RCTResponseSenderBlock)callback
{
    HKSampleType *sampleType =
    [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKObserverQuery *query =
    [[HKObserverQuery alloc]
     initWithSampleType:sampleType
     predicate:nil
     updateHandler:^(HKObserverQuery *query,
                     HKObserverQueryCompletionHandler completionHandler,
                     NSError *error) {
         
         if (error) {
             // Perform Proper Error Handling Here...
             NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***", error.localizedDescription);
             callback(@[RCTMakeError(@"An error occured while setting up the stepCount observer", error, nil)]);
             return;
         }
         
         [self.bridge.eventDispatcher sendAppEventWithName:@"change:steps"
                                                      body:@{@"name": @"change:steps"}];
         
         completionHandler();
     }];
    
    [self.healthStore executeQuery:query];
}



//HKSampleType *sampleType =
//[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
//
//HKObserverQuery *query =
//[[HKObserverQuery alloc]
// initWithSampleType:sampleType
// predicate:nil
// updateHandler:^(HKObserverQuery *query,
//                 HKObserverQueryCompletionHandler completionHandler,
//                 NSError *error) {
//
//     if (error) {
//         // Perform Proper Error Handling Here...
//         NSLog(@"*** An error occured while setting up the stepCount observer. %@ ***", error.localizedDescription);
//         callback(@[RCTMakeError(@"An error occured while setting up the stepCount observer", error, nil)]);
//         return;
//     }
//
//     [self.bridge.eventDispatcher sendAppEventWithName:@"change:steps"
//                                                  body:@{@"name": @"change:steps"}];
//
//     // If you have subscribed for background updates you must call the completion handler here.
//     // completionHandler();
//
// }];
//
//[self.healthStore executeQuery:query];

@end
