// Import Three.js and OrbitControls using ES modules
import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';


const solutionLabelEl = document.getElementById('solution-label');
const volumeLabelEl = document.getElementById('volume-label');

const prevBtnEl = document.getElementById('prev-btn')
const currIndexLabel = document.getElementById('actual-index-label');
const nextBtnEl = document.getElementById('next-btn');
const fullBtnEL = document.getElementById('full-btn');
const clearBtnEL = document.getElementById('clear-btn');
let currIndex = 1;

// Initialize the scene, camera, and renderer
const scene = new THREE.Scene();
scene.background = new THREE.Color(0xffffff); // Set background to white

const camera = new THREE.PerspectiveCamera(
    75,
    window.innerWidth / window.innerHeight,
    0.1,
    1000
);
camera.position.set(15, 15, 25); // Adjusted camera position for better view

const renderer = new THREE.WebGLRenderer({ antialias: true }); // Enable antialiasing
renderer.setSize(window.innerWidth, window.innerHeight);
document.body.appendChild(renderer.domElement);

// Add ambient light and a directional light source
const ambientLight = new THREE.AmbientLight(0xcccccc, 0.8);
scene.add(ambientLight);

const directionalLight = new THREE.DirectionalLight(0xffffff, 0.8);
directionalLight.position.set(10, 10, 10);
scene.add(directionalLight);

// Enable camera controls
const controls = new OrbitControls(camera, renderer.domElement);
controls.update();


let cubesHandles = [];
window.cubesHandles = cubesHandles;

// Function to load and parse the solution file
function loadSolution(solutionFile) {
    fetch(solutionFile)
        .then((response) => response.text())
        .then((data) => {
            const cubes = [];
            const lines = data.split('\n');

            let solution = lines[0].split(':')[1].trim();
            let volume = lines[1].split(':')[1].trim();
            solutionLabelEl.innerHTML = solution;
            volumeLabelEl.innerHTML = volume;

            lines.forEach((line) => {
                line = line.trim();
                if (line.startsWith('cubes[')) {
                    const coordsText = line.split(':')[1].trim();
                    const coords = coordsText
                        .replace(/[()]/g, '')
                        .split(',')
                        .map(Number);
                    cubes.push(coords);
                }
            });

            recenterCubes(cubes);

            createCubes(cubes);
            createLinkages(cubes);
            showUpTo(1);
            animate();
        })
        .catch((error) => {
            console.error('Error loading solution.txt:', error);
        });
}

// Function to offset the cube so the middle cube is at the origin (0, 0, 0)
function recenterCubes(cubePositions) {
    const minCoords = cubePositions.reduce((acc, val) => {
        return val.map((v, i) => Math.min(v, acc[i]));
    }, cubePositions[0]);
    const maxCoords = cubePositions.reduce((acc, val) => {
        return val.map((v, i) => Math.max(v, acc[i]));
    }, cubePositions[0]);

    const midCoords = maxCoords.map((v, i) => (v + minCoords[i]) / 2);

    cubePositions.forEach((position) => {
        for (let i = 0; i < position.length; i++) {
            position[i] -= midCoords[i];
        }
    });

}

// Function to create cube meshes with borders and transparency
function createCubes(cubePositions) {
    // Slightly smaller cube geometry to create gaps between cubes
    const cubeGeometry = new THREE.BoxGeometry(0.9, 0.9, 0.9);

    // Semi-transparent material for the cubes
    const cubeMaterial = new THREE.MeshPhongMaterial({
        color: 0x00ff00,
        transparent: true,
        opacity: 0.5,
        wireframe: false,
    });

    // Material for the edges (borders)
    const edgesMaterial = new THREE.LineBasicMaterial({ color: 0x000000 });

    let i = 0;
    cubePositions.forEach((position) => {
        // Create the cube mesh
        //make a copy of cubeMaterial to avoid sharing the same material
        let copyMaterial = cubeMaterial.clone();
        const cubeMesh = new THREE.Mesh(cubeGeometry, copyMaterial);
        cubeMesh.position.set(position[0], position[1], position[2]);
        

        
        // Create and add edges to the cube
        const edgesGeometry = new THREE.EdgesGeometry(cubeGeometry);
        const edges = new THREE.LineSegments(edgesGeometry, edgesMaterial.clone());
        // hide edges initially

        edges.position.copy(cubeMesh.position);
        

        i+=1;
        cubesHandles.push({
            cubeMesh, edges
        });
        // setTimeout(() => {
        //     scene.add(cubeMesh);
        //     scene.add(edges);
        //     // edges.material.opacity = 1;
        // }, i*100);
    });
}

function showUpTo(currIndex) {
    for (var i = 1; i <= 27; i++) {
        let {cubeMesh, edges} = cubesHandles[i-1];
        if (i <= currIndex) {
            scene.add(cubeMesh);
            scene.add(edges);
            if (i == currIndex) {
                cubeMesh.material.color = {r: 0, g: 0, b: 1};
            } else {
                cubeMesh.material.color = {r: 1, g: 1, b: 1};
            }
        } else {
            scene.remove(cubeMesh);
            scene.remove(edges);
        }
    }
}

function fillSolution() {
    for (let i = 0; i < 27; i++) {
        let {cubeMesh, edges} = cubesHandles[i];
        cubeMesh.material.color = {r: 0, g: 0, b: 1};
        scene.add(cubeMesh);
        scene.add(edges);
    }
}

function clearSolution() {
    for (let i = 1; i < 27; i++) {
        let {cubeMesh, edges} = cubesHandles[i];
        scene.remove(cubeMesh);
        scene.remove(edges);
    }
}

// Function to create linkage lines between cubes
function createLinkages(cubePositions) {
    const linkageMaterial = new THREE.LineBasicMaterial({ color: 0x000000, linewidth: 2 });

    for (let i = 0; i < cubePositions.length - 1; i++) {
        const startPos = new THREE.Vector3(...cubePositions[i]);
        const endPos = new THREE.Vector3(...cubePositions[i + 1]);

        // Create a geometry for the linkage line
        const linkageGeometry = new THREE.BufferGeometry().setFromPoints([startPos, endPos]);

        // Create the line and add it to the scene
        const linkageLine = new THREE.Line(linkageGeometry, linkageMaterial);
        scene.add(linkageLine);
    }
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

prevBtnEl.addEventListener('click', () => {
    if (currIndex == 1) return;
    currIndex -= 1;
    currIndexLabel.innerHTML = currIndex;
    showUpTo(currIndex);
});

nextBtnEl.addEventListener('click', () => {
    if (currIndex == 27) return;

    currIndex += 1;
    
    currIndexLabel.innerHTML = currIndex;
    showUpTo(currIndex);
});

fullBtnEL.addEventListener('click', () => {
    currIndex = 27;
    currIndexLabel.innerHTML = currIndex;
    fillSolution();
});

clearBtnEL.addEventListener('click', () => {
    currIndex = 1;
    currIndexLabel.innerHTML = currIndex;
    clearSolution();
});

// Start the visualization
loadSolution(window.solutionFile);