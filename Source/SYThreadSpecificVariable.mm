//
//  SYThreadSpecificVariable.m
//  SYTimer
//
//  Created by ws on 2020/2/8.
//  Copyright © 2020 ws. All rights reserved.
//

#import <SYTimer/SYThreadSpecificVariable.h>
#import <pthread.h>
#import <objc/runtime.h>
@interface SYThreadSpecificData<T> : NSObject

@property (nonatomic, strong) SYThreadSpecificVariable *owner;
@property (nonatomic, strong) T storage;
- (instancetype)initWithOwner:(SYThreadSpecificVariable<T> *)owner;

@end

@interface SYThreadSpecificVariable()
{
    @package
    pthread_key_t _key;
    SYThreadSpecificVariableBlock _valueBlock;
}

@end

@implementation SYThreadSpecificVariable


- (instancetype)initWithValue:(SYThreadSpecificVariableBlock)valueBlock
{
    self = [super init];
    if (self) {
        int error = pthread_key_create(&_key, destroy);
        if (error != 0) {
            NSAssert(error == 0, @"pthread_key_delete failed, error %d", error);
        }
        
        _valueBlock = valueBlock;
    }
    return self;
}
- (void)setInTLS:(SYThreadSpecificData *)data {
    pthread_setspecific(_key, (__bridge_retained const void * _Nullable)(data));
}

/// Set the current value for the calling threads. The `currentValue` for all other threads remains unchanged.
- (id)setValue {
    NSParameterAssert(![self getValue]);
    SYThreadSpecificData *data = [[SYThreadSpecificData alloc] initWithOwner:self];
    NSParameterAssert(self.getValue == data.storage);
    return data.storage;
}
- (id)getValue {
    SYThreadSpecificData *data = (__bridge SYThreadSpecificData *)(pthread_getspecific(_key));
    if (data) {
        return data.storage;
    }
    return nil;
}

- (id)currentValue {
    id value = [self getValue];
    if (value) {
        return value;
    }
    return [self setValue];
}
- (BOOL)isSet {
    return !![self getValue];
}
static inline void destroy(void* ptr) {
    SYThreadSpecificData *data = (__bridge SYThreadSpecificData *)(ptr);
    // We want get() to keep working while data destructor works, because it can be called indirectly by the destructor.
    // Some pthreads implementations zero out the pointer before calling destroy(), so we temporarily reset it.
    pthread_setspecific(data.owner->_key, ptr);
    CFRelease(ptr);
}

@end




@implementation SYThreadSpecificData

- (instancetype)initWithOwner:(SYThreadSpecificVariable *)owner
{
    self = [super init];
    if (self) {
        _owner = owner;
        // Set up thread-specific value's memory pointer before invoking constructor, in case any function it calls
        // needs to access the value, to avoid recursion.
        [_owner setInTLS: self];
        _storage = _owner->_valueBlock();
    }
    return self;
}


- (void)dealloc {
    _storage = nil;
    [_owner setInTLS:nil];
}
@end
