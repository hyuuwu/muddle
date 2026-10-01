let tin = 0;
let tinperclick = 1; //at base
const tinbutton = document.getElementById('tinbutton');
const tinnumber = document.getElementById('tinnumber');

tinbutton.addEventListener('click', () => {
  tin += tinperclick;
  tinnumber.textContent = tin;
});
document.querySelectorAll('#tiers .button').forEach((btn, index) => {
  if (index > 0) {
    btn.classList.add('locked');
    btn.dataset.original = btn.innerHTML;
    const attr = btn.getAttribute('onclick');
    if (attr) btn.innerHTML = `${attr.match(/\d+/)[0]} Tin`; //regex
  }
});
function buymod(cost, boost, element) {
  if (tin >= cost) {
    tin -= cost;
    tinperclick += boost;
    tinnumber.textContent = tin;
    element.style.display = 'none';
    const buttons = Array.from(document.querySelectorAll('#tiers .button'));
    const nextbutton = buttons[buttons.indexOf(element) + 1];
    if (nextbutton) {
      nextbutton.classList.remove('locked'); //unlock
      nextbutton.innerHTML = nextbutton.dataset.original;
  }
}
