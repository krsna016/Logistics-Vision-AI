import { useState, useEffect, useMemo } from 'react';
import { useNavigate } from 'react-router-dom';
import { Users, UserCheck, ShieldCheck, ShieldAlert, LogOut, Plus, Search, Filter, RefreshCcw, Activity } from 'lucide-react';
import api from '../api';

export default function Dashboard() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('All');
  
  const navigate = useNavigate();

  const fetchUsers = async () => {
    try {
      const res = await api.get('/users/');
      setUsers(res.data);
    } catch (err) {
      if (err.response?.status === 401) {
        navigate('/login');
      }
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const disableUser = async (employeeId) => {
    if (!window.confirm(`Are you sure you want to disable ${employeeId}? They will be immediately logged out.`)) return;
    try {
      await api.delete(`/users/${employeeId}`);
      fetchUsers();
    } catch (err) {
      alert('Failed to disable user');
    }
  };

  const activateUser = async (employeeId) => {
    if (!window.confirm(`Are you sure you want to re-activate ${employeeId}?`)) return;
    try {
      await api.post(`/users/${employeeId}/activate`);
      fetchUsers();
    } catch (err) {
      alert('Failed to activate user');
    }
  };

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  // Derived State (Metrics)
  const metrics = useMemo(() => {
    const active = users.filter(u => u.is_active);
    return {
      total: users.length,
      activeCount: active.length,
      adminCount: active.filter(u => u.role === 'Admin' || u.role === 'Manager').length,
    };
  }, [users]);

  // Derived State (Filtered Users)
  const filteredUsers = useMemo(() => {
    return users.filter(user => {
      const matchesSearch = user.name.toLowerCase().includes(search.toLowerCase()) || 
                            user.employee_id.toLowerCase().includes(search.toLowerCase());
      const matchesRole = roleFilter === 'All' || user.role === roleFilter;
      return matchesSearch && matchesRole;
    });
  }, [users, search, roleFilter]);

  return (
    <div className="app-layout">
      {/* SIDEBAR */}
      <aside className="app-sidebar">
        <div style={{ padding: '24px', borderBottom: '1px solid var(--border-color)', display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '40px', height: '40px', background: 'rgba(255,255,255,0.1)', borderRadius: '10px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Activity color="var(--primary)" />
          </div>
          <div>
            <h2 style={{ margin: 0, fontSize: '16px', color: 'white' }}>SmartLoad</h2>
            <p style={{ margin: 0, fontSize: '11px', color: 'var(--text-muted)' }}>Admin Portal</p>
          </div>
        </div>
        
        <nav style={{ padding: '24px 12px', flex: 1, display: 'flex', flexDirection: 'column', gap: '8px' }}>
          <button style={{ background: 'var(--primary)', color: 'white', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', fontWeight: '500', textAlign: 'left' }}>
            <Users size={18} /> User Management
          </button>
          <button style={{ background: 'transparent', color: 'var(--text-muted)', padding: '12px 16px', borderRadius: '8px', display: 'flex', alignItems: 'center', gap: '12px', fontSize: '14px', fontWeight: '500', textAlign: 'left' }} onClick={() => alert('Audit Logs coming soon!')}>
            <ShieldCheck size={18} /> System Audit
          </button>
        </nav>

        <div style={{ padding: '24px' }}>
          <button className="premium-button danger" style={{ width: '100%', padding: '12px' }} onClick={handleLogout}>
            <LogOut size={16} /> Logout
          </button>
        </div>
      </aside>

      {/* MAIN CONTENT */}
      <main className="app-content animate-fade-in">
        
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '32px' }}>
          <div>
            <h1 style={{ margin: 0, color: 'white', fontSize: '28px' }}>User Management</h1>
            <p style={{ margin: '8px 0 0', color: 'var(--text-muted)' }}>Control access and roles across the organization</p>
          </div>
          <button className="premium-button" onClick={() => navigate('/create-user')}>
            <Plus size={18} /> Add New User
          </button>
        </div>

        {/* METRICS */}
        <div className="metrics-grid">
          <div className="premium-card metric-card">
            <div className="metric-icon" style={{ background: 'rgba(59, 130, 246, 0.1)' }}>
              <Users color="#3B82F6" size={24} />
            </div>
            <div>
              <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '13px' }}>Total Registered</p>
              <h2 style={{ margin: '4px 0 0', color: 'white', fontSize: '24px' }}>{metrics.total}</h2>
            </div>
          </div>
          <div className="premium-card metric-card">
            <div className="metric-icon" style={{ background: 'rgba(16, 185, 129, 0.1)' }}>
              <UserCheck color="var(--success)" size={24} />
            </div>
            <div>
              <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '13px' }}>Active Staff</p>
              <h2 style={{ margin: '4px 0 0', color: 'white', fontSize: '24px' }}>{metrics.activeCount}</h2>
            </div>
          </div>
          <div className="premium-card metric-card">
            <div className="metric-icon" style={{ background: 'rgba(139, 92, 246, 0.1)' }}>
              <ShieldCheck color="#8B5CF6" size={24} />
            </div>
            <div>
              <p style={{ margin: 0, color: 'var(--text-muted)', fontSize: '13px' }}>Privileged Accounts</p>
              <h2 style={{ margin: '4px 0 0', color: 'white', fontSize: '24px' }}>{metrics.adminCount}</h2>
            </div>
          </div>
        </div>

        {/* TABLE SECTION */}
        <div className="premium-card" style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{ padding: '20px 24px', borderBottom: '1px solid var(--border-color)', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
            <div style={{ flex: 1, minWidth: '240px', position: 'relative' }}>
              <Search color="var(--text-muted)" size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
              <input 
                className="premium-input" 
                placeholder="Search by ID or Name..." 
                style={{ paddingLeft: '40px' }}
                value={search}
                onChange={e => setSearch(e.target.value)}
              />
            </div>
            <div style={{ width: '200px', position: 'relative' }}>
              <Filter color="var(--text-muted)" size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)' }} />
              <select 
                className="premium-input" 
                style={{ paddingLeft: '40px', appearance: 'none' }}
                value={roleFilter}
                onChange={e => setRoleFilter(e.target.value)}
              >
                <option value="All">All Roles</option>
                <option value="Admin">Admin</option>
                <option value="Manager">Manager</option>
                <option value="Operator">Operator</option>
              </select>
            </div>
          </div>

          <div className="table-container" style={{ border: 'none', borderRadius: 0 }}>
            {loading ? (
              <div style={{ padding: '48px', textAlign: 'center', color: 'var(--text-muted)' }}>Loading users...</div>
            ) : filteredUsers.length === 0 ? (
              <div style={{ padding: '48px', textAlign: 'center', color: 'var(--text-muted)' }}>
                <ShieldAlert size={48} style={{ margin: '0 auto 16px', opacity: 0.5 }} />
                No users match your filters.
              </div>
            ) : (
              <table className="premium-table">
                <thead>
                  <tr>
                    <th>Employee ID</th>
                    <th>Full Name</th>
                    <th>Role Privilege</th>
                    <th>Status</th>
                    <th style={{ textAlign: 'right' }}>Access Control</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.map(user => (
                    <tr key={user.id}>
                      <td style={{ fontFamily: 'monospace', color: 'var(--text-main)' }}>{user.employee_id}</td>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                          <div style={{ width: '32px', height: '32px', background: 'rgba(255,255,255,0.05)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '12px', fontWeight: 'bold' }}>
                            {user.name.charAt(0).toUpperCase()}
                          </div>
                          {user.name}
                        </div>
                      </td>
                      <td style={{ color: 'var(--text-muted)' }}>{user.role}</td>
                      <td>
                        <span className={`status-badge ${user.is_active ? 'active' : 'inactive'}`}>
                          {user.is_active ? 'Active' : 'Disabled'}
                        </span>
                      </td>
                      <td style={{ textAlign: 'right' }}>
                        {user.is_active ? (
                          <button 
                            className="premium-button danger" 
                            style={{ padding: '6px 12px', fontSize: '12px', display: 'inline-flex' }}
                            onClick={() => disableUser(user.employee_id)}
                          >
                            Disable
                          </button>
                        ) : (
                          <button 
                            className="premium-button success" 
                            style={{ padding: '6px 12px', fontSize: '12px', display: 'inline-flex' }}
                            onClick={() => activateUser(user.employee_id)}
                          >
                            <RefreshCcw size={12} /> Activate
                          </button>
                        )}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
        </div>
      </main>
    </div>
  );
}
