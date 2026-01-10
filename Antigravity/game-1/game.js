const canvas = document.getElementById('gameCanvas');
const ctx = canvas.getContext('2d');

// Game State
let gameRunning = false;
let score = 0;
let gameSpeed = 5;
let frames = 0;
let playerName = "Player";

// UI Elements
const startScreen = document.getElementById('start-screen');
const gameOverScreen = document.getElementById('game-over-screen');
const finalScoreSpan = document.getElementById('final-score');
const startBtn = document.getElementById('start-btn');
const restartBtn = document.getElementById('restart-btn');
const nameInput = document.getElementById('player-name');
const highScoreList = document.getElementById('high-score-list');
const statusMessage = document.getElementById('status-message');

// Game Objects
const player = {
    x: 50,
    y: 200,
    width: 30,
    height: 30,
    dy: 0,
    jumpPower: -12,
    gravity: 0.6,
    grounded: false,
    color: '#00f3ff',

    draw: function () {
        ctx.fillStyle = this.color;

        // Glow effect
        ctx.shadowBlur = 10;
        ctx.shadowColor = this.color;
        ctx.fillRect(this.x, this.y, this.width, this.height);
        ctx.shadowBlur = 0;
    },

    update: function () {
        // Jump
        if (keys['Space'] || keys['ArrowUp']) {
            if (this.grounded) {
                this.dy = this.jumpPower;
                this.grounded = false;
                createParticles(this.x + this.width / 2, this.y + this.height);
            }
        }

        this.dy += this.gravity;
        this.y += this.dy;

        // Ground collision (simple floor)
        if (this.y + this.height > canvas.height - 50) {
            this.y = canvas.height - 50 - this.height;
            this.dy = 0;
            this.grounded = true;
        } else {
            this.grounded = false;
        }
    }
};

let obstacles = [];
let particles = [];
let keys = {};

// Input Handling
window.addEventListener('keydown', e => {
    keys[e.code] = true;
});

window.addEventListener('keyup', e => {
    keys[e.code] = false;
});

startBtn.addEventListener('click', startGame);
restartBtn.addEventListener('click', resetGame);

// Top level floor
const floorHeight = 50;

class Obstacle {
    constructor() {
        this.width = 30 + Math.random() * 30;
        this.height = 30 + Math.random() * 50;
        this.x = canvas.width;
        this.y = canvas.height - floorHeight - this.height;
        this.markedForDeletion = false;
    }

    update() {
        this.x -= gameSpeed;
        if (this.x + this.width < 0) this.markedForDeletion = true;
    }

    draw() {
        ctx.fillStyle = '#ff0055';
        ctx.shadowBlur = 10;
        ctx.shadowColor = '#ff0055';
        ctx.fillRect(this.x, this.y, this.width, this.height);
        ctx.shadowBlur = 0;
    }
}

class Particle {
    constructor(x, y) {
        this.x = x;
        this.y = y;
        this.size = Math.random() * 5 + 2;
        this.speedX = Math.random() * 2 - 1;
        this.speedY = Math.random() * -1 - 1; // move up
        this.color = '#00f3ff';
        this.markedForDeletion = false;
    }

    update() {
        this.x += this.speedX;
        this.y += this.speedY;
        this.size *= 0.95; // shrink
        if (this.size < 0.5) this.markedForDeletion = true;
    }

    draw() {
        ctx.fillStyle = this.color;
        ctx.beginPath();
        ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
        ctx.fill();
    }
}

function createParticles(x, y) {
    for (let i = 0; i < 5; i++) {
        particles.push(new Particle(x, y));
    }
}

function handleObstacles() {
    if (frames % 100 === 0) { // Spawn rate
        obstacles.push(new Obstacle());
        // Increase difficulty slightly
        if (gameSpeed < 12) gameSpeed += 0.1;
    }

    obstacles.forEach(obs => {
        obs.update();
        obs.draw();

        // Collision Check
        if (
            player.x < obs.x + obs.width &&
            player.x + player.width > obs.x &&
            player.y < obs.y + obs.height &&
            player.y + player.height > obs.y
        ) {
            gameOver();
        }
    });

    obstacles = obstacles.filter(obs => !obs.markedForDeletion);
}

function handleParticles() {
    particles.forEach(p => {
        p.update();
        p.draw();
    });
    particles = particles.filter(p => !p.markedForDeletion);
}

function drawEnvironment() {
    // Floor
    ctx.fillStyle = '#16213e';
    ctx.fillRect(0, canvas.height - 50, canvas.width, 50);
    // Floor highlight
    ctx.fillStyle = '#1f4068';
    ctx.fillRect(0, canvas.height - 50, canvas.width, 4);

    // Score
    ctx.fillStyle = 'white';
    ctx.font = "20px Orbitron";
    ctx.fillText("Score: " + Math.floor(score), 20, 30);
}

function animate() {
    if (!gameRunning) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    drawEnvironment();
    handleObstacles();
    handleParticles();
    player.update();
    player.draw();

    score += 0.1; // Score based on survival time/distance
    frames++;
    requestAnimationFrame(animate);
}

function startGame() {
    const name = nameInput.value.trim();
    if (name) {
        playerName = name;
    } else {
        playerName = "Anonymous";
    }

    startScreen.classList.add('hidden');
    gameOverScreen.classList.add('hidden');

    resetGameState();
    gameRunning = true;
    animate();
}

function resetGameState() {
    score = 0;
    gameSpeed = 5;
    frames = 0;
    obstacles = [];
    particles = [];
    player.y = 200;
    player.dy = 0;
}

function gameOver() {
    gameRunning = false;
    finalScoreSpan.innerText = Math.floor(score);
    startScreen.classList.add('hidden');
    gameOverScreen.classList.remove('hidden');

    saveScore(playerName, Math.floor(score));
}

function resetGame() {
    startGame();
}

async function saveScore(name, scoreVal) {
    statusMessage.innerText = "Saving score...";
    try {
        const response = await fetch('save_score.php', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ name: name, score: scoreVal })
        });

        if (response.ok) {
            statusMessage.innerText = "Score Saved!";
            loadHighScores();
        } else {
            // Check if it's a 404/405 (likely no PHP server needed)
            statusMessage.innerText = "Score not saved (PHP backend not detected/configured).";
            console.warn("Backend error or missing");
        }
    } catch (e) {
        statusMessage.innerText = "Local mode (No Backend Connection).";
        console.warn("Fetch failed", e);
    }
}

async function loadHighScores() {
    highScoreList.innerHTML = "<li>Loading...</li>";
    try {
        const response = await fetch('get_scores.php');
        if (response.ok) {
            const scores = await response.json();
            highScoreList.innerHTML = scores.map(s => `<li><span>${s.name}</span> <span class="s-score">${s.score}</span></li>`).join('');
            if (scores.length === 0) {
                highScoreList.innerHTML = "<li>No scores yet!</li>";
            }
        } else {
            highScoreList.innerHTML = "<li>Backend unavailable</li>";
        }
    } catch (e) {
        highScoreList.innerHTML = "<li>Offline/No Backend</li>";
    }
}

// Initial load
loadHighScores();
