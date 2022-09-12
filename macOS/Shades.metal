#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
    float2 texCoords [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[position]];
    float3 worldPosition;
    float3 viewPosition;
    float3 normal;
    float2 texCoords;
};

struct Node {
    float4x4 view;
};

struct Frame {
    float4x4 projection;
    float4x4 view;
};

vertex VertexOut vertex_main(const VertexIn in [[ stage_in ]],
                             constant Node *nodes [[ buffer(1) ]],
                             constant Frame &frame [[ buffer(2) ]],
                             uint id [[ instance_id ]]) {
    constant Node &node = nodes[id];
    float4x4 model = frame.view * node.view;
    float4 world = node.view * float4(in.position, 1.0);
    float4 position = frame.view * world;
    float4 normal = model * float4(in.normal, 0.0);
    
    VertexOut out;
    out.position = frame.projection * position;
    out.worldPosition = world.xyz;
    out.viewPosition = position.xyz;
    out.normal = normal.xyz;
    out.texCoords = in.texCoords;
    return out;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//
//    float4 view = node.view * float4(in.position, 1);
//    float4 normal = node.view * float4(in.normal, 0);
//
//    VertexOut out;
//    out.position = frame.projection * view;
////    out.position = view;
//
////    vertex_out.position = float4(vertex_in.position, 1);
////    vertex_out.color = float4(vertex_in.texture, 1, 1);
//    out.normal = normal.xyz;
//    out.view = view.xyz;
//    out.texCoords = in.texCoords;
////    vertex_out.position.y += timer;
////    vertex_out.timer = timer;
////    vertexOut.pointSize = 4;
////    vertexOut.color = float4(1, 1, 1, 1);
//    return out;
    
    
    
    
    
    
    
    
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]],
                              constant Frame &frame [[ buffer(0) ]],
                              texture2d<float, access::sample> textureMap [[ texture(0) ]],
                              sampler textureSampler [[ sampler(0) ]]) {

    
    float4 baseColor = textureMap.sample(textureSampler, in.texCoords);
        float specularExponent = 50.0;

        float3 N = normalize(in.normal);
        float3 V = normalize(float3(0) - in.viewPosition);

        float3 litColor { 0 };

        for (uint i = 0; i < 2; ++i) {
            float ambientFactor = 0;
            float diffuseFactor = 0;
            float specularFactor = 0;
            float3 intensity = float3(1, 1, 1);

            switch(i) {
                case 0: {
                    ambientFactor = 1;
                    break;
                }
                case 1: {
                    intensity *= 0.35;
                    float3 direction = normalize(float3(0, 0, 1));
                    float3 L = normalize(-direction);
                    float3 H = normalize(L + V);
                    diffuseFactor = saturate(dot(N, L));
                    specularFactor = powr(saturate(dot(N, H)), specularExponent);
                    break;
                }
            }

            litColor += (ambientFactor + diffuseFactor + specularFactor) * intensity * baseColor.rgb;
        }

        return float4(litColor * baseColor.a, baseColor.a);
}
