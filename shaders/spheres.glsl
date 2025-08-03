uniform float time;
uniform vec2 res;

vec2 rotate(vec2 uv, float deg) {
  mat2 rotation_matrix  = mat2(cos(deg), -sin(deg), sin(deg), cos(deg));
  return rotation_matrix * uv;
}

float map(vec3 p) {
  vec3 spacing = vec3(3.0, 3.0, 5.0);
  float radius = 1.0;
  
  vec3 repeated_p = mod(p, spacing) - spacing * 0.5;
  return length(repeated_p) - radius;
}

vec2 quantize(vec2 uv, int num_buckets) {
  float f_buckets = float(num_buckets);
  return floor(uv * f_buckets) / f_buckets;
}

vec3 quantize(vec3 uv, int num_buckets) {
  float f_buckets = float(num_buckets);
  return floor(uv * f_buckets) / f_buckets;
}

float heartbeat(float x) {
  float a = fract(-0.25 * x - 0.1);
  float b = fract(-0.25 * x);

  float short_beat = a * a;
  float long_beat = b * b;

  return long_beat + short_beat;
}

void main() {
  vec2 uv = (gl_FragCoord.xy * 2.0 - res.xy) / res.y;
  uv = quantize(uv, 200);

  vec3 origin = vec3(0.0, 0.0, 0.75 * time);
  vec3 direction = normalize(vec3(uv, 1.0));
  vec3 c = vec3(0.0);

  float total_distance = 0.0;
  float max_distance = 15.0;
  int i = 0;
  int max_i = 48;

  for (; i < max_i; i++) {
    vec3 p = origin + direction * total_distance;
    p.xy = rotate(p.xy, (p.z - origin.z) * 0.03);
    float distance = map(p);

    total_distance += distance;
    if (distance < 0.001) {
      float l = length(p - origin);
      c = vec3(fract(0.1 * l));
      c = quantize(c, 8);

      break;
    }

    if (total_distance > max_distance) {
      float freq_fn = heartbeat(origin.z);
      c.r = float(i) / float(max_i) * freq_fn;
      break;
    }
  }


  // float r = fract(total_distance);
  // float g = fract(3.0 * total_distance / PI);
  // float b = fract(7.0 * total_distance / e);
  // gl_FragColor = vec4(r, g, b, 1.0);
  gl_FragColor = vec4(c, 1.0);
}
