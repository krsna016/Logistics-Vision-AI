export function getSessionToken() {
  return sessionStorage.getItem('token');
}

export function hasValidSession() {
  const token = getSessionToken();
  if (!token) return false;

  try {
    const encodedPayload = token.split('.')[1];
    if (!encodedPayload) return false;
    const normalized = encodedPayload.replace(/-/g, '+').replace(/_/g, '/');
    const payload = JSON.parse(atob(normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')));
    return typeof payload.exp === 'number' && payload.exp * 1000 > Date.now();
  } catch {
    return false;
  }
}
