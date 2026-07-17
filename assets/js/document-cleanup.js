(() => {
  const content = document.querySelector('.document-content');
  if (!content) return;

  const repositoryBase = '/vivado-traffic-signal-controller/';
  content.querySelectorAll('img').forEach((image) => {
    const source = image.getAttribute('src') || '';
    if (!source || /^(?:data:|https?:\/\/)/i.test(source)) return;
    const marker = 'images/';
    const index = source.indexOf(marker);
    if (index >= 0) image.setAttribute('src', `${repositoryBase}${source.slice(index)}`);
  });

  content.querySelectorAll('a[href$=".v"]').forEach((link) => {
    const href = link.getAttribute('href') || '';
    const marker = 'src/';
    const index = href.indexOf(marker);
    if (index < 0) return;
    const codePath = href.slice(index);
    link.dataset.codeFile = codePath;
    link.dataset.codeTitle = link.textContent.trim() || codePath.split('/').pop();
    link.href = '#';
    link.setAttribute('role', 'button');
  });

  [...content.querySelectorAll('p')].forEach((paragraph) => {
    const text = paragraph.textContent.replace(/[·|]/g, '').trim();
    const hasMeaningfulElement = paragraph.querySelector('img,picture,figure,video,iframe,svg,canvas,pre,code,table,a,button');
    if (!text && !hasMeaningfulElement) paragraph.remove();
  });
})();
