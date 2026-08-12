import { useState } from 'react';
import { ArrowRight, Eye, EyeOff, LockKeyhole, ShieldCheck, X } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import api from '../api';
import { hasAdminSession } from '../auth';

export default function Login() {
  const [employeeId, setEmployeeId] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const handleLogin = async e => {
    e.preventDefault(); setLoading(true); setError('');
    try {
      const params = new URLSearchParams({ username: employeeId.trim(), password });
      const res = await api.post('/auth/login', params, { headers: { 'Content-Type': 'application/x-www-form-urlencoded' } });
      sessionStorage.setItem('token', res.data.access_token);
      if (!hasAdminSession()) {
        sessionStorage.removeItem('token');
        setError('Administrator access is required for this console.');
        return;
      }
      navigate('/');
    } catch (err) { setError(err.response?.data?.detail || 'Invalid credentials or inactive account.'); }
    finally { setLoading(false); }
  };
  return <div className="auth-layout">
    <div className="auth-brand-panel"><div className="auth-brand"><div className="brand-mark"><img className="company-logo" src="/company-logo.png" alt="SmartLoad logo" /></div><div><strong>SmartLoad</strong><span>Operations control</span></div></div><div className="auth-hero"><div className="eyebrow"><span className="eyebrow-dot" /> SECURE ADMIN CONSOLE</div><h1>Keep every<br /><em>operation moving.</em></h1><p>One command center for workforce access, device authorization, and operational continuity.</p><div className="auth-feature"><span><ShieldCheck size={17} /></span><div><strong>Enterprise access control</strong><p>Every change is authenticated and applied across connected devices.</p></div></div></div><div className="auth-footer">© {new Date().getFullYear()} SmartLoad <span>•</span> Protected workspace</div></div>
    <main className="auth-form-panel"><div className="auth-form-wrap"><div className="mobile-auth-logo"><div className="brand-mark"><img className="company-logo" src="/company-logo.png" alt="SmartLoad logo" /></div><strong>SmartLoad</strong></div><div className="auth-heading"><div className="auth-icon"><LockKeyhole size={19} /></div><div><div className="section-kicker">ADMINISTRATOR ACCESS</div><h2>Welcome back</h2><p>Sign in to manage your workforce directory.</p></div></div>{error && <div className="alert alert-danger auth-alert"><X size={15} /><span>{error}</span></div>}<form onSubmit={handleLogin} className="auth-form"><label>Administrator ID<input autoFocus value={employeeId} onChange={e => setEmployeeId(e.target.value)} placeholder="e.g. ADMIN-001" autoComplete="username" required /></label><label>Password<div className="password-field"><input type={showPassword ? 'text' : 'password'} value={password} onChange={e => setPassword(e.target.value)} placeholder="Enter your password" autoComplete="current-password" required /><button type="button" onClick={() => setShowPassword(v => !v)} aria-label={showPassword ? 'Hide password' : 'Show password'}>{showPassword ? <EyeOff size={16} /> : <Eye size={16} />}</button></div></label><button className="button button-primary auth-submit" disabled={loading}>{loading ? 'Authenticating…' : <>Sign in securely <ArrowRight size={16} /></>}</button></form><div className="auth-assurance"><ShieldCheck size={15} /><span>Administrator actions are audited and protected by session-based authentication.</span></div></div></main>
  </div>;
}
