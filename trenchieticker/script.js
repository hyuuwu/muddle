let tin = 0;
let tinPerClick = 1; //at base
const tinButton = document.getElementById('tinbutton');
const tinNumber = document.getElementById('tinnumber');

tinButton.addEventListener('click', () => {
  tin += tinPerClick;
  tinNumber.textContent = tin;
});
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
    tinPerClick += boost;
    tinNumber.textContent = tin;
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
  if (progress >= 1) {
    clearInterval(flipInterval);
    runnerman.remove()
  } else {
    requestAnimationFrame(step);
  }
  container.appendChild(runnerman);

  const duration = 6000;
  const endPos = 165;
  let startTime = null;
  function step(timestamp) {
      if (!startTime) startTime = timestamp;
      const elapsed = timestamp - startTime;
      const progress = Math.min(elapsed / duration, 1);
    
      runnerman.style.transform = `TranslateY(${progress * endPos}px)`;

      if (progress < 1) {
        requestAnimationFrame(step);
      } else {
          runnerman.remove();
      }
  }
}
function scheduleRunnerman() {
  const randomDelay = Math.floor(Math.random() * 50000) + 40000
  setTimeout(() => {
    spawnRunnerman();
    scheduleRunnerman(); //loop
  }, randomDelay);
}
scheduleRunnerman();
