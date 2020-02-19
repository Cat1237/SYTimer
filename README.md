
SYTimer
==============

[![License MIT](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/wangson1237/SYTimer/master/LICENSE)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/v/SYTimer.svg?style=flat)](http://cocoapods.org/pods/SYTimer)&nbsp;
[![CocoaPods](http://img.shields.io/cocoapods/p/SYTimer.svg?style=flat)](http://cocoadocs.org/docsets/SYTimer)&nbsp;
[![Support](https://img.shields.io/badge/support-iOS10+-blue.svg?style=flat)](https://www.apple.com/nl/ios/)&nbsp;
[![Build Status](https://github.com/wangson1237/SYTimer/workflows/build/badge.svg?branch=master)](https://github.com/wangson1237/SYTimer/actions?query=workflow%3Abuild)

SYTimer is a High performance library for timing. It provides you a chance to use it main runLoop or other runLoop in your next app.

Base on CFRunLoop Timer for iOS.

## Features

- [x] All runLoop and runLoopMode Support.
- [x] It's only created two runLoop timer when in main runLoop.
- [x] It's based on priority queue wehn in main runLoop 
- [x] ThreadSpecificVariable.
- [x] Heap and HeapItem.


### SYTimer

The simplest use-case to setting an timer in main runLoop:

```oc
_timer = [SYTimer mainRunLoopTimerWithRunLoopMode:kCFRunLoopCommonModes block:^(SYTimer * _Nonnull) {
    // do 
}];
[_timer startRepeating:.5];
```

SYTimer will puted ther timer into the runLoopCommonModes heap and set runLoop timer next fire date.

other runLoop:

```oc
_otherRunLoopTimer = [[SYTimer alloc] initWithRunLoop:[SYRunLoop current] runLoopMode:kCFRunLoopCommonModes block:^(SYTimer * timer) {
    // do
}];
[_otherRunLoopTimer startRepeating:.5];

```

Just created runLoop timer and added to current runLoop.

### SYHeap

See SYHeap code. It's contained min-heap and max-heap, INCREASE-KEY, DECREASE-KEY.  It's used just like NSArray.

### SYThreadSpecificVariable

A `SYThreadSpecificVariable` is a variable that can be read and set like a normal variable except that it holds different variables per thread.

### SYHeapItem

An object which it's packaged as SYHeapItem and store it in a heap which it's SYHeap.

Installation
==============

### CocoaPods

1. Add `pod 'SYTimer'` to your Podfile.
2. Run `pod install` or `pod update`.
3. Import \<SYTimer/SYTimer.h\>.

Requirements
==============
This library requires `iOS 10.0+` and `Xcode 11.0+`.

License
==============
SYTimer is provided under the MIT license. See LICENSE file for details.
