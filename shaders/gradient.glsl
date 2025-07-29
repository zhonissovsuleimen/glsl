uniform float time;
uniform vec2 res;

void main() {
  vec2 uv = gl_FragCoord.xy/res.xy;
  gl_FragColor = vec4(uv.xy, sin(time), 1.0);
}
