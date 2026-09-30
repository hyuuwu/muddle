let tin=0;
const tinbutton = document.getElementById('tinbutton');
const tintext = document.getElementById('tintext');

tinbutton.addEventListener('click', () => {
  tin += 1;
  tintext.textcontent = 'Tin: ${tin}';
});
