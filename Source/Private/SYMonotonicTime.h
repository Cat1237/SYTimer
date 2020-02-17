//
//  SYMonotonicTime.h
//  SYTimer
//
//  Created by ws on 2019/1/8.
//  Copyright © 2019 ws. All rights reserved.
//

#pragma once

#import <SYTimer/SYClockType.h>
#import <SYTimer/SYSeconds.h>

namespace SY {
    
    class WallTime;
    
    // The current time according to a monotonic clock. Monotonic clocks don't go backwards and
    // possibly don't count downtime. This uses floating point internally so that you can reason about
    // infinity and other things that arise in math. It's acceptable to use this to wrap NaN times,
    // negative times, and infinite times, so long as they are all relative to the same clock.
    class MonotonicTime {
    public:
        static const ClockType clockType = ClockType::Monotonic;
        
        // This is the epoch. So, x.secondsSinceEpoch() should be the same as x - MonotonicTime().
        constexpr MonotonicTime() { }
        
        // Call this if you know for sure that the double represents monotonic time according to the
        // same time source as MonotonicTime. It must be in seconds.
        static constexpr MonotonicTime fromRawSeconds(double value)
        {
            return MonotonicTime(value);
        }
        
        __attribute__((visibility("default"))) static MonotonicTime now();
        
        static constexpr MonotonicTime infinity() { return fromRawSeconds(std::numeric_limits<double>::infinity()); }
        static constexpr MonotonicTime nan() { return fromRawSeconds(std::numeric_limits<double>::quiet_NaN()); }
        
        constexpr Seconds secondsSinceEpoch() const { return Seconds(_value); }
        
        MonotonicTime approximateMonotonicTime() const { return *this; }
        __attribute__((visibility("default"))) WallTime approximateWallTime() const;
        
        explicit constexpr operator bool() const { return !!_value; }
        
        constexpr MonotonicTime operator+(Seconds other) const
        {
            return fromRawSeconds(_value + other.value());
        }
        
        constexpr MonotonicTime operator-(Seconds other) const
        {
            return fromRawSeconds(_value - other.value());
        }
        
        Seconds operator%(Seconds other) const
        {
            return Seconds { fmod(_value, other.value()) };
        }
        
        // Time is a scalar and scalars can be negated as this could arise from algebraic
        // transformations. So, we allow it.
        constexpr MonotonicTime operator-() const
        {
            return fromRawSeconds(-_value);
        }
        
        MonotonicTime operator+=(Seconds other)
        {
            return *this = *this + other;
        }
        
        MonotonicTime operator-=(Seconds other)
        {
            return *this = *this - other;
        }
        
        constexpr Seconds operator-(MonotonicTime other) const
        {
            return Seconds(_value - other._value);
        }
        
        constexpr bool operator==(MonotonicTime other) const
        {
            return _value == other._value;
        }
        
        constexpr bool operator!=(MonotonicTime other) const
        {
            return _value != other._value;
        }
        
        constexpr bool operator<(MonotonicTime other) const
        {
            return _value < other._value;
        }
        
        constexpr bool operator>(MonotonicTime other) const
        {
            return _value > other._value;
        }
        
        constexpr bool operator<=(MonotonicTime other) const
        {
            return _value <= other._value;
        }
        
        constexpr bool operator>=(MonotonicTime other) const
        {
            return _value >= other._value;
        }
        
        MonotonicTime isolatedCopy() const
        {
            return *this;
        }
        
        template<class Encoder>
        void encode(Encoder& encoder) const
        {
            encoder << _value;
        }
        
        template<class Decoder>
        static bool decode(Decoder& decoder, MonotonicTime& time)
        {
            double value;
            if (!decoder.decode(value))
                return false;
            
            time = MonotonicTime::fromRawSeconds(value);
            return true;
        }
        
        struct MarkableTraits;
        
private:
    constexpr MonotonicTime(double rawValue)
    : _value(rawValue)
    {
    }
    
    double _value { 0 };
        
};
    
struct MonotonicTime::MarkableTraits {
    static bool isEmptyValue(MonotonicTime time)
    {
        return std::isnan(time._value);
    }
    
    static constexpr MonotonicTime emptyValue()
    {
        return MonotonicTime::nan();
    }
};
    
} // namespace SY

namespace std {
    
    inline bool isnan(SY::MonotonicTime time)
    {
        return std::isnan(time.secondsSinceEpoch().value());
    }
    
    inline bool isinf(SY::MonotonicTime time)
    {
        return std::isinf(time.secondsSinceEpoch().value());
    }
    
    inline bool isfinite(SY::MonotonicTime time)
    {
        return std::isfinite(time.secondsSinceEpoch().value());
    }
    
} // namespace std

using SY::MonotonicTime;

