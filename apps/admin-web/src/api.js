import axios from 'axios';
import { getSessionToken, hasValidSession } from './auth';

const api = axios.create({
  // Use Vercel environment variable for production, fallback to localhost for local dev
  baseURL: import.meta.env.VITE_API_BASE_URL || 'http://127.0.0.1:8000/api', 
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
