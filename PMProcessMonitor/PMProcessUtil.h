//
//  PMProcessUtil.h
//  PMProcessMonitor
//
//  Created by Alk on 3/7/19.
//  Copyright © 2019 Alk. All rights reserved.
//

#import "PMProcessMonitor.h"

NS_ASSUME_NONNULL_BEGIN

@interface PMProcessUtil : NSObject

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;

- (NSArray<NSNumber *> *)collectPidsForUser:(const uid_t)user;
- (nullable NSNumber *)processUidForPid:(const pid_t)pid;
- (nullable NSString *)processNameForPid:(const pid_t)pid;
- (nullable NSURL *)processLocationForPid:(const pid_t)pid;

@end

NS_ASSUME_NONNULL_END
