//
//  Underwater.metal
//  DeepBlue
//
//  Created by eos on 2/10/24.
//

#include <metal_stdlib>
using namespace metal;

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

float noise(float2 p) {
    float2 ip = floor(p);
    float2 u = fract(p);
    u = u * u * (3.0 - 2.0 * u);

    float res = mix(
        mix(hash(ip.x + hash(ip.y)), hash(ip.x + 1.0 + hash(ip.y)), u.x),
        mix(hash(ip.x + hash(ip.y + 1.0)), hash(ip.x + 1.0 + hash(ip.y + 1.0)), u.x),
        u.y
    );
    return res * res;
}

float simulateDust(float2 uv, float time) {
    float driftSpeed = 0.05;
    float2 drift = float2(time * driftSpeed, time * driftSpeed);

    float scale = 80.0;
    float dust = noise((uv + drift) * scale);

    float varianceScale = 15.0;
    float variance = noise((uv + drift) * varianceScale) * 0.5 + 0.5;
    float baseThreshold = 0.95;
    float threshold = mix(baseThreshold, 1.0, variance);

    float depthFactor = uv.y * 0.2 + 0.8;

    float visibility = dust > threshold ? depthFactor : 0.0;

    return visibility;
}

[[kernel]]
void underwaterEffectCompute(
    texture2d<float, access::read> inputTexture [[texture(0)]],
    texture2d<float, access::write> outputTexture [[texture(1)]],
    constant float &time [[buffer(0)]],
    uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= outputTexture.get_width() || gid.y >= outputTexture.get_height())
        return;

    float2 uv = float2(gid) / float2(outputTexture.get_width(), outputTexture.get_height());
    
    float baseWaveStrength = 0.006;
    float baseWaveSpeed = 1.0;

    float secondaryWaveStrength = 0.003;
    float secondaryWaveSpeed = 0.5;
    float secondaryWaveFrequency = 8.0;

    float tertiaryWaveStrength = 0.0015;
    float tertiaryWaveSpeed = 0.75;
    float tertiaryWaveFrequency = 20.0;

    uv.x += sin(uv.y * 6.0 + time * baseWaveSpeed) * baseWaveStrength;
    uv.y += cos(uv.x * 6.0 + time * baseWaveSpeed) * baseWaveStrength;

    uv.x += sin(uv.y * secondaryWaveFrequency + time * secondaryWaveSpeed) * secondaryWaveStrength;
    uv.y += cos(uv.x * secondaryWaveFrequency + time * secondaryWaveSpeed) * secondaryWaveStrength;

    uv.x += sin(uv.y * tertiaryWaveFrequency + time * tertiaryWaveSpeed) * tertiaryWaveStrength;
    uv.y += cos(uv.x * tertiaryWaveFrequency + time * tertiaryWaveSpeed) * tertiaryWaveStrength;

    uint2 distortedGid = uint2(uv * float2(outputTexture.get_width(), outputTexture.get_height()));

    distortedGid.x = min(distortedGid.x, outputTexture.get_width() - 1);
    distortedGid.y = min(distortedGid.y, outputTexture.get_height() - 1);

    float4 color = inputTexture.read(distortedGid);

    float dust = simulateDust(uv, time);
    color.rgb += float3(dust) * 0.5;

    color.rgb *= float3(0.2, 0.5, 0.7);
    
    outputTexture.write(color, gid);
}
