// Import Three.js and OrbitControls using ES modules
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

// Initialize the scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x87ceeb); // Light blue sky background

const camera = new THREE.PerspectiveCamera(
    60, // Reduced field of view for a better perspective
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);
camera.position.set(0, 20, 60); // Move the camera further back and up for better coverage

const renderer = new THREE.WebGLRenderer({ antialias: true }); // Enable antialiasing
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Add ambient light and a directional light source
const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(10, 20, 10);
scene.add(directionalLight);

// Enable camera controls
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();

// Function to create the cargo vessel
function createCargoVessel() {
    // Extend the ship's hull
    const hullLength = 30; // Increased from 20
    const hullGeometry = new THREE.BoxGeometry(hullLength, 4, 10);
    const hullMaterial = new THREE.MeshPhongMaterial({ color: 0x8b4513 }); // Brown color
    const hull = new THREE.Mesh(hullGeometry, hullMaterial);
    hull.position.y = 2; // Raise the hull above the "water"
    scene.add(hull);

    // Extend the deck
    const deckLength = 28; // Increased from 18
    const deckGeometry = new THREE.BoxGeometry(deckLength, 1, 10);
    const deckMaterial = new THREE.MeshPhongMaterial({ color: 0xdeb887 }); // Light brown
    const deck = new THREE.Mesh(deckGeometry, deckMaterial);
    deck.position.y = 4;
    scene.add(deck);

    // Reposition the bridge (ship's control tower)
    const bridgeGeometry = new THREE.BoxGeometry(4, 4, 6);
    const bridgeMaterial = new THREE.MeshPhongMaterial({ color: 0xffffff }); // White color
    const bridge = new THREE.Mesh(bridgeGeometry, bridgeMaterial);
    bridge.position.set(-10, 6, 0); // Moved further back
    scene.add(bridge);

    // Create stacked containers
    const containerGeometry = new THREE.BoxGeometry(2, 2, 2);
    const containerColors = [0xff0000, 0x00ff00, 0x0000ff, 0xffff00, 0xffa500]; // Red, Green, Blue, Yellow, Orange

    const startX = -4; // Shifted forward to leave space at the back
    const startY = 5;
    const startZ = -2;

    const containersInLength = 8; // Increased number of containers along the length
    for (let i = 0; i < containersInLength; i++) {
        for (let j = 0; j < 3; j++) {
            for (let k = 0; k < 3; k++) {
                const containerMaterial = new THREE.MeshPhongMaterial({
                    color: containerColors[(i + j + k) % containerColors.length],
                });
                const container = new THREE.Mesh(containerGeometry, containerMaterial);
                container.position.set(
                    startX + i * 2,
                    startY + j * 2,
                    startZ + k * 2
                );
                scene.add(container);
            }
        }
    }

    // Create "water" plane
    const waterGeometry = new THREE.PlaneGeometry(1000, 1000);
    const waterMaterial = new THREE.MeshPhongMaterial({
        color: 0x1e90ff,
        side: THREE.DoubleSide,
    });
    const water = new THREE.Mesh(waterGeometry, waterMaterial);
    water.rotation.x = -Math.PI / 2;
    scene.add(water);
}

// Animation loop
function animate() {
    requestAnimationFrame(animate);
    controls.update();
    renderer.render(scene, camera);
}

// Handle window resize
window.addEventListener('resize', onWindowResize, false);
function onWindowResize() {
    camera.aspect = window.innerWidth / window.innerHeight;
    camera.updateProjectionMatrix();
    renderer.setSize(window.innerWidth, window.innerHeight);
}

// Start the visualization
createCargoVessel();
animate()