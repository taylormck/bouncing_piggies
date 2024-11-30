package main

import "core:time"

ROLLING_AVERGAE_TIMER_MAX_LEN :: 1000

RollingAverageTimer :: struct {
    times: [ROLLING_AVERGAE_TIMER_MAX_LEN]f64,
    start: int,
    end:   int,
}

rolling_average_timer_create :: proc() -> RollingAverageTimer {
    return RollingAverageTimer{end = 1}
}

rolling_average_timer_len :: proc(t: ^RollingAverageTimer) -> int {
    if t.end >= t.start {
        return t.end - t.start
    } else {
        return t.end + ROLLING_AVERGAE_TIMER_MAX_LEN - t.start
    }
}

rolling_average_timer_get_average_time :: proc(
    t: ^RollingAverageTimer,
) -> f64 {
    num_entries := rolling_average_timer_len(t)

    sum: f64 = 0
    for i := 0; i != num_entries; {
        sum += t.times[i]
        increment_index(&i)
    }

    return sum / f64(num_entries)
}

rolling_average_timer_append :: proc(t: ^RollingAverageTimer, time: f64) {
    t.times[t.end] = time

    increment_index(&t.end)

    if rolling_average_timer_len(t) > ROLLING_AVERGAE_TIMER_MAX_LEN {
        increment_index(&t.start)
    }
}

increment_index :: proc(i: ^int) {
    i^ += 1
    if i^ == ROLLING_AVERGAE_TIMER_MAX_LEN {
        i^ = 0
    }
}
