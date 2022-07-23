//
//  Shaders.metal
//  Filterio
//
//  Created by Benjamin Musoke-Lubega on 7/23/22.
//

#include <metal_stdlib>
using namespace metal;

kernel void compute(texture2d<float, access::read> input [[texture(0)]],
                    texture2d<float, access::write> output [[texture(1)]],
                    uint2 id [[thread_position_in_grid]]) {
    float4 color = input.read(id);
    color = float4(color.g, color.b, color.r, 1.0);
    output.write(color, id);
}

kernel void graycale(texture2d<float, access::read> input [[texture(0)]],
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


