const $ = (id) => document.getElementById(id);
let selectedFile = null;
let sourceImage = null;
let lastResult = null;
let zoomLevel = 0;
let verificationPoints = [];
let verificationMode = false;
let availableModels = [];

const COLORS = ['#38e6b1', '#42b9ff', '#ffc34d', '#c783ff', '#ff6e8d', '#61e6e6'];

async function checkHealth() {
  const status = $('modelStatus');
  try {
    const response = await fetch('/api/health');
    const health = await response.json();
    status.className = health.status === 'ready' ? 'status ready' : 'status bad';
    status.innerHTML = health.status === 'ready' ? `<span></span>${health.model} ready · ${health.model_size_mb} MB` : '<span></span>Carton model missing';
  } catch (_) {
    status.className = 'status bad'; status.innerHTML = '<span></span>App backend unavailable';
  }
}

async function loadModels(preferredId = '') {
  const response = await fetch('/api/models'); const models = await response.json();
  if (!response.ok) throw new Error(models.detail || 'Could not load the model library.');
  availableModels = models; const select = $('modelSelect'); const previous = preferredId || select.value;
  select.innerHTML = models.map((model) => `<option value="${model.id}">${model.name}${model.default ? ' · default' : ''} · ${model.size_mb} MB</option>`).join('');
  select.value = models.some((model) => model.id === previous) ? previous : (models.find((model) => model.default)?.id || models[0]?.id || '');
}

async function uploadModel(file) {
  if (!file || !file.name.toLowerCase().endsWith('.pt')) { $('modelUploadStatus').textContent = 'Please choose a trusted .pt checkpoint.'; return; }
  $('modelUploadStatus').className = 'model-upload-status loading'; $('modelUploadStatus').textContent = `Validating ${file.name}… this may take a moment.`;
  const form = new FormData(); form.append('model', file);
  try {
    const response = await fetch('/api/models', { method: 'POST', body: form }); const body = await response.json();
    if (!response.ok) throw new Error(body.detail || 'Model upload failed.');
    await loadModels(body.id); invalidateResult(); $('modelUploadStatus').className = 'model-upload-status success'; $('modelUploadStatus').textContent = `${body.name} is ready · ${body.task} · ${body.size_mb} MB`;
  } catch (error) { $('modelUploadStatus').className = 'model-upload-status error-text'; $('modelUploadStatus').textContent = error.message; }
}

function invalidateResult() {
  lastResult = null; verificationPoints = []; verificationMode = false; updateMarkerControls();
  $('metrics').hidden = true; $('resultFooter').hidden = true; $('resultCanvas').hidden = true; $('resultPlaceholder').hidden = false; $('downloadButton').disabled = true; $('verificationTools').hidden = true;
  if (sourceImage) { renderOriginalCanvas(); setView('original'); }
  $('activeRunModel').textContent = availableModels.find((model) => model.id === $('modelSelect').value)?.name || $('modelSelect').value || 'No model';
}

function chooseFile(file) {
  if (!file || !['image/jpeg', 'image/png', 'image/webp'].includes(file.type)) return showError('Please choose a JPEG, PNG, or WebP image.');
  selectedFile = file; lastResult = null; zoomLevel = 0; verificationPoints = []; verificationMode = false;
  const url = URL.createObjectURL(file);
  sourceImage = new Image();
  sourceImage.onload = () => {
    renderOriginalCanvas(); updateMarkerControls();
    $('imageThumb').src = url;
    $('fileName').textContent = file.name;
    $('imageMeta').textContent = `${sourceImage.naturalWidth} × ${sourceImage.naturalHeight} px · ${(file.size / 1024 / 1024).toFixed(2)} MB`;
    $('welcomePanel').hidden = true; $('inspectionPanel').hidden = false; $('rightbar').hidden = false; $('metrics').hidden = true; $('resultFooter').hidden = true;
    $('resultCanvas').hidden = true; $('resultPlaceholder').hidden = false; $('downloadButton').disabled = true;
    $('activeRunModel').textContent = availableModels.find((model) => model.id === $('modelSelect').value)?.name || $('modelSelect').value || 'No model';
    setView('original'); showError(''); updateZoom();
    $('inspectionPanel').scrollIntoView({ behavior: 'smooth', block: 'start' });
  };
  sourceImage.src = url;
}

function showError(message) { $('error').hidden = !message; $('error').textContent = message; }

