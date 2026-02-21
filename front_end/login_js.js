function switchTab(name) {
    document.querySelectorAll('.tab').forEach(t => {
      t.classList.toggle('active', t.dataset.tab === name);
    });
    document.querySelectorAll('.form-panel').forEach(p => {
      p.classList.toggle('active', p.id === 'panel-' + name);
    });
  }