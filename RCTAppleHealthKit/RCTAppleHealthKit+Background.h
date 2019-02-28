//
//  RCTAppleHealthKit+Background.h
//  RCTAppleHealthKit
//
//  Created by Eric Chavez on 2/25/19.
//  Copyright © 2019 Greg Wilson. All rights reserved.
//

#import "RCTAppleHealthKit.h"

@interface RCTAppleHealthKit (Background)

- (void)background_enableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)background_disableBackgroundDelivery:(NSDictionary *)input callback:(RCTResponseSenderBlock)callback;
- (void)background_initializeListenersWithCallback:(RCTResponseSenderBlock)callback;

@end