async function run() {
  if (!selectedFile) return;
  const button = $('runButton'); button.disabled = true; button.querySelector('span').textContent = 'Inspecting cartons…'; showError('');
  const form = new FormData();
  form.append('image', selectedFile); form.append('model_id', $('modelSelect').value); form.append('confidence', $('confidence').value); form.append('iou', $('iou').value); form.append('image_size', $('imageSize').value); form.append('ground_truth', $('truth').value);
  try {
    const response = await fetch('/api/count', { method: 'POST', body: form });
    const body = await response.json(); if (!response.ok) throw new Error(body.detail || 'The model could not process this image.');
    lastResult = body; renderOriginalCanvas(); renderCanvas();
    $('count').textContent = body.predicted_count; $('avgConfidence').textContent = `${(body.average_confidence * 100).toFixed(1)}%`; $('time').textContent = `${body.elapsed_ms} ms`;
    $('accuracy').textContent = body.exact === null ? 'Not scored' : body.exact ? 'Exact match ✓' : `${body.count_error > 0 ? '+' : ''}${body.count_error} cartons`;
    $('resultSummary').textContent = `${body.model_name} · ${body.predicted_count} instances · confidence ≥ ${body.parameters.confidence.toFixed(2)} · ${body.parameters.image_size}px`;
    $('metrics').hidden = false; $('resultFooter').hidden = false; $('resultPlaceholder').hidden = true; $('resultCanvas').hidden = false; $('downloadButton').disabled = false;
    setView('annotated'); fitImage();
  } catch (error) { showError(error.message); }
  finally { button.disabled = false; button.querySelector('span').textContent = 'Run carton model'; }
}

function renderCanvas() {
  if (!lastResult || !sourceImage) return;
  const canvas = $('resultCanvas'); const ctx = canvas.getContext('2d');
  canvas.width = sourceImage.naturalWidth; canvas.height = sourceImage.naturalHeight;
  ctx.drawImage(sourceImage, 0, 0, canvas.width, canvas.height);
  const scale = Math.min(canvas.width, canvas.height);
  const lineWidth = Math.max(3, Math.round(scale / 300));
  const fontSize = Math.max(16, Math.round(scale / 38));
  const opacity = Number($('maskOpacity').value) / 100;
  lastResult.detections.forEach((detection, index) => {
    const color = COLORS[index % COLORS.length]; const [x1, y1, x2, y2] = detection.box;
    if ($('showMasks').checked && detection.polygon?.length >= 3) {
      ctx.beginPath(); detection.polygon.forEach(([x, y], pointIndex) => pointIndex ? ctx.lineTo(x, y) : ctx.moveTo(x, y)); ctx.closePath();
      ctx.globalAlpha = opacity; ctx.fillStyle = color; ctx.fill(); ctx.globalAlpha = 1; ctx.strokeStyle = color; ctx.lineWidth = lineWidth; ctx.stroke();
    }
    if ($('showBoxes').checked) { ctx.strokeStyle = color; ctx.lineWidth = lineWidth; ctx.strokeRect(x1, y1, x2 - x1, y2 - y1); }
    if ($('showNumbers').checked) {
      const radius = Math.max(15, fontSize * .78); const cx = Math.max(radius + 3, Math.min(canvas.width - radius - 3, x1 + radius)); const cy = Math.max(radius + 3, Math.min(canvas.height - radius - 3, y1 + radius));
      ctx.beginPath(); ctx.arc(cx, cy, radius, 0, Math.PI * 2); ctx.fillStyle = '#06171d'; ctx.fill(); ctx.strokeStyle = color; ctx.lineWidth = Math.max(2, lineWidth); ctx.stroke();
      ctx.fillStyle = '#fff'; ctx.font = `800 ${fontSize}px system-ui`; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillText(detection.number, cx, cy + 1);
    }
    if ($('showConfidence').checked) {
      const text = `${Math.round(detection.confidence * 100)}%`; ctx.font = `700 ${Math.max(13, fontSize * .62)}px system-ui`; const width = ctx.measureText(text).width + 12;
      const tx = Math.min(canvas.width - width - 2, x1); const ty = Math.max(2, y2 - fontSize);
      ctx.fillStyle = 'rgba(3,18,24,.88)'; ctx.fillRect(tx, ty, width, fontSize); ctx.fillStyle = '#fff'; ctx.textAlign = 'left'; ctx.textBaseline = 'middle'; ctx.fillText(text, tx + 6, ty + fontSize / 2);
    }
  });
  drawVerificationMarks(ctx, canvas);
}

