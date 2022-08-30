#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float point_size [[ point_size ]];
};

vertex VertexOut vertex_main(const VertexIn vertex_in [[ stage_in ]],
                             constant float &timer [[ buffer(1) ]]) {
    VertexOut vertex_out;
    vertex_out.position = vertex_in.position;
    vertex_out.position.y += timer;
//    vertexOut.pointSize = 4;
//    vertexOut.color = float4(1, 1, 1, 1);
    return vertex_out;
}

fragment float4 fragment_main(VertexOut vertex_out [[ stage_in ]]) {
    float multiplier = 1 - (vertex_out.position.y / 3250);
    return float4(multiplier * 0.9,
                  multiplier * 0.95,
                  multiplier * 1,
                  1);
}
