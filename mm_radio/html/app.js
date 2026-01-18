const root = document.getElementById('root');
const presetList = document.getElementById('presetList');
const btnClose = document.getElementById('btnClose');
const manualInput = document.getElementById('manualInput');
const btnConnect = document.getElementById('btnConnect');
const btnDisconnect = document.getElementById('btnDisconnect');
const vol = document.getElementById('vol');
const volVal = document.getElementById('volVal');
const statusEl = document.getElementById('status');

let state = {
  presets: [],
  minChannel: 1,
  maxChannel: 9999,
  currentChannel: 0,
  volume: 0.5
};

function nui(eventName, data = {}) {
  fetch(`https://${GetParentResourceName()}/${eventName}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
    body: JSON.stringify(data)
  }).catch(() => {});
}

function setVisible(v) {
  if (v) root.classList.remove('hidden');
  else root.classList.add('hidden');
}

function renderPresets() {
  presetList.innerHTML = '';

  state.presets.forEach(p => {
    const item = document.createElement('div');
    item.className = 'item' + (state.currentChannel === p.channel ? ' active' : '');

    const left = document.createElement('div');
    left.className = 'left';

    const pill = document.createElement('div');
    pill.className = 'pill';

    const label = document.createElement('div');
    label.className = 'label';
    label.textContent = p.label ?? String(p.channel);

    left.appendChild(pill);
    left.appendChild(label);

    const right = document.createElement('div');
    right.className = 'right';
    right.textContent = (state.currentChannel === p.channel) ? 'conectado' : 'entrar';

    item.appendChild(left);
    item.appendChild(right);

    item.addEventListener('click', () => {
      nui('connect', { channel: p.channel });
    });

    presetList.appendChild(item);
  });
}

function applyState() {
  const v = Math.round((state.volume ?? 0.5) * 100);
  vol.value = String(v);
  volVal.textContent = String(v);

  if ((state.currentChannel ?? 0) > 0) {
    statusEl.textContent = `Conectado: ${state.currentChannel}`;
    statusEl.classList.add('on');
  } else {
    statusEl.textContent = 'Desconectado';
    statusEl.classList.remove('on');
  }

  renderPresets();
}

btnClose.addEventListener('click', () => nui('close'));
btnDisconnect.addEventListener('click', () => nui('disconnect'));

btnConnect.addEventListener('click', () => {
  const ch = Number(manualInput.value || 0);
  if (!ch) return;

  const clamped = Math.min(state.maxChannel, Math.max(state.minChannel, ch));
  manualInput.value = String(clamped);
  nui('connect', { channel: clamped });
});

vol.addEventListener('input', () => {
  const v = Number(vol.value) / 100.0;
  volVal.textContent = String(vol.value);
  nui('setVolume', { volume: v });
});

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') nui('close');
});

window.addEventListener('message', (event) => {
  const data = event.data;
  if (!data || !data.action) return;

  if (data.action === 'open') {
    state.presets = data.presets || [];
    state.minChannel = data.minChannel ?? 1;
    state.maxChannel = data.maxChannel ?? 9999;
    state.currentChannel = data.currentChannel ?? 0;
    state.volume = data.volume ?? 0.5;

    setVisible(true);
    applyState();
  }

  if (data.action === 'close') {
    setVisible(false);
  }

  if (data.action === 'state') {
    state.currentChannel = data.currentChannel ?? state.currentChannel;
    state.volume = data.volume ?? state.volume;
    applyState();
  }
});
