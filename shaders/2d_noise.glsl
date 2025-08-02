//credits to https://blog.pkh.me/p/42-sharing-everything-i-could-understand-about-gradient-noise.html

uniform float time;
uniform vec2 res;

uint hash(uint x) {
  x = (x ^ (x >> 16)) * 0x21f0aaadU;
  x = (x ^ (x >> 15)) * 0x735a2d97U;
  return x ^ (x >> 15);
}

uint hash(uvec2 x) {
  return hash(x.x ^ hash(x.y));
}

float u2f(uint x) {
  return float(x >> 8U) * uintBitsToFloat(0x33800000U);
}

vec2 fade_quintic(vec2 t) {
  return ((6.0*t-15.0)*t+10.0)*t*t*t;
}

vec2 grad(ivec2 x) {
  float angle = u2f(hash(uvec2(x))) * 6.283185307179586;
  return vec2(cos(angle), sin(angle));
}

float noise(vec2 uv) {
  ivec2 i = ivec2(floor(uv));
  vec2 g0 = grad(i);
  vec2 g1 = grad(i + ivec2(1, 0));
  vec2 g2 = grad(i + ivec2(0, 1));
  vec2 g3 = grad(i + ivec2(1, 1));

  vec2 f = fract(uv);
  float v0 = dot(g0, f);
  float v1 = dot(g1, f - vec2(1.0, 0.0));
  float v2 = dot(g2, f - vec2(0.0, 1.0));
  float v3 = dot(g3, f - vec2(1.0, 1.0));

  vec2 a = fade_quintic(f);
  return mix(
    mix(v0, v1, a.x),
    mix(v2, v3, a.x),
    a.y
  );
}

void main() {
  vec2 uv = gl_FragCoord.xy/res.xy;
  uv = uv * 2.0 - 1.0;
  uv.x *= res.x / res.y;

  vec2 fog_uv = uv * 2.125;
  fog_uv.x += 0.5 + 0.5*sin(time * 0.25);
  fog_uv.y += fog_uv.x / 2.0;

  float n = noise(fog_uv) * 0.5 + 0.5;
  vec3 fog_c = mix(vec3(0.25, 0.25, 0.4), vec3(0.2, 0.2, 0.2), n);

  gl_FragColor = vec4(fog_c, 1.0);
}
