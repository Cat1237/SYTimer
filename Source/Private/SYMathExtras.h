//
//  SYMathExtras.h
//  SYTimer
//
//  Created by ws on 2019/1/11.
//  Copyright © 2019 ws. All rights reserved.
//

#pragma once

#import <cmath>

namespace SY {
    // std::numeric_limits<T>::min() returns the smallest positive value for floating point types
    template<typename T> constexpr inline T defaultMinimumForClamp() { return std::numeric_limits<T>::min(); }
    template<> constexpr inline float defaultMinimumForClamp() { return -std::numeric_limits<float>::max(); }
    template<> constexpr inline double defaultMinimumForClamp() { return -std::numeric_limits<double>::max(); }
    template<typename T> constexpr inline T defaultMaximumForClamp() { return std::numeric_limits<T>::max(); }
    
    template<typename T> inline T clampTo(double value, T min = defaultMinimumForClamp<T>(), T max = defaultMaximumForClamp<T>())
    {
        if (value >= static_cast<double>(max))
            return max;
        if (value <= static_cast<double>(min))
            return min;
        return static_cast<T>(value);
    }
    template<> inline long long int clampTo(double, long long int, long long int); // clampTo does not support long long ints.
    
    inline int clampToInteger(double value)
    {
        return clampTo<int>(value);
    }
    // Explicitly accept 64bit result when clamping double value.
    // Keep in mind that double can only represent 53bit integer precisely.
    template<typename T> constexpr inline T clampToAccepting64(double value, T min = defaultMinimumForClamp<T>(), T max = defaultMaximumForClamp<T>())
    {
        return (value >= static_cast<double>(max)) ? max : ((value <= static_cast<double>(min)) ? min : static_cast<T>(value));
    }
    
    template <typename T>
    inline typename std::enable_if<std::is_floating_point<T>::value, T>::type safeFPDivision(T u, T v)
    {
        // Protect against overflow / underflow.
        if (v < 1 && u > v * std::numeric_limits<T>::max())
            return std::numeric_limits<T>::max();
        if (v > 1 && u < v * std::numeric_limits<T>::min())
            return 0;
        return u / v;
    }
    
    // Floating point numbers comparison:
    // u is "essentially equal" [1][2] to v if: | u - v | / |u| <= e and | u - v | / |v| <= e
    //
    // [1] Knuth, D. E. "Accuracy of Floating Point Arithmetic." The Art of Computer Programming. 3rd ed. Vol. 2.
    //     Boston: Addison-Wesley, 1998. 229-45.
    // [2] http://www.boost.org/doc/libs/1_34_0/libs/test/doc/components/test_tools/floating_point_comparison.html
    template <typename T>
    inline typename std::enable_if<std::is_floating_point<T>::value, bool>::type areEssentiallyEqual(T u, T v, T epsilon = std::numeric_limits<T>::epsilon())
    {
        if (u == v)
            return true;
        
        const T delta = std::abs(u - v);
        return safeFPDivision(delta, std::abs(u)) <= epsilon && safeFPDivision(delta, std::abs(v)) <= epsilon;
    }
    inline bool isWithinIntRange(float x)
    {
        return x > static_cast<float>(std::numeric_limits<int>::min()) && x < static_cast<float>(std::numeric_limits<int>::max());
    }
}


