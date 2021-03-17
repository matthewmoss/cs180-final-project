//
//  PhongShader.metal
//  cs180-final-project
//
//  Created by Matt Moss on 3/16/21.
//

#include <metal_stdlib>
using namespace metal;
#include <SceneKit/scn_metal>

// https://developer.apple.com/documentation/scenekit/scnprogram
// https://www.raywenderlich.com/714-metal-tutorial-with-swift-3-part-4-lighting

struct SceneBuffer {
    float4x4    viewTransform;
    float4x4    inverseViewTransform; // view space to world space
    float4x4    projectionTransform;
    float4x4    viewProjectionTransform;
};

struct NodeBuffer {
    float4x4 modelTransform;
    float4x4 inverseModelTransform;
    float4x4 modelViewProjectionTransform;
    float4x4 modelViewTransform;
    float4x4 normalTransform;
    float2x3 boundingBox;
};

struct FragmentShaderInput {
    float3 position  [[attribute(SCNVertexSemanticPosition)]];
    float2 uv [[attribute(SCNVertexSemanticTexcoord0)]];
    float3 normal [[ attribute(SCNVertexSemanticNormal) ]];
};

struct FragmentShaderPayload {
    float4 position [[position]];
    float2 uv;
    float3 normal;
};

struct light {
    float3 position;
    float3 intensity;
};

vertex FragmentShaderPayload phongTextureVertex(FragmentShaderInput in [[ stage_in ]], constant SceneBuffer& scn_frame [[buffer(0)]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    FragmentShaderPayload vertextOut;
    vertextOut.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0); // Project point into scene
    vertextOut.uv = in.uv; // Copy over text coord
    vertextOut.normal = (scn_node.modelViewTransform * float4(in.normal, 0)).xyz; // Copy over normal
    return vertextOut;
}

fragment float4 phongTextureFragment(FragmentShaderPayload out [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]], texture2d<float, access::sample> textureImage [[texture(0)]]) {
    
    // Define constants
    float3 ka = float3(0.001, 0.001, 0.001);
    float3 ks = float3(0.7937, 0.7937, 0.7937);
    float p = 30;
    
    // Define lights
    float intensity = 2000 * 255.0f;
    light l1 = light{{800, 600, 800}, {intensity, intensity, intensity}};
    light l2 = light{{-800, 600, 0}, {intensity, intensity, intensity}};
    light lights[2] = {l1, l2};
    
    float3 amb_light_intensity = float3(10, 10, 10);
    float3 eye_pos = float3(0, 0, 0);
    
    // Define points
    float3 point = float3(out.position[0], out.position[1], out.position[2]);
    float3 normal = out.normal;
    
    // Define result
    float3 result_color = float3(0, 0, 0);
    
    // Get color value
    float3 kd = float3(154 / 255.0f, 82 / 255.0f, 226 / 255.0f);
    
    // Loop through lights
    for (int i = 0; i < 2; i++) {
        
        // Get light
        auto light = lights[i];
        
        // Calculate r
        float3 lightPos = light.position;
        float3 r = distance(lightPos, point);
        auto pointIntensity = light.intensity / pow(r, 2);
        
        // Calculate l, v, n, and h
        auto l = normalize(lightPos - point);
        auto v = normalize(eye_pos - point);
        auto n = normalize(normal);
        auto h = (v + l) / length(v + l);
        
        // Calculate ambient
        auto ambient = ka * amb_light_intensity;
        
        // Calculate diffuse
        auto diffuse = kd * pointIntensity * fmax(0.0, dot(l, n));
        
        // Calculate specular
        auto specular = ks * pointIntensity * pow(fmax(0, dot(n, h)), p);
        
        // Combine results
        auto combined = ambient + diffuse + specular;
        
        // Append to total color
        result_color += combined;
        
    }
    
    // Return shaded color
    return float4(result_color[0], result_color[1], result_color[2], 1);
}

vertex FragmentShaderPayload texturedTextureVertex(FragmentShaderInput in [[ stage_in ]], constant SceneBuffer& scn_frame [[buffer(0)]], constant NodeBuffer& scn_node [[buffer(1)]]) {
    FragmentShaderPayload vertextOut;
    vertextOut.position = scn_node.modelViewProjectionTransform * float4(in.position, 1.0); // Project point into scene
    vertextOut.uv = in.uv; // Copy over text coord
    vertextOut.normal = (scn_node.modelViewTransform * float4(in.normal, 0)).xyz; // Copy over normal
    return vertextOut;
}

fragment float4 texturedTextureFragment(FragmentShaderPayload out [[ stage_in ]], constant NodeBuffer& scn_node [[buffer(1)]], texture2d<float, access::sample> textureImage [[texture(0)]]) {
    
    // Define constants
    float3 ka = float3(0.001, 0.001, 0.001);
    float3 ks = float3(0.7937, 0.7937, 0.7937);
    float p = 30;
    
    // Define lights
    float intensity = 2000 * 255.0f;
    light l1 = light{{800, 600, 800}, {intensity, intensity, intensity}};
    light l2 = light{{-800, 600, 0}, {intensity, intensity, intensity}};
    light lights[2] = {l1, l2};
    
    float3 amb_light_intensity = float3(10, 10, 10);
    float3 eye_pos = float3(0, 0, 0);
    
    // Define points
    float3 point = float3(out.position[0], out.position[1], out.position[2]);
    float3 normal = out.normal;
    
    // Define result
    float3 result_color = float3(0, 0, 0);
    
    // Get color value
    constexpr sampler textureSampler(coord::normalized, filter::linear, address::repeat);
    float4 textOutput = textureImage.sample(textureSampler, out.uv);
    float3 kd = float3(textOutput[0], textOutput[1], textOutput[2]);
    
    // Loop through lights
    for (int i = 0; i < 2; i++) {
        
        // Get light
        auto light = lights[i];
        
        // Calculate r
        float3 lightPos = light.position;
        float3 r = distance(lightPos, point);
        auto pointIntensity = light.intensity / pow(r, 2);
        
        // Calculate l, v, n, and h
        auto l = normalize(lightPos - point);
        auto v = normalize(eye_pos - point);
        auto n = normalize(normal);
        auto h = (v + l) / length(v + l);
        
        // Calculate ambient
        auto ambient = ka * amb_light_intensity;
        
        // Calculate diffuse
        auto diffuse = kd * pointIntensity * fmax(0.0, dot(l, n));
        
        // Calculate specular
        auto specular = ks * pointIntensity * pow(fmax(0, dot(n, h)), p);
        
        // Combine results
        auto combined = ambient + diffuse + specular;
        
        // Append to total color
        result_color += combined;
        
    }
    
    // Return shaded color
    return float4(result_color[0], result_color[1], result_color[2], 1);
}

