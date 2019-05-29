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

/**
 * Obtains process information with specified pid.
 * @return Instance with process information or nil if pid is invalid or any error has occurred.
 */
+ (nullable instancetype)processWithPid:(const pid_t)pid;

@end


static const NSTimeInterval PMDefaultRefreshFrequency = 5.0;

@interface PMProcessMonitor : NSObject

@property (strong, readonly, atomic) NSArray<PMProcess *> *allProcesses;

/// Default shared instance to monitor that allows monitoring of all processes.
+ (instancetype)defaultMonitor;

/// Creates monitor instance with non-default refresh frequency.
- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency;

/// Creates monitor instance with specified refresh frequency that monitors processes of exact user.
- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency forUser:(const uid_t)user NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

/// Returns filtered list of processes matching predicate.
- (NSArray<PMProcess *> *)filteredProcessesWithBlock:(BOOL(^)(PMProcess *const))filter;

@end

NS_ASSUME_NONNULL_END
