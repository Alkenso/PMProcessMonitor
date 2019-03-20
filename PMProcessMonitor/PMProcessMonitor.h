//
//  PMProcessMonitor.h
//  PMProcessMonitor
//
//  Created by Alk on 3/7/19.
//  Copyright © 2019 Alk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PMProcess : NSObject

@property (readonly, nonatomic) pid_t pid;
@property (readonly, nonatomic) uid_t uid;
@property (copy, readonly, nonatomic) NSString *name;
@property (copy, readonly, nonatomic) NSURL *location;

+ (nullable instancetype)processWithPid:(const pid_t)pid;

@end


extern const uid_t PMAllProcesses;

@interface PMProcessMonitor : NSObject

@property (strong, readonly, atomic) NSArray<PMProcess *> *allProcesses;

+ (instancetype)defaultMonitor;

- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency;
- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency forUser:(const uid_t)user NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
