package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

PiggyTypes :: enum {
    Aligned,
    Packed,
}

PIGGY_MIN_SIZE :: 20
PIGGY_MAX_SIZE :: 30
PIGGY_MIN_SPEED :: 10
PIGGY_MAX_SPEED :: 25
PIGGY_SPECIAL_COLOR_RATE :: 0.01

PiggyAligned :: struct {
    position:      [2]f32,
    velocity:      [2]f32,
    size:          i32,
    speed:         f32,
    special_color: bool,
}

PiggyPacked :: struct #packed {
    position:      [2]f32,
    velocity:      [2]f32,
    size:          i32,
    speed:         f32,
    special_color: bool,
}

piggy_aligned_create :: proc() -> PiggyAligned {
    x := rand.int31_max(SCREEN_WIDTH - PIGGY_MAX_SIZE)
    y := rand.int31_max(SCREEN_HEIGHT - PIGGY_MAX_SIZE)
    position: [2]f32 = {f32(x), f32(y)}

    theta := rand.float32() * math.TAU
    velocity_x := math.cos(theta)
    velocity_y := math.sin(theta)
    speed :=
        rand.float32() * (PIGGY_MAX_SPEED - PIGGY_MIN_SPEED) + PIGGY_MIN_SPEED
    velocity: [2]f32 = {velocity_x, velocity_y} * speed

    size := rand.int31_max(PIGGY_MAX_SIZE - PIGGY_MIN_SIZE) + PIGGY_MIN_SIZE
    special_color := rand.float32() < PIGGY_SPECIAL_COLOR_RATE

    return {position, velocity, size, speed, special_color}
}

piggy_packed_create :: proc() -> PiggyPacked {
    x := rand.int31_max(SCREEN_WIDTH - PIGGY_MAX_SIZE)
    y := rand.int31_max(SCREEN_HEIGHT - PIGGY_MAX_SIZE)
    position: [2]f32 = {f32(x), f32(y)}

    theta := rand.float32() * math.TAU
    velocity_x := math.cos(theta)
    velocity_y := math.sin(theta)
    speed :=
        rand.float32() * (PIGGY_MAX_SPEED - PIGGY_MIN_SPEED) + PIGGY_MIN_SPEED
    velocity: [2]f32 = {velocity_x, velocity_y} * speed

    size := rand.int31_max(PIGGY_MAX_SIZE - PIGGY_MIN_SIZE) + PIGGY_MIN_SIZE
    special_color := rand.float32() < PIGGY_SPECIAL_COLOR_RATE

    return {position, velocity, size, speed, special_color}
}

piggy_update :: proc(p: ^$Piggy, delta: f32) {
    movement := p.velocity * delta
    p.position += movement

    if p.position.x <= 0 {
        p.velocity.x = abs(p.velocity.x)
    } else if p.position.x >= SCREEN_WIDTH - f32(p.size) {
        p.velocity.x = -abs(p.velocity.x)
    }

    if p.position.y <= 0 {
        p.velocity.y = abs(p.velocity.y)
    } else if p.position.y >= SCREEN_HEIGHT - f32(p.size) {
        p.velocity.y = -abs(p.velocity.y)
    }
}

piggy_draw :: proc(p: ^$Piggy) {
    tint := p.special_color ? rl.MAROON : rl.WHITE
    dest := rl.Rectangle{p.position.x, p.position.y, f32(p.size), f32(p.size)}

    rl.DrawTexturePro(piggy_sprite, piggy_sprite_source, dest, {0, 0}, 0, tint)
}

piggy_aligned_to_packed :: proc(p: ^PiggyAligned) -> PiggyPacked {
    return PiggyPacked {
        p.position,
        p.velocity,
        p.size,
        p.speed,
        p.special_color,
    }
}

piggy_packed_to_aligned :: proc(p: ^PiggyPacked) -> PiggyAligned {
    return PiggyAligned {
        p.position,
        p.velocity,
        p.size,
        p.speed,
        p.special_color,
    }
}
