//
//  Shader.metal
//  DiVPN
//
//  Created by Diesperov Konstantin on 13.01.2026.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
    float2 position;
    float2 uv;
};

struct VertexOut{
    float4 position [[position]];
    float2 uv;
};

struct Uniforms {
    float time;
    float connected;
    float loading;
    float scroll;
    float4 activeColor;
    float4 defaultColor;
};

vertex VertexOut vertex_main(const device VertexIn* vertices [[buffer(0)]], uint id [[vertex_id]]){
    VertexOut out;
    out.position = float4(vertices[id].position, 0, 1);
    out.uv = vertices[id].uv;
    return out;
}

fragment float4 fragment_main(VertexOut in [[stage_in]], texture2d<float> tex [[texture(0)]],
                              texture2d<float> mask [[texture(1)]], sampler samp [[sampler(0)]],
                              constant Uniforms& u [[buffer(0)]]) {
    in.uv.y *= 1.2;
    
    float2 colUV = in.uv;
    colUV.y += u.scroll;
    
    float4 col = tex.sample(samp, colUV);
    col.rgb = mix(u.defaultColor.rgb, u.activeColor.rgb, u.connected);
    
    float2 maskUV = in.uv;
    maskUV.y -= 0.1 * (1 - u.connected);
    float4 msk = mask.sample(samp, saturate(maskUV));
    float maskValue = clamp(msk.r * 1.2 * clamp(u.connected, 0.5, 1.0), 0.0, 1.0);
    col.a *= maskValue;
    return col;
}
