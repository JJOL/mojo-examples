// Import Three.js and OrbitControls using ES modules
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

// Initialize the scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0x87ceeb); // Light blue sky background

const camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    1,
    2000
);
camera.position.set(0, 150, 300); // Positioned to view the entire crane

const renderer = new THREE.WebGLRenderer({ antialias: true }); // Enable antialiasing
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Add ambient light and a directional light source
const ambientLight = new THREE.AmbientLight(0xffffff, 0.6);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(200, 400, 200);
scene.add(directionalLight);

// Enable camera controls
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();

// Function to create the Quay Crane
function createQuayCrane() {
    const craneGroup = new THREE.Group();

    // Scale factors (adjust as needed)
    const scale = 1; // Adjust this to scale the entire crane

    // Main Legs (Supports)
    const legWidth = 10 * scale;
    const legHeight = 100 * scale;
    const legDepth = 10 * scale;
    const legGeometry = new THREE.BoxGeometry(legWidth, legHeight, legDepth);
    const legMaterial = new THREE.MeshPhongMaterial({ color: 0xdd0000 }); // Bright red

    // Left Leg
    const leftLeg = new THREE.Mesh(legGeometry, legMaterial);
    leftLeg.position.set(-30 * scale, legHeight / 2, 0);
    craneGroup.add(leftLeg);

    // Right Leg
    const rightLeg = new THREE.Mesh(legGeometry, legMaterial);
    rightLeg.position.set(30 * scale, legHeight / 2, 0);
    craneGroup.add(rightLeg);

    // Horizontal Beam (Top Girder)
    const girderWidth = 80 * scale;
    const girderHeight = 10 * scale;
    const girderDepth = 10 * scale;
    const girderGeometry = new THREE.BoxGeometry(girderWidth, girderHeight, girderDepth);
    const girder = new THREE.Mesh(girderGeometry, legMaterial);
    girder.position.set(0, legHeight + girderHeight / 2, 0);
    craneGroup.add(girder);

    // Arm Structure (Boom)
    const boomLength = 100 * scale;
    const boomHeight = 10 * scale;
    const boomDepth = 10 * scale;
    const boomGeometry = new THREE.BoxGeometry(boomLength, boomHeight, boomDepth);
    const boom = new THREE.Mesh(boomGeometry, legMaterial);
    boom.position.set(girderWidth / 2 + boomLength / 2, legHeight + girderHeight / 2, 0);
    craneGroup.add(boom);

    // Diagonal Cables (Boom Cables)
    const cableMaterial = new THREE.LineBasicMaterial({ color: 0x000000 }); // Black

    const cableGeometry1 = new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(30 * scale, legHeight + girderHeight, 0),
        new THREE.Vector3(boom.position.x + boomLength / 2, legHeight + girderHeight / 2, 0),
    ]);

    const cable1 = new THREE.Line(cableGeometry1, cableMaterial);
    craneGroup.add(cable1);

    const cableGeometry2 = new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(-30 * scale, legHeight + girderHeight, 0),
        new THREE.Vector3(boom.position.x + boomLength / 2, legHeight + girderHeight / 2, 0),
    ]);

    const cable2 = new THREE.Line(cableGeometry2, cableMaterial);
    craneGroup.add(cable2);

    // Cabin
    const cabinWidth = 10 * scale;
    const cabinHeight = 10 * scale;
    const cabinDepth = 10 * scale;
    const cabinGeometry = new THREE.BoxGeometry(cabinWidth, cabinHeight, cabinDepth);
    const cabinMaterial = new THREE.MeshPhongMaterial({ color: 0x0000ff }); // Blue
    const cabin = new THREE.Mesh(cabinGeometry, cabinMaterial);
    cabin.position.set(girderWidth / 2 - cabinWidth / 2, legHeight + girderHeight / 2 - cabinHeight / 2, -girderDepth / 2 - cabinDepth / 2);
    craneGroup.add(cabin);

    // Trolley
    const trolleyWidth = 10 * scale;
    const trolleyHeight = 5 * scale;
    const trolleyDepth = 10 * scale;
    const trolleyGeometry = new THREE.BoxGeometry(trolleyWidth, trolleyHeight, trolleyDepth);
    const trolleyMaterial = new THREE.MeshPhongMaterial({ color: 0xffff00 }); // Yellow
    const trolley = new THREE.Mesh(trolleyGeometry, trolleyMaterial);
    trolley.position.set(0, legHeight + girderHeight + trolleyHeight / 2, 0);
    craneGroup.add(trolley);

    // Spreader
    const spreaderWidth = 40 * scale;
    const spreaderHeight = 2 * scale;
    const spreaderDepth = 5 * scale;
    const spreaderGeometry = new THREE.BoxGeometry(spreaderWidth, spreaderHeight, spreaderDepth);
    const spreader = new THREE.Mesh(spreaderGeometry, trolleyMaterial);
    spreader.position.set(0, legHeight + girderHeight - 20 * scale, 0);
    craneGroup.add(spreader);

    // Container Lift Mechanism (Cables)
    const hoistMaterial = new THREE.LineBasicMaterial({ color: 0x000000 }); // Black
    const hoistGeometry = new THREE.BufferGeometry().setFromPoints([
        new THREE.Vector3(trolley.position.x, trolley.position.y - trolleyHeight / 2, trolley.position.z),
        new THREE.Vector3(spreader.position.x, spreader.position.y + spreaderHeight / 2, spreader.position.z),
    ]);
    const hoistCable = new THREE.Line(hoistGeometry, hoistMaterial);
    craneGroup.add(hoistCable);

    // Base Platform
    const baseWidth = 80 * scale;
    const baseHeight = 5 * scale;
    const baseDepth = 20 * scale;
    const baseGeometry = new THREE.BoxGeometry(baseWidth, baseHeight, baseDepth);
    const baseMaterial = new THREE.MeshPhongMaterial({ color: 0x555555 }); // Dark gray
    const base = new THREE.Mesh(baseGeometry, baseMaterial);
    base.position.set(0, baseHeight / 2, 0);
    craneGroup.add(base);

    // Wheels
    const wheelRadius = 3 * scale;
    const wheelThickness = 2 * scale;
    const wheelGeometry = new THREE.CylinderGeometry(wheelRadius, wheelRadius, wheelThickness, 16);
    const wheelMaterial = new THREE.MeshPhongMaterial({ color: 0x000000 }); // Black
    const wheelPositions = [
        [-baseWidth / 2 + wheelThickness, wheelRadius, -baseDepth / 2 + wheelThickness],
        [baseWidth / 2 - wheelThickness, wheelRadius, -baseDepth / 2 + wheelThickness],
        [-baseWidth / 2 + wheelThickness, wheelRadius, baseDepth / 2 - wheelThickness],
        [baseWidth / 2 - wheelThickness, wheelRadius, baseDepth / 2 - wheelThickness],
    ];
    wheelPositions.forEach(pos => {
        const wheel = new THREE.Mesh(wheelGeometry, wheelMaterial);
        wheel.rotation.z = Math.PI / 2;
        wheel.position.set(...pos);
        craneGroup.add(wheel);
    });

    // Add the crane group to the scene
    scene.add(craneGroup);

    // Ground plane (Quay)
    const groundGeometry = new THREE.PlaneGeometry(500 * scale, 500 * scale);
    const groundMaterial = new THREE.MeshPhongMaterial({ color: 0x808080, side: THREE.DoubleSide });
    const ground = new THREE.Mesh(groundGeometry, groundMaterial);
    ground.rotation.x = -Math.PI / 2;
    ground.position.y = 0; // Align with base of crane
    scene.add(ground);
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
createQuayCrane();
animate();