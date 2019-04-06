//
//  PMProcessMonitor.m
//  PMProcessMonitor
//
//  Created by Alk on 3/7/19.
//  Copyright © 2019 Alk. All rights reserved.
//

#import "PMProcessMonitor.h"

#import "PMProcessUtil.h"

@interface PMProcess ()

@property (readwrite, nonatomic) pid_t pid;
@property (readwrite, nonatomic) uid_t uid;
@property (copy, readwrite, nonatomic) NSString *name;
@property (copy, readwrite, nonatomic) NSURL *location;

+ (instancetype)processWithPid:(const pid_t)pid processUtil:(PMProcessUtil *const)processUtil;

@end


@interface PMProcessMonitor ()

@property (strong, readwrite, atomic) NSArray<PMProcess *> *processes;

@property (nonatomic) uid_t userId;
@property (strong, nonatomic) dispatch_source_t timer;

@end

@implementation PMProcessMonitor

+ (instancetype)defaultMonitor
{
    static PMProcessMonitor * s_defaultMonitor = nil;
    static dispatch_once_t s_onceToken;
    dispatch_once(&s_onceToken, ^{
        s_defaultMonitor = [[PMProcessMonitor alloc] initWithRefreshFrequency: PMDefaultRefreshFrequency];
    });
    
    return s_defaultMonitor;
}

- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency
{
    return [self initWithRefreshFrequency: refreshFrequency forUser: PMAllProcesses];
}

- (instancetype)initWithRefreshFrequency:(const NSTimeInterval)refreshFrequency forUser:(const uid_t)user
{
    self = [super init];
    if (self)
    {
        _processes = @[];
        _userId = user;
        
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        
        __weak __typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{
            [weakSelf updateProcessList];
        });
        
        dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(refreshFrequency * NSEC_PER_SEC)), 0);
        dispatch_resume(_timer);
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_source_cancel(self.timer);
}

- (NSArray<PMProcess *> *)allProcesses
{
    // If process list has not been updated yet
    if (!self.processes.count)
    {
        [self updateProcessList];
    }
    
    return self.processes;
}

- (void)updateProcessList
{
    PMProcessUtil *const processUtil = PMProcessUtil.shared;
    
    NSMutableArray<PMProcess *> *const processes = [NSMutableArray array];
    for (NSNumber *const pidNumber in [processUtil collectPidsForUser: self.userId])
    {
        PMProcess *const process = [PMProcess processWithPid: pidNumber.intValue processUtil: processUtil];
        if (process)
        {
            [processes addObject: process];
        }
    }
    
    self.processes = processes;
}

@end

@implementation PMProcess

+ (instancetype)processWithPid:(const pid_t)pid
{
    return [PMProcess processWithPid: pid processUtil: PMProcessUtil.shared];
}

+ (instancetype)processWithPid:(const pid_t)pid processUtil:(PMProcessUtil *const)processUtil
{
    NSNumber *const uid = [processUtil processUidForPid: pid];
    if (!uid)
    {
        return nil;
    }
    
    NSString *const name = [processUtil processNameForPid: pid];
    if (!name)
    {
        return nil;
    }
    
    NSURL *const location = [processUtil processLocationForPid: pid];
    if (!location)
    {
        return nil;
    }
    
    PMProcess *const process = [[PMProcess alloc] init];
    process.pid = pid;
    process.uid = uid.intValue;
    process.name = name;
    process.location = location;
    
    return process;
}

@end