function renderOriginalCanvas() {
  if (!sourceImage?.naturalWidth) return;
  const canvas = $('originalCanvas'); const ctx = canvas.getContext('2d');
  canvas.width = sourceImage.naturalWidth; canvas.height = sourceImage.naturalHeight;
  ctx.drawImage(sourceImage, 0, 0, canvas.width, canvas.height);
  drawVerificationMarks(ctx, canvas);
}

function drawVerificationMarks(ctx, canvas) {
  const scale = Math.min(canvas.width, canvas.height);
  const radius = Math.max(17, Math.round(scale / 34));
  verificationPoints.forEach((point, index) => {
    const x = point.x * canvas.width; const y = point.y * canvas.height;
    ctx.save(); ctx.beginPath(); ctx.arc(x, y, radius, 0, Math.PI * 2); ctx.fillStyle = 'rgba(4, 43, 32, .90)'; ctx.fill(); ctx.strokeStyle = '#64f0b8'; ctx.lineWidth = Math.max(3, radius * .16); ctx.stroke();
    ctx.strokeStyle = '#fff'; ctx.lineWidth = Math.max(3, radius * .16); ctx.lineCap = 'round'; ctx.lineJoin = 'round'; ctx.beginPath(); ctx.moveTo(x - radius * .43, y); ctx.lineTo(x - radius * .10, y + radius * .30); ctx.lineTo(x + radius * .48, y - radius * .38); ctx.stroke();
    ctx.font = `800 ${Math.max(11, radius * .55)}px system-ui`; ctx.textAlign = 'center'; ctx.textBaseline = 'middle'; ctx.fillStyle = '#06251d'; ctx.beginPath(); ctx.arc(x + radius * .72, y - radius * .72, radius * .42, 0, Math.PI * 2); ctx.fillStyle = '#64f0b8'; ctx.fill(); ctx.fillStyle = '#06251d'; ctx.fillText(String(index + 1), x + radius * .72, y - radius * .70); ctx.restore();
  });
}

function updateMarkerControls() {
  $('markerCount').textContent = verificationPoints.length;
  $('undoMarker').disabled = verificationPoints.length === 0; $('clearMarkers').disabled = verificationPoints.length === 0;
  $('verificationToggle').classList.toggle('active', verificationMode); $('verificationToggle').textContent = verificationMode ? '✓ Verification on' : 'Verification paused'; $('viewer').classList.toggle('verify-mode', verificationMode);
}

function setView(view) {
  $('viewer').className = `viewer ${view}-view`;
  if (view === 'compare' && lastResult) verificationMode = true;
  if (verificationMode) $('viewer').classList.add('verify-mode');
  document.querySelectorAll('.view-tabs button').forEach((button) => button.classList.toggle('active', button.dataset.view === view));
  $('verificationTools').hidden = !(view === 'compare' && lastResult);
  updateMarkerControls();
}

function fitImage() { zoomLevel = 0; updateZoom(); }
function updateZoom() {
  const canv = $('resultCanvas'); const original = $('originalCanvas');
  canv.style.width = ''; original.style.width = ''; $('viewer').scrollTo({ left: 0, top: 0 });
}
function downloadResult() { if (!lastResult) return; const link = document.createElement('a'); link.download = `${selectedFile.name.replace(/\.[^.]+$/, '')}-numbered-cartons.jpg`; link.href = $('resultCanvas').toDataURL('image/jpeg', .94); link.click(); }
function toggleVerificationAt(event) {
  if (!verificationMode || !lastResult) return;
  event.preventDefault();
  const rect = event.currentTarget.getBoundingClientRect();
  const x = Math.max(0, Math.min(1, (event.clientX - rect.left) / rect.width));
  const y = Math.max(0, Math.min(1, (event.clientY - rect.top) / rect.height));
  let nearestIndex = -1; let nearestDistance = Infinity;
  verificationPoints.forEach((point, index) => {
    const distance = Math.hypot((point.x - x) * rect.width, (point.y - y) * rect.height);
    if (distance < nearestDistance) { nearestDistance = distance; nearestIndex = index; }
  });
  if (nearestIndex >= 0 && nearestDistance <= 34) verificationPoints.splice(nearestIndex, 1);
  else verificationPoints.push({ x, y });
  renderOriginalCanvas(); renderCanvas(); updateMarkerControls();
}
function exportReview() {
  if (!lastResult) return;
  const report = { image: selectedFile.name, reviewed_at: new Date().toISOString(), model_id: lastResult.model_id, model_name: lastResult.model_name, predicted_cartons: lastResult.predicted_count, average_confidence: lastResult.average_confidence, inference_ms: lastResult.elapsed_ms, model_parameters: lastResult.parameters, manual_verification_marks: verificationPoints.map((point, index) => ({ number: index + 1, x_normalized: Number(point.x.toFixed(6)), y_normalized: Number(point.y.toFixed(6)) })) };
  const url = URL.createObjectURL(new Blob([JSON.stringify(report, null, 2)], { type: 'application/json' })); const link = document.createElement('a'); link.href = url; link.download = `${selectedFile.name.replace(/\.[^.]+$/, '')}-verification-report.json`; link.click(); URL.revokeObjectURL(url);
}

