let tin = 0;
let tinperclick = 1; //at base
const tinbutton = document.getElementById('tinbutton');
const tinnumber = document.getElementById('tinnumber');

tinbutton.addEventListener('click', () => {
  tin += tinperclick;
  tinnumber.textContext = tin;
});
function buymod(cost, boost, element) {
  if (tin >= cost) {
    tin -= cost;
    tinperclick += boost;
    tinnumber.textContent = tin;
    element.style.display = 'none';
  }
}
