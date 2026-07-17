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

  [...content.querySelectorAll('p')].forEach((paragraph) => {
    const text = paragraph.textContent.replace(/[·|]/g, '').trim();
    const hasMeaningfulElement = paragraph.querySelector('img,picture,figure,video,iframe,svg,canvas,pre,code,table,a,button');
    if (!text && !hasMeaningfulElement) paragraph.remove();
  });
})();
