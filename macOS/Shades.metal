#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
    float4 color [[ attribute(1) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float timer;
    float point_size [[ point_size ]];
};

struct Uniforms {
    float4x4 matrix;
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant float &timer [[ buffer(1) ]],
                             const device Uniforms &uniforms [[ buffer(2) ]]) {
    VertexOut vertex_out;
    vertex_out.position = uniforms.matrix * vertex_in.position;
    vertex_out.color = vertex_in.color;
//    vertex_out.position.y += timer;
//    vertex_out.timer = timer;
//    vertexOut.pointSize = 4;
//    vertexOut.color = float4(1, 1, 1, 1);
    uniforms.matrix;
    return vertex_out;
}

fragment half4 fragment_main(VertexOut vertex_out [[ stage_in ]]) {
//    float multiplier = 1 - (vertex_out.position.y / 3250);
//    return half4(multiplier * 0.9,
//                  multiplier * 0.95,
//                  multiplier * 1,
//                  1);
    return half4(vertex_out.color[0], vertex_out.color[1], vertex_out.color[2], vertex_out.color[3]);
}
