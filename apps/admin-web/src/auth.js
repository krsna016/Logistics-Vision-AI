export function getSessionToken() {
  return sessionStorage.getItem('token');
}

export function getSessionClaims() {
  const token = getSessionToken();
  if (!token) return null;

  try {
  const encodedPayload = token.split('.')[1];
  if (!encodedPayload) return null;
    const normalized = encodedPayload.replace(/-/g, '+').replace(/_/g, '/');
    const payload = JSON.parse(atob(normalized.padEnd(Math.ceil(normalized.length / 4) * 4, '=')));
    return payload;
  } catch {
    return null;
  }
}

export function hasValidSession() {
  const claims = getSessionClaims();
  return claims !== null &&
    typeof claims.exp === 'number' && claims.exp * 1000 > Date.now();
}

export function hasAdminSession() {
  const claims = getSessionClaims();
  return hasValidSession() && claims?.role === 'Administrator';
}
