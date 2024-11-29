package main

import "core:fmt"
import "core:math"
import rl "vendor:raylib"

SCREEN_WIDTH :: 1480
SCREEN_HEIGHT :: 960

BACKGROUND_COLOR :: rl.Color{47, 158, 141, 255}

piggy_sprite: rl.Texture2D
piggy_sprite_source :: rl.Rectangle{7, 15, 18, 17}

num_piggies: i32 = 100
active_piggy_type := PiggyTypes.Aligned

piggies_aligned: [dynamic]PiggyAligned
piggies_packed: [dynamic]PiggyPacked

should_switch_piggy_type := false

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Packed")
    defer rl.CloseWindow()

    rl.GuiLoadStyle("assets/styles/style_dark.rgs")

    piggy_sprite = rl.LoadTexture("assets/sprites/piggy/piggy_sheet.png")
    defer rl.UnloadTexture(piggy_sprite)

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
            for &p in piggies_aligned {
                append(&piggies_packed, piggy_aligned_to_packed(&p))
            }

            shrink(&piggies_aligned, 0)
            active_piggy_type = .Packed
        case .Packed:
            for &p in piggies_packed {
                append(&piggies_aligned, piggy_packed_to_aligned(&p))
            }

            shrink(&piggies_packed, 0)
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

        shrink(&piggies_aligned, num_piggies)
    case .Packed:
        for i32(len(piggies_packed)) < num_piggies {
            append(&piggies_packed, piggy_packed_create())
        }

        shrink(&piggies_packed, num_piggies)
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

    draw_gui()

    rl.EndDrawing()
}

draw_gui :: proc() {
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

    rl.GuiLabel({10, 110, 190, 20}, num_piggies_message)

    @(static) new_piggy_count: f32
    rl.GuiSlider({10, 135, 190, 20}, "", "", &new_piggy_count, 2, 6)
    num_piggies = i32(math.pow(10, new_piggy_count))
}
