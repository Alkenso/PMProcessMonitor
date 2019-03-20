//
//  PMProcessUtil.m
//  PMProcessMonitor
//
//  Created by Alk on 3/7/19.
//  Copyright © 2019 Alk. All rights reserved.
//

#import "PMProcessUtil.h"

#include <libproc.h>

@implementation PMProcessUtil

+ (instancetype)shared
{
    static PMProcessUtil *s_sharedInstance = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_sharedInstance = [[PMProcessUtil alloc] initImpl];
    });
    
    return s_sharedInstance;
}

- (instancetype)initImpl
{
    self = [super init];
    return self;
}

- (NSArray<NSNumber *> *)collectPidsForUser:(const uid_t)user
{
    const uint32_t mode = (PMAllProcesses == user) ? PROC_ALL_PIDS : PROC_UID_ONLY;
    const int expectedNumberOfPids = proc_listpids(mode, user, NULL, 0);
    const int pidsBufferSize = sizeof(pid_t) * expectedNumberOfPids;
    
    NSMutableData *const pidsBuffer = [NSMutableData dataWithLength: pidsBufferSize];
    const int actualNumberOfPids = proc_listpids(mode, user, pidsBuffer.mutableBytes, pidsBufferSize);
    
    const pid_t* pids = (const pid_t*)pidsBuffer.bytes;
    NSMutableSet *const pidsForUser = [[NSMutableSet alloc] init];
    for (int i = 0; i < actualNumberOfPids; i++)
    {
        [pidsForUser addObject: @(pids[i])];
    }
    
    return pidsForUser.allObjects;
}

- (nullable NSNumber *)processUidForPid:(const pid_t)pid
{
    struct proc_bsdshortinfo bsdInfo = {};
    if (proc_pidinfo(pid, PROC_PIDT_SHORTBSDINFO, 0, &bsdInfo, sizeof(bsdInfo)) <= 0)
    {
        return nil;
    }
    
    return @(bsdInfo.pbsi_uid);
}

- (nullable NSString *)processNameForPid:(const pid_t)pid
{
    char name[PROC_PIDPATHINFO_MAXSIZE] = {};
    if (proc_name(pid, name, PROC_PIDPATHINFO_MAXSIZE) <= 0)
    {
        return [self processLocationForPid: pid].lastPathComponent;
    }
    
    NSString* processName = @(name);
    
    return processName.length > 0 ? processName : [self processLocationForPid: pid].lastPathComponent;
}

- (nullable NSURL *)processLocationForPid:(const pid_t)pid
{
    char path[PROC_PIDPATHINFO_MAXSIZE] = {};
    if (proc_pidpath(pid, path, PROC_PIDPATHINFO_MAXSIZE) <= 0)
    {
        return nil;
    }
    
    return [NSURL fileURLWithPath: @(path)];
}

@end
