import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, ShieldCheck, Activity, ArrowLeft, CheckCircle2 } from 'lucide-react';
import api from '../api';

export default function CreateUser() {
  const [formData, setFormData] = useState({
    employee_id: '',
    name: '',
    role: 'Operator',
    password: ''
  });
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [successData, setSuccessData] = useState(null);
  const navigate = useNavigate();

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');
    
    try {
      await api.post('/users/', formData);
      setSuccessData({
        employee_id: formData.employee_id,
        password: formData.password
      });
    } catch (err) {
      setError(err.response?.data?.detail || 'Failed to create user');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app-layout">
      {/* SIDEBAR */}
      <aside className="app-sidebar">
        <div style={{ padding: '24px', borderBottom: 'none', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '40px', height: '40px', background: 'rgba(255,255,255,0.1)', borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Activity color="var(--primary)" />
          </div>
          <div>
            <h2 style={{ margin: 0, fontSize: '16px', color: 'white' }}>SmartLoad</h2>
            <p style={{ margin: 0, fontSize: '11px', color: 'var(--text-muted)' }}>Admin Portal</p>
          </div>
        </div>
        
        <nav style={{ padding: '24px 12px', flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <button 
            onClick={() => navigate('/')}
            style={{ background: 'var(--primary)', color: 'white', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', fontWeight: '500', textAlign: 'left' }}>
            <Users size={18} /> User Management
          </button>
          <button style={{ background: 'transparent', color: 'var(--text-muted)', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', fontWeight: '500', textAlign: 'left' }} onClick={() => alert('Audit Logs coming soon!')}>
            <ShieldCheck size={18} /> System Audit
          </button>
        </nav>
      </aside>

      <main className="app-content animate-fade-in" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ width: '100%', maxWidth: '600px', display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '32px' }}>
          <button 
            onClick={() => navigate('/')}
            className="premium-button secondary"
            style={{ padding: '8px 12px' }}
          >
            <ArrowLeft size={16} /> Back
          </button>
          <div>
            <h1 style={{ margin: 0, color: 'white', fontSize: '28px' }}>Create New User</h1>
            <p style={{ margin: '4px 0 0', color: 'var(--text-muted)' }}>Generate credentials for a new warehouse worker</p>
          </div>
        </div>

        <div className="premium-card animate-fade-in" style={{ width: '100%', maxWidth: '600px' }}>
          {error && (
            <div style={{ background: 'rgba(239, 68, 68, 0.15)', border: 'none', color: 'var(--danger)', padding: '12px', borderRadius: '12px', marginBottom: '20px' }}>
              {error}
            </div>
          )}

          {successData ? (
            <div style={{ textAlign: 'center', padding: '20px 0' }}>
              <div style={{ width: '64px', height: '64px', background: 'rgba(16, 185, 129, 0.1)', color: 'var(--success)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 24px' }}>
                <CheckCircle2 size={32} />
              </div>
              <h2 style={{ color: 'white', marginBottom: '16px' }}>User Created Successfully!</h2>
              <p style={{ color: 'var(--text-muted)', marginBottom: '32px' }}>
                Please copy these credentials and share them securely with the worker. <br/>
                <strong>You will not be able to see this password again.</strong>
              </p>
              
              <div style={{ background: 'rgba(0,0,0,0.25)', padding: '24px', borderRadius: '16px', textAlign: 'left', marginBottom: '32px', border: 'none', boxShadow: 'inset 0 2px 8px rgba(0,0,0,0.2)' }}>
                <div style={{ marginBottom: '16px' }}>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '4px' }}>Employee ID</div>
                  <div style={{ color: 'white', fontSize: '20px', fontFamily: 'monospace' }}>{successData.employee_id}</div>
                </div>
                <div>
                  <div style={{ fontSize: '12px', color: 'var(--text-muted)', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '4px' }}>Temporary Password</div>
                  <div style={{ color: 'var(--primary)', fontSize: '20px', fontFamily: 'monospace' }}>{successData.password}</div>
                </div>
              </div>
              
              <button 
                onClick={() => navigate('/')}
                className="premium-button" 
                style={{ width: '100%', justifyContent: 'center', padding: '14px' }}
              >
                Return to Dashboard
              </button>
            </div>
          ) : (
            <form onSubmit={handleSubmit}>
              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>Employee ID (Required for login)</label>
                <input 
                  name="employee_id"
                  className="premium-input" 
                  placeholder="e.g. OP-105"
                  value={formData.employee_id}
                  onChange={handleChange}
                  required
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>Full Name</label>
                <input 
                  name="name"
                  className="premium-input" 
                  placeholder="John Doe"
                  value={formData.name}
                  onChange={handleChange}
                  required
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>Role Privilege</label>
                <select 
                  name="role"
                  className="premium-input"
                  value={formData.role}
                  onChange={handleChange}
                >
                  <option value="Operator">Operator (Standard)</option>
                  <option value="Supervisor">Supervisor</option>
                  <option value="Manager">Warehouse Manager</option>
                  <option value="Admin">System Admin</option>
                </select>
              </div>

              <div style={{ marginBottom: '32px' }}>
                <label style={{ display: 'block', marginBottom: '8px', color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>Temporary Password</label>
                <input 
                  name="password"
                  type="password"
                  className="premium-input" 
                  placeholder="Enter a secure password"
                  value={formData.password}
                  onChange={handleChange}
                  required
                />
              </div>

              <button type="submit" className="premium-button" style={{ width: '100%', justifyContent: 'center', padding: '14px' }} disabled={loading}>
                {loading ? 'Creating Account...' : 'Create User & Generate Access'}
              </button>
            </form>
          )}
        </div>
      </main>
    </div>
  );
}
