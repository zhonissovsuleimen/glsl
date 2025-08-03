import * as THREE from 'three';

const scene = new THREE.Scene();
const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const canvas = document.getElementById('main-canvas');
const renderer = new THREE.WebGLRenderer({ canvas, antialias: true });
renderer.setPixelRatio(window.devicePixelRatio);

const vertexShader = await fetch('./shaders/vertex.glsl').then(res => res.text());
const fragmentShader = await fetch('./shaders/fallback.glsl').then(res => res.text());

const uniforms = {
  time: { value: 0.0 },
  res: { value: new THREE.Vector2() },
};

const material = new THREE.ShaderMaterial({
  vertexShader,
  fragmentShader,
  uniforms,
});

const geometry = new THREE.PlaneGeometry(2, 2);
const plane = new THREE.Mesh(geometry, material);
scene.add(plane);

async function loadShader(shaderFile) {
  const newFragmentShader = await fetch(shaderFile).then(res => res.text());
  material.fragmentShader = newFragmentShader;
  material.needsUpdate = true;
}

function onWindowResize() {
  const newWidth = window.innerWidth;
  const newHeight = window.innerHeight;

  renderer.setSize(newWidth, newHeight);
  uniforms.res.value.x = newWidth;
  uniforms.res.value.y = newHeight;
}

const clock = new THREE.Clock();
function animate() {
  requestAnimationFrame(animate);
  uniforms.time.value = clock.getElapsedTime();
  renderer.render(scene, camera);
}

window.addEventListener('resize', onWindowResize, false);
onWindowResize();
animate();

const shaders = [
  { title: 'Gradient', filename: 'gradient' },
  { title: 'Circles', filename: 'circles' },
  { title: 'Fog', filename: '2d_noise' },
  { title: 'Spheres', filename: 'spheres' },
];

const shaderList = document.querySelector('#shader-picker ul');

shaders.forEach(shader => {
  const listItem = document.createElement('li');
  const link = document.createElement('a');
  link.href = `#${shader.filename}`;
  link.textContent = shader.title;
  link.addEventListener('click', (e) => {
    e.preventDefault();
    window.location.hash = shader.filename;
    loadShader(`./shaders/${shader.filename}.glsl`);
  });
  listItem.appendChild(link);
  shaderList.appendChild(listItem);
});

function loadShaderFromHash() {
  const shaderId = window.location.hash.substring(1) || 'basic';
  const shader = shaders.find(s => s.filename === shaderId);
  if (shader) {
    loadShader(`./shaders/${shader.filename}.glsl`);
  } else {
    loadShader('./shaders/fallback.glsl');
  }
}

window.addEventListener('hashchange', loadShaderFromHash);
loadShaderFromHash();