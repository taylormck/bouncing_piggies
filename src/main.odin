package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1480
SCREEN_HEIGHT :: 960

BACKGROUND_COLOR :: rl.Color{47, 158, 141, 255}

num_piggies: i32 = 1000000
active_piggy_type := PiggyTypes.Packed

piggies_aligned: [dynamic]PiggyAligned
piggies_packed: [dynamic]PiggyPacked

should_switch_piggy_type := false

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Packed")
    defer rl.CloseWindow()

    rl.GuiLoadStyle("assets/styles/style_dark.rgs")

    for _ in 0 ..< num_piggies {
        append(&piggies_aligned, piggy_aligned_create())
        append(&piggies_packed, piggy_packed_create())
    }

    delta: f32

    for !rl.WindowShouldClose() {
        delta = rl.GetFrameTime()

        update(delta)
        draw()
    }
}

update :: proc(delta: f32) {
    if should_switch_piggy_type {
        switch (active_piggy_type) {
        case .Aligned:
            clear(&piggies_aligned)
            active_piggy_type = .Packed
        case .Packed:
            clear(&piggies_packed)
            active_piggy_type = .Aligned
        }
    }

    update_piggy_count()

    switch (active_piggy_type) {
    case .Aligned:
        for &piggy in piggies_aligned {
            piggy_update(&piggy, delta)
        }
    case .Packed:
        for &piggy in piggies_packed {
            piggy_update(&piggy, delta)
        }
    }
}

update_piggy_count :: proc() {
    switch (active_piggy_type) {
    case .Aligned:
        for i32(len(piggies_aligned)) < num_piggies {
            append(&piggies_aligned, piggy_aligned_create())
        }

        if i32(len(piggies_aligned)) > num_piggies {
            shrink(&piggies_aligned, num_piggies)
        }
    case .Packed:
        for i32(len(piggies_packed)) < num_piggies {
            append(&piggies_packed, piggy_packed_create())
        }

        if i32(len(piggies_packed)) > num_piggies {
            shrink(&piggies_packed, num_piggies)
        }
    }
}

draw :: proc() {
    rl.BeginDrawing()
    rl.ClearBackground(BACKGROUND_COLOR)

    switch (active_piggy_type) {
    case .Aligned:
        for &piggy in piggies_aligned {
            piggy_draw(&piggy)
        }
    case .Packed:
        for &piggy in piggies_packed {
            piggy_draw(&piggy)
        }
    }

    draw_fps()

    rl.EndDrawing()
}

draw_fps :: proc() {
    fps := fmt.caprintf("FPS: {}", rl.GetFPS())
    current_piggy_type: string = "unknown"
    switch (active_piggy_type) {
    case .Aligned:
        current_piggy_type = "Aligned"
    case .Packed:
        current_piggy_type = "Packed"
    }
    piggy_message := fmt.caprintf("Piggy Type: {}", current_piggy_type)
    num_piggies_message := fmt.caprintf("Number of piggies: {}", num_piggies)

    rl.GuiPanel({5, 5, 200, 160}, "#191# Stats")
    rl.GuiLabel({10, 25, 190, 20}, fps)
    rl.GuiLabel({10, 45, 190, 20}, piggy_message)

    should_switch_piggy_type = rl.GuiButton(
        {10, 70, 190, 25},
        "Switch Piggy Type",
    )

    rl.GuiLabel({10, 100, 190, 20}, num_piggies_message)

    @(static) new_piggy_count: f32
    rl.GuiSlider({10, 125, 190, 20}, "", "", &new_piggy_count, 2, 6)
    num_piggies = i32(math.pow10(new_piggy_count))
}

PiggyTypes :: enum {
    Aligned,
    Packed,
}

PIGGY_MIN_SIZE :: 1
PIGGY_MAX_SIZE :: 5
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
    x := rand.int31_max(SCREEN_WIDTH - 2 * PIGGY_MAX_SIZE) + PIGGY_MAX_SIZE
    y := rand.int31_max(SCREEN_HEIGHT - 2 * PIGGY_MAX_SIZE) + PIGGY_MAX_SIZE
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
    x := rand.int31_max(SCREEN_WIDTH - 2 * PIGGY_MAX_SIZE) + PIGGY_MAX_SIZE
    y := rand.int31_max(SCREEN_HEIGHT - 2 * PIGGY_MAX_SIZE) + PIGGY_MAX_SIZE
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
    color := p.special_color ? rl.MAROON : rl.PINK

    rl.DrawRectangle(
        i32(p.position.x),
        i32(p.position.y),
        p.size,
        p.size,
        color,
    )
}
