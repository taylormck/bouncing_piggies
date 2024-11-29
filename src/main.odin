package main

import "core:fmt"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HEIGHT :: 640


BACKGROUND_COLOR :: rl.Color{47, 158, 141, 255}
// TODO: Make this adjsutable in the GUI
NUM_PIGGIES :: 1000

piggies_aligned: [dynamic]PiggyAligned

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Packed")
    defer rl.CloseWindow()


    for _ in 0 ..< NUM_PIGGIES {
        append(&piggies_aligned, piggy_aligned_create())
    }

    delta: f32

    for !rl.WindowShouldClose() {
        delta = rl.GetFrameTime()

        update(delta)
        draw()
    }
}

update :: proc(delta: f32) {
    for &piggy in piggies_aligned {
        piggy_aligned_update(&piggy, delta)
    }
}

draw :: proc() {
    rl.BeginDrawing()

    rl.ClearBackground(BACKGROUND_COLOR)

    for &piggy in piggies_aligned {
        piggy_aligned_draw(&piggy)
    }

    draw_fps()

    rl.EndDrawing()
}

draw_fps :: proc() {
    fps := fmt.caprintf("{}", rl.GetFPS())
    rl.DrawRectangle(5, 5, 80, 40, rl.WHITE)
    rl.DrawText(fps, 7, 7, 36, rl.GRAY)
}

PIGGY_MIN_SIZE :: 5
PIGGY_MAX_SIZE :: 15
PIGGY_MIN_SPEED :: 10
PIGGY_MAX_SPEED :: 25

PiggyAligned :: struct {
    position: [2]f32,
    velocity: [2]f32,
    size:     i32,
    speed:    f32,
    fluff:    bool,
}

PiggyPacked :: struct #packed {
    position: [2]f32,
    velocity: [2]f32,
    size:     i32,
    fluff:    bool,
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
    fluff := rand.float32() >= 0.5

    return {position, velocity, size, speed, fluff}
}

piggy_packed_create :: proc() {
    // TODO: implement piggy_packed_create
}

piggy_aligned_update :: proc(p: ^PiggyAligned, delta: f32) {
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

piggy_packed_update :: proc(p: ^PiggyPacked, delta: f32) {
    // TODO: implement piggy_packed_update
}

piggy_aligned_draw :: proc(p: ^PiggyAligned) {
    rl.DrawRectangle(
        i32(p.position.x),
        i32(p.position.y),
        p.size,
        p.size,
        rl.PINK,
    )
}

piggy_packed_draw :: proc(p: ^PiggyPacked) {
    // TODO: implement piggy_packed_draw
}
