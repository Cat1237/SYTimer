//
//  SYWallTime.h
//  SYTimer
//
//  Created by ws on 2019/1/8.
//  Copyright © 2019 ws. All rights reserved.
//

#pragma once

#import <SYTimer/SYClockType.h>
#import <SYTimer/SYSeconds.h>

namespace SY {
    class MonotonicTime;

    // The current time according to a wall clock (aka real time clock). This uses floating point
    // internally so that you can reason about infinity and other things that arise in math. It's
    // acceptable to use this to wrap NaN times, negative times, and infinite times, so long as they
    // are relative to the same clock. Use this only if wall clock time is needed. For elapsed time
    // measurement use MonotonicTime instead.
    class WallTime {
    public:
        static const ClockType clockType = ClockType::Wall;
        
        // This is the epoch. So, x.secondsSinceEpoch() should be the same as x - WallTime().
        constexpr WallTime() { }
        
        // Call this if you know for sure that the double represents time according to
        // SY::currentTime(). It must be in seconds and it must be from the same time source.
        static constexpr WallTime fromRawSeconds(double value)
        {
            return WallTime(value);
        }
        
        __attribute__((visibility("default"))) static WallTime now();
        
        static constexpr WallTime infinity() { return fromRawSeconds(std::numeric_limits<double>::infinity()); }
        static constexpr WallTime nan() { return fromRawSeconds(std::numeric_limits<double>::quiet_NaN()); }
        
        constexpr Seconds secondsSinceEpoch() const { return Seconds(_value); }
        
        WallTime approximateWallTime() const { return *this; }
        __attribute__((visibility("default"))) MonotonicTime approximateMonotonicTime() const;
        
        explicit constexpr operator bool() const { return !!_value; }
        
        constexpr WallTime operator+(Seconds other) const
        {
            return fromRawSeconds(_value + other.value());
        }
        
        constexpr WallTime operator-(Seconds other) const
        {
            return fromRawSeconds(_value - other.value());
        }
        
        // Time is a scalar and scalars can be negated as this could arise from algebraic
        // transformations. So, we allow it.
        constexpr WallTime operator-() const
        {
            return fromRawSeconds(-_value);
        }
        
        WallTime& operator+=(Seconds other)
        {
            return *this = *this + other;
        }
        
        WallTime& operator-=(Seconds other)
        {
            return *this = *this - other;
        }
        
        constexpr Seconds operator-(WallTime other) const
        {
            return Seconds(_value - other._value);
        }
        
        constexpr bool operator==(WallTime other) const
        {
            return _value == other._value;
        }
        
        constexpr bool operator!=(WallTime other) const
        {
            return _value != other._value;
        }
        
        constexpr bool operator<(WallTime other) const
        {
            return _value < other._value;
        }
        
        constexpr bool operator>(WallTime other) const
        {
            return _value > other._value;
        }
        
        constexpr bool operator<=(WallTime other) const
        {
            return _value <= other._value;
        }
        
        constexpr bool operator>=(WallTime other) const
        {
            return _value >= other._value;
        }
        
        
        WallTime isolatedCopy() const
        {
            return *this;
        }
        
        struct MarkableTraits;
        
    private:
        constexpr WallTime(double rawValue)
        : _value(rawValue)
        {
        }
        
        double _value { 0 };
    };
    
    struct WallTime::MarkableTraits {
        static bool isEmptyValue(WallTime time)
        {
            return std::isnan(time._value);
        }
        
        static constexpr WallTime emptyValue()
        {
            return WallTime::nan();
        }
    };
    
    __attribute__((visibility("default"))) void sleep(WallTime);
    
} // namespace SY

namespace std {
    
    inline bool isnan(SY::WallTime time)
    {
        return std::isnan(time.secondsSinceEpoch().value());
    }
    
    inline bool isinf(SY::WallTime time)
    {
        return std::isinf(time.secondsSinceEpoch().value());
    }
    
    inline bool isfinite(SY::WallTime time)
    {
        return std::isfinite(time.secondsSinceEpoch().value());
    }
    
} // namespace std

using SY::WallTime;