const drop = $('dropZone');
const modelDrop = $('modelDrop');
drop.addEventListener('click', () => $('fileInput').click());
drop.addEventListener('keydown', (event) => { if (event.key === 'Enter' || event.key === ' ') $('fileInput').click(); });
drop.addEventListener('dragover', (event) => { event.preventDefault(); drop.classList.add('dragging'); });
drop.addEventListener('dragleave', () => drop.classList.remove('dragging'));
drop.addEventListener('drop', (event) => { event.preventDefault(); drop.classList.remove('dragging'); chooseFile(event.dataTransfer.files[0]); });
$('fileInput').addEventListener('change', (event) => chooseFile(event.target.files[0]));
$('welcomeBrowse').addEventListener('click', () => $('fileInput').click());
$('modelSelect').addEventListener('change', invalidateResult);
modelDrop.addEventListener('click', () => $('modelFileInput').click()); modelDrop.addEventListener('keydown', (event) => { if (event.key === 'Enter' || event.key === ' ') $('modelFileInput').click(); });
modelDrop.addEventListener('dragover', (event) => { event.preventDefault(); modelDrop.classList.add('dragging'); }); modelDrop.addEventListener('dragleave', () => modelDrop.classList.remove('dragging'));
modelDrop.addEventListener('drop', (event) => { event.preventDefault(); modelDrop.classList.remove('dragging'); uploadModel(event.dataTransfer.files[0]); });
$('modelFileInput').addEventListener('change', (event) => { uploadModel(event.target.files[0]); event.target.value = ''; });
$('runButton').addEventListener('click', run);
document.addEventListener('keydown', (event) => { if ((event.metaKey || event.ctrlKey) && event.key === 'Enter') run(); });
['confidence', 'iou'].forEach((id) => $(id).addEventListener('input', () => $(`${id}Value`).textContent = Number($(id).value).toFixed(2)));
$('maskOpacity').addEventListener('input', () => { $('opacityValue').textContent = `${$('maskOpacity').value}%`; renderCanvas(); });
['showMasks', 'showBoxes', 'showNumbers', 'showConfidence'].forEach((id) => $(id).addEventListener('change', renderCanvas));
document.querySelectorAll('.view-tabs button').forEach((button) => button.addEventListener('click', () => setView(button.dataset.view)));
$('fullscreenButton').addEventListener('click', () => $('viewer').requestFullscreen?.()); $('downloadButton').addEventListener('click', downloadResult);
$('verificationToggle').addEventListener('click', () => { verificationMode = !verificationMode; if (verificationMode) setView('compare'); updateMarkerControls(); });
$('originalCanvas').addEventListener('click', toggleVerificationAt);
$('resultCanvas').addEventListener('click', toggleVerificationAt);
$('undoMarker').addEventListener('click', () => { verificationPoints.pop(); renderOriginalCanvas(); renderCanvas(); updateMarkerControls(); });
$('clearMarkers').addEventListener('click', () => { verificationPoints = []; renderOriginalCanvas(); renderCanvas(); updateMarkerControls(); });
$('exportReview').addEventListener('click', exportReview);
function setDocs(open) { $('docsModal').hidden = !open; document.body.classList.toggle('modal-open', open); }
$('openDocs').addEventListener('click', () => setDocs(true));
$('closeDocs').addEventListener('click', () => setDocs(false));
document.querySelector('[data-close-docs]').addEventListener('click', () => setDocs(false));
document.addEventListener('keydown', (event) => { if (event.key === 'Escape' && !$('docsModal').hidden) setDocs(false); });
checkHealth(); loadModels().catch((error) => { $('modelUploadStatus').className = 'model-upload-status error-text'; $('modelUploadStatus').textContent = error.message; });
