#language slang 2026

// Copyright (C) 2026 Nicolas Mattia <nicolas at nmattia.com>
// Copied from https://gist.github.com/nmattia/977d36df157a4c4319a39ff90d8aa5c0
//
// Bend the top part of the terminal to display around the notch. Only meaningful in full screen.
//
// Inspired by Kitty's `crt` shader. Requires kitty 49.3.

import kitty_custom_shader_types;

// notch width & height, as a proportion of total display.
// Only works correctly when fullscreen and might only be correct for my machine.
static const float NOTCH_WIDTH = 0.121412;
static const float NOTCH_HEIGHT = 0.03373;

// Bend the screen to create a smooth gap around the notch.
// Anything outside of uv's [0, 1] range is rendered as black by kitty, which
// is what we want.
float2
bend(float2 uv) {
    float dx = abs(.5 - uv.x); // X-dist from the midline
    // calculate the "sag" curve, where .5 is "half a window's width" calculated from the midline (stretches the
    // sag to both ends).
    float sag = (1. - smoothstep(NOTCH_WIDTH/2., .5, dx)) * NOTCH_HEIGHT;
    uv.y /= 1. - sag; // scale vertically based on sag
    return uv;
}

// Make clicks land on the text that is shown under the pointer
// NOTE: this does not take the animation into account (we assume the animation
// is short enough to be negligible).
public float2
pointer_map(float2 pos, KittyCustomShaderData d) {
    return bend(pos);
}

public float4
fragment_main(float4 color, KittyTextures t, KittyCustomShaderData d) {
    // Lerp over animation_progress so that the bend is progressive when the
    // animation is toggled on/off.
    return t.backbuffer.Sample(lerp(t.pos, bend(t.pos), t.animation_progress));
}
