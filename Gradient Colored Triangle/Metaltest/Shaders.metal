//
//  Shaders.metal
//  Metaltest
//
//  Created by Mac mini on 11/1/21.
//

#include <metal_stdlib>
using namespace metal;

struct vertexIn
{
    float3 position;
    float4 color;
};

struct RasterizerData
{
    float4 position [[ position ]];
    float4 color;
};


vertex RasterizerData basic_vertex_shader( const device vertexIn *vertexData [[ buffer(0) ]], const unsigned int vertexID [[ vertex_id ]] )
{
    
    RasterizerData rd;
    rd.position = float4( vertexData[ vertexID ].position , 1 );
    rd.color = vertexData [ vertexID ].color;
    return rd;
}

fragment half4 basic_fragment_shader( RasterizerData rd [[ stage_in ]] )
{
    float4 color = rd.color;
    return half4( color.r, color.g, color.b, color.a );
}
