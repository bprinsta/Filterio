//
//  Shaders.metal
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

#include <metal_stdlib>
using namespace metal;

constant float PI = 3.1415926535897932384626433832795;

kernel void brightness(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    constant float &ratio [[buffer(10)]],
                    uint2 id [[thread_position_in_grid]]) {
    float alpha = ratio < 0.0 ? 1 + ratio : 1 - ratio;
    // blend with black when ratio < 0 to make image darker, and blend with with white when ratio > 0 to make image lighter
    float dirLuminance = ratio < 0.0 ? 0 : 1;
    
    float4 color = input.read(id);
    color = float4(alpha * color.r + (1 - alpha) * dirLuminance,
                   alpha * color.g + (1 - alpha) * dirLuminance,
                   alpha * color.b + (1 - alpha) * dirLuminance, 1.0);
    output.write(color, id);
}

// Contrast an image by interpolating between a constant gray image and the original image. 
kernel void contrast(texture2d<float, access::read> input [[texture(0)]],
                     texture2d<float, access::write> output [[texture(1)]],
                     constant float &ratio [[buffer(10)]],
                     uint2 id [[thread_position_in_grid]]) {
    float4 color = input.read(id);
    color = float4((color.r - 0.5) * tan((ratio + 1) * PI / 4) + 0.5,
                   (color.g - 0.5) * tan((ratio + 1) * PI / 4) + 0.5,
                   (color.b - 0.5) * tan((ratio + 1) * PI / 4) + 0.5, 1.0);
    output.write(color, id);
}

kernel void rgb_to_gbr(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    uint2 id [[thread_position_in_grid]]) {
    float4 color = input.read(id);
    color = float4(color.g, color.b, color.r, 1.0);
    output.write(color, id);
}

kernel void grayscale(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    uint2 id [[thread_position_in_grid]]) {
    float4 color = input.read(id);
    color.xyz = (color.r * 0.3 + color.g * 0.6 + color.b * 0.1) * 1.5;
    output.write(color, id);
}

kernel void pixelate(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    uint2 id [[thread_position_in_grid]]) {
    uint2 index = uint2((id.x / 5) * 5, (id.y / 5) * 5);
    float4 color = input.read(index);
    output.write(color, id);
}


