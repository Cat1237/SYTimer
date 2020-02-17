//
//  SYThreadSpecificVariable.h
//  SYTimer
//
//  Created by ws on 2020/2/8.
//  Copyright © 2020 ws. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nullable (^SYThreadSpecificVariableBlock)(void);


/// A `SYThreadSpecificVariable` is a variable that can be read and set like a normal variable except that it holds
/// different variables per thread.
///
/// `SYThreadSpecificVariable` is thread-safe so it can be used with multiple threads at the same time but the value
/// returned by `currentValue` is defined per thread.

@interface SYThreadSpecificVariable<T> : NSObject

/// Initialize a new `SYThreadSpecificVariable` with a current value (`currentValue == valueBlock()`).but on all other threads `currentValue` will be `nil` until changed.
///
/// - parameters:
///   - valueBlock: The value to set for the calling thread.
- (instancetype)initWithValue:(SYThreadSpecificVariableBlock)valueBlock;

/// The value for the current thread.
@property (nonatomic, strong, readonly) T currentValue;
- (BOOL)isSet;

@end


NS_ASSUME_NONNULL_END
