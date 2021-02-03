//
//  ImageFilter.metal
//  Invert Color filter with Metal
//
//  Created by Mac mini on 31/1/21.
//

#include <metal_stdlib>
using namespace metal;

// Function to Invert colors.
half4 invertColor(half4 color)
{
    return half4((1.0 - color.rgb), color.a);
}

//First perameter inTexture is a read only texture. OutTexture is for new image. gif stores the poitions of texture.
kernel void drawWithInvertedColor(texture2d<half, access::read> inTexture [[ texture (0) ]], texture2d<half, access::read_write> outTexture [[ texture (1) ]], uint2 gid [[ thread_position_in_grid ]])
{
    half4 color = inTexture.read(gid).rgba;
    half4 invertedColor = invertColor(color);
    outTexture.write(invertedColor, gid);
}
