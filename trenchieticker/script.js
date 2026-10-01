let tin = 0;
const tinbutton = document.getElementById('tinbutton');
const tinnumber = document.getElementById('tinnumber');

tinbutton.addEventListener('click', () => {
  tin += 1;
  tinnumber.textContent = tin;
});
