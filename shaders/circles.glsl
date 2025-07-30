uniform float time;
uniform vec2 res;


vec2 rotate(vec2 uv, float deg) {
  mat2 rotate_matrix = mat2(cos(deg), -sin(deg), sin(deg), cos(deg));
  return rotate_matrix * uv;
}

void main() {
  vec2 uv = gl_FragCoord.xy / res.xy;
  uv = uv * 2.0 - 1.0;
  uv.x *= res.x / res.y;

  uv = rotate(uv, time * -0.1);
  float offset = 0.5;
  float red_time = time;
  float green_time = time - sin(time * offset);
  float blue_time = time - 2.0 * sin(time * offset);

  float radius = 0.1;
  vec2 red_center = sin((red_time + 1.0) * uv);
  vec2 green_center = sin((green_time + 1.0) * uv);
  vec2 blue_center = sin((blue_time + 1.0) * uv);

  float red_dist = length(red_center) - radius;
  float green_dist = length(green_center) - radius;
  float blue_dist = length(blue_center) - radius;

  float r = step(radius, red_dist);
  float g = step(radius, green_dist);
  float b = step(radius, blue_dist);
  gl_FragColor = vec4(r, g, b, 1.0);
}