#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[ attribute(0) ]];
    float3 normal [[ attribute(1) ]];
    float2 texCoords [[ attribute(2) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 normal;
    float2 texCoords;
    
    float3 view;
    
    
    float4 color;
    float timer;
    float point_size [[ point_size ]];
};

struct Node {
    float4x4 view;
};

struct Frame {
    float4x4 projection;
};

vertex VertexOut vertex_main(const VertexIn in [[ stage_in ]],
                             constant Node &node [[ buffer(1) ]],
                             constant Frame &frame [[ buffer(2) ]]) {
    float4 view = node.view * float4(in.position, 1);
    float4 normal = node.view * float4(in.normal, 0);
    
    VertexOut out;
    out.position = frame.projection * view;
//    vertex_out.position = float4(vertex_in.position, 1);
//    vertex_out.color = float4(vertex_in.texture, 1, 1);
    out.normal = normal.xyz;
    out.view = view.xyz;
    out.texCoords = in.texCoords;
//    vertex_out.position.y += timer;
//    vertex_out.timer = timer;
//    vertexOut.pointSize = 4;
//    vertexOut.color = float4(1, 1, 1, 1);
    return out;
}

fragment float4 fragment_main(VertexOut in [[ stage_in ]],
                              constant Frame &frame [[ buffer(0) ]],
                              texture2d<float, access::sample> textureMap [[ texture(0) ]],
                              sampler textureSampler [[ sampler(0) ]]) {
//    float3 L = normalize(float3(0.2, -0.5, 0));
//    float3 N = normalize(in.normal);
//    float NdotL = saturate(dot(N, L));
//    return float4(float3(NdotL), 1);
//    return textureMap.sample(textureSampler, in.texCoords);
    
    
    
    
    float4 baseColor = textureMap.sample(textureSampler, in.texCoords);
        float specularExponent = 50.0;

        float3 N = normalize(in.normal);
        float3 V = normalize(float3(0) - in.view);

        float3 litColor { 0 };

        for (uint i = 0; i < 2; ++i) {
            float ambientFactor = 0;
            float diffuseFactor = 0;
            float specularFactor = 0;
            float3 intensity = float3(0.2, 0.2, 0.2);

            switch(i) {
                case 0: {
                    ambientFactor = 1;
                    intensity = 0.85 * float3(1, 1, 1);
                    break;
                }
                case 1: {
                    ambientFactor = 0.3;
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
