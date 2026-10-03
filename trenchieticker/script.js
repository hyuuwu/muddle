let tin = 0;
let baseTinPerClick = 1; //at base
const tinButton = document.getElementById('tinbutton');
const tinNumber = document.getElementById('tinnumber');
let activeDays = 0;
let retireTimes = 0;

function getMultiplier() {
  return 1 + (activeDays / 100);
}
function getTinPerClick() {
  return baseTinPerClick * getMultiplier();
}

function clickTin() {
  tin += getTinPerClick();
  tinNumber.textContent = Math.floor(tin);
}
document.querySelectorAll('#tiers > div').forEach((row, index) => {
  if (index > 0) {
    row.querySelectorAll('.button').forEach(btn => {
      btn.classList.add('locked');
      btn.dataset.original = btn.innerHTML;
      const attr = btn.getAttribute('onclick');
      if (attr) btn.innerHTML = `${attr.match(/\d+/)[0]} Tin`;
      else btn.innerHTML = '';
    });
  }
});
function buyMod(cost, boost, element) {
  if (tin >= cost) {
    tin -= cost;
    baseTinPerClick += boost;
    tinNumber.textContent = Math.floor(tin);
    element.style.display = 'none';
    const currentTier = element.parentElement;
    if (currentTier.classList.contains('andtier')) {
      const unbought = Array.from(currentTier.querySelectorAll('.button'))
                            .some(btn => btn.style.display !== 'none');
      if (unbought) return;
    }
    currentTier.style.display = 'none';
    const nextTier = currentTier.nextElementSibling;
    if (nextTier) {
      nextTier.querySelectorAll('.button').forEach(btn => {
        btn.classList.remove('locked');
        if (btn.dataset.original) btn.innerHTML = btn.dataset.original;
      });
    }
  }
}
function spawnRunnerman() {
  const container = document.getElementById('runnerman');
  if (!container) return;

  const runnerman = document.createElement('div');
  runnerman.className = 'runnerman';
  const maxLeft = container.clientWidth - 30;
  runnerman.style.left = Math.floor(Math.random() * maxLeft) + 'px';
  const sprite = document.createElement('div');
  sprite.className = 'sprite';
  runnerman.appendChild(sprite);
  const flipInterval = setInterval(() => {
  sprite.classList.toggle('flipped');
  }, 1000);

  runnerman.onclick = function() {
    const roll = Math.random();
    const baseTin = baseTinPerClick;
    if (roll < 0.5) {
      const instantTin = baseTinPerClick * 400;
      tin += instantTin;
      tinNumber.textContent = Math.floor(tin);
    } else {
      baseTinPerClick *= 4;

      setTimeout(() => {
        baseTinPerClick = baseTin;
      }, 10000);
    }
    clearInterval(flipInterval);
    runnerman.remove();
  };
  container.appendChild(runnerman);

  const duration = 2000;
  const endPos = 165;
  let startTime = null;
  function step(timestamp) {
      if (startTime === null) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const progress = Math.min(elapsed / duration, 1);
    
      runnerman.style.transform = `translateY(${progress * endPos}px)`;

    if (progress >= 1) {
      clearInterval(flipInterval);
      runnerman.remove()
    } else {
      requestAnimationFrame(step);
    }
  }
  requestAnimationFrame(step);
}
function scheduleRunnerman() {
  const randomDelay = Math.floor(Math.random() * 50000) + 40000
  setTimeout(() => {
    spawnRunnerman();
    scheduleRunnerman(); //loop
  }, randomDelay);
}
function retire() {
  const allButtons = document.querySelectorAll('#tiers .button');
  let passiveDays = 0;
  allButtons.forEach(btn => {
    if (btn.style.display === 'none') {
      passiveDays++;
    }
  });
  
  if (passiveDays === 0) return;
  activeDays += passiveDays;
  retireTimes++;
  tin = 0;
  baseTinPerClick = 1;
  document.getElementById('tinnumber').textContent = 0;
  const daysSpan = document.querySelector('#daystext span');
  if (daysSpan) daysSpan.textContent = activeDays;
  const tiers = document.querySelectorAll('#tiers > div');
  tiers.forEach((tier, index) => {
    tier.style.display = '';
    tier.querySelectorAll('.button').forEach(btn => {
      btn.style.display = '';
      if (index === 0) {
        btn.classList.remove('locked');
        if (btn.dataset.original) {
          btn.innerHTML = btn.dataset.original;
        }
      } else {
        btn.classList.add('locked');
        if (btn.dataset.original) {
          const attr = btn.getAttribute('onclick');
          if (attr) {
            const match = attr.match(/-?\d+/);
            btn.innerHTML = match ? `${match[0]} Tin` : '';
          }
        }
        if (retireTimes > 0) {
          const greatestWar = document.getElementById('greatestwar');
          if (greatestWar) {
            greatestWar.style.display = 'none';
          }
        }
      }
    });
  });
}
scheduleRunnerman();
