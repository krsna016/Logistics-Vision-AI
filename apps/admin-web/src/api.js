import axios from 'axios';
import { getSessionToken, hasValidSession } from './auth';

const api = axios.create({
  // Use an explicit override for local/staging environments; hosted Admin
  // builds must default to the deployed API instead of a visitor's localhost.
  baseURL: import.meta.env.VITE_API_BASE_URL || 'https://logistics-vision-ai.onrender.com/api',
});

api.interceptors.request.use((config) => {
  const token = getSessionToken();
  if (token && hasValidSession()) {
    config.headers.Authorization = `Bearer ${token}`;
  } else if (token) {
    sessionStorage.removeItem('token');
  }
  return config;
});

export default api;
