#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
    
    
    
    float4 color;
    float timer;
    float point_size [[ point_size ]];
};

struct Constants {
    float4x4 matrix;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant Constants &constants [[ buffer(1) ]]) {
    VertexOut vertex_out;
    vertex_out.position = constants.matrix * float4(vertex_in.position, 1);
//    vertex_out.position = float4(vertex_in.position, 1);
//    vertex_out.color = float4(vertex_in.texture, 1, 1);
    vertex_out.normal = vertex_in.normal;
//    vertex_out.position.y += timer;
//    vertex_out.timer = timer;
//    vertexOut.pointSize = 4;
//    vertexOut.color = float4(1, 1, 1, 1);
    return vertex_out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]]) {
    float3 L = normalize(float3(0.2, -0.5, 0));
    float3 N = normalize(in.normal);
    float NdotL = saturate(dot(N, L));
    return float4(float3(NdotL), 1);
}
