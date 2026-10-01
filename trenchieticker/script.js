let tin = 0;
let tinperclick = 1; //at base
const tinbutton = document.getElementById('tinbutton');
const tinnumber = document.getElementById('tinnumber');

tinbutton.addEventListener('click', () => {
  tin += tinperclick;
  tinnumber.textContent = tin;
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
function buymod(cost, boost, element) {
  if (tin >= cost) {
    tin -= cost;
    tinperclick += boost;
    tinnumber.textContent = tin;
    element.style.display = 'none';
    const currenttier = element.parentElement;
    if (currenttier.classList.contains('andtier')) {
      const unbought = Array.from(currenttier.querySelectorAll('.button'))
                            .some(btn => btn.style.display !== 'none');
      if (unbought) return;
    }
    currenttier.style.display = 'none';
    const nexttier = currenttier.nextElementSibling;
    if (nexttier) {
      nexttier.querySelectorAll('.button').forEach(btn => {
        btn.classList.remove('locked');
        if (btn.dataset.original) btn.innerHTML = btn.dataset.original;
      });
    }
  }
}
