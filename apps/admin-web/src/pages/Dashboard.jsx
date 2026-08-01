import { useState, useEffect, useMemo, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Check, CheckCircle2, ChevronDown, Copy, Filter, LayoutGrid, List,
  LogOut, Plus, RefreshCcw, Search, ShieldAlert, ShieldCheck, Trash2, UserCheck,
  Users, UserX, X, MapPin
} from 'lucide-react';
import api from '../api';
import LiveLocationMap from '../components/LiveLocationMap';

const roleOptions = ['All', 'Admin', 'Manager', 'Supervisor', 'Operator'];

function AppShell({ children, onLogout, active = 'users' }) {
  const navigate = useNavigate();
  return (
    <div className="app-layout">
      <aside className="app-sidebar">
        <div className="brand-lockup">
          <div className="brand-mark"><img className="company-logo" src="/company-logo.png" alt="SmartLoad logo" /></div>
          <div><h2>SmartLoad</h2><p>Operations control</p></div>
        </div>
        <div className="workspace-label">WORKSPACE</div>
        <nav className="sidebar-nav" aria-label="Primary navigation">
          <button className={`nav-button ${active === 'users' ? 'active' : ''}`} onClick={() => navigate('/')}>
            <Users size={17} /> User management
          </button>
        </nav>
        <div className="sidebar-footer">
          <div className="security-note"><ShieldCheck size={15} /><span>Admin session<br /><strong>Protected</strong></span><span className="online-dot" /></div>
          <button className="logout-link" onClick={onLogout}><LogOut size={15} /> Sign out</button>
        </div>
      </aside>
      <div className="mobile-header">
        <div className="brand-lockup"><div className="brand-mark"><img className="company-logo" src="/company-logo.png" alt="SmartLoad logo" /></div><h2>SmartLoad</h2></div>
        <button className="icon-button" onClick={onLogout} aria-label="Sign out"><LogOut size={17} /></button>
      </div>
      {children}
    </div>
  );
}

function Metric({ icon: Icon, label, value, note, tone }) {
  return <div className={`metric-card metric-${tone}`}>
    <div className="metric-icon"><Icon size={19} /></div>
    <div className="metric-copy"><span>{label}</span><strong>{value}</strong><small>{note}</small></div>
  </div>;
}

function ConfirmDialog({ action, onCancel, onConfirm, loading }) {
  if (!action) return null;
  const isDelete = action.type === 'delete';
  return <div className="modal-backdrop" role="presentation" onMouseDown={onCancel}>
    <section className="confirm-modal" role="dialog" aria-modal="true" aria-labelledby="confirm-title" onMouseDown={e => e.stopPropagation()}>
      <button className="modal-close" onClick={onCancel} aria-label="Close"><X size={17} /></button>
      <div className={`modal-icon ${isDelete ? 'modal-icon-danger' : 'modal-icon-warning'}`}>
        {isDelete ? <Trash2 size={22} /> : <ShieldAlert size={22} />}
      </div>
      <div className="modal-eyebrow">{isDelete ? 'PERMANENT ACTION' : 'ACCESS CONTROL'}</div>
      <h2 id="confirm-title">{isDelete ? 'Delete this user?' : action.active ? 'Revoke access?' : 'Restore access?'}</h2>
      <p>{isDelete
        ? <>This permanently removes <strong>{action.name}</strong> from SmartLoad. This cannot be undone.</>
        : <>{action.active ? <>The user will be signed out of connected mobile devices immediately.</> : <>The user will be allowed to sign in to connected mobile devices again.</>}</>}</p>
      <div className="modal-user"><div className="avatar avatar-small">{action.name?.charAt(0).toUpperCase()}</div><div><strong>{action.name}</strong><span>{action.employeeId} · {action.role}</span></div></div>
      <div className="modal-actions"><button className="button button-secondary" onClick={onCancel} disabled={loading}>Cancel</button><button className={`button ${isDelete || action.active ? 'button-danger' : 'button-success'}`} onClick={onConfirm} disabled={loading}>{loading ? <><RefreshCcw size={15} className="spin" /> Working…</> : isDelete ? 'Delete user' : action.active ? 'Revoke access' : 'Restore access'}</button></div>
    </section>
  </div>;
}

export default function Dashboard() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [lastUpdated, setLastUpdated] = useState(null);
  const [search, setSearch] = useState('');
  const [roleFilter, setRoleFilter] = useState('All');
  const [statusFilter, setStatusFilter] = useState('All');
  const [view, setView] = useState('table');
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const [confirmAction, setConfirmAction] = useState(null);
  const [actionLoading, setActionLoading] = useState(false);
  const [copied, setCopied] = useState('');
  const [liveLocations, setLiveLocations] = useState([]);
  const navigate = useNavigate();

  const fetchUsers = useCallback(async (silent = false) => {
    if (!silent) setRefreshing(true);
    try {
      const res = await api.get('/users/');
      setUsers(Array.isArray(res.data) ? res.data : []);
      setLastUpdated(new Date());
      setError('');
    } catch (err) {
      if (err.response?.status === 401) navigate('/login');
      else setError(err.response?.data?.detail || 'Unable to load the user directory. Check the API connection.');
    } finally { setLoading(false); setRefreshing(false); }
  }, [navigate]);

  useEffect(() => { fetchUsers(); }, [fetchUsers]);
  useEffect(() => { const timer = window.setInterval(() => fetchUsers(true), 10000); return () => window.clearInterval(timer); }, [fetchUsers]);
  useEffect(() => { if (!notice) return; const timer = window.setTimeout(() => setNotice(''), 4500); return () => window.clearTimeout(timer); }, [notice]);
  useEffect(() => {
    let cancelled = false;
    const fetchLocations = async () => {
      try {
        const response = await api.get('/locations/live');
        if (!cancelled) setLiveLocations(Array.isArray(response.data) ? response.data : []);
      } catch (err) {
        if (err.response?.status === 401 && !cancelled) navigate('/login');
      }
    };
    fetchLocations();
    const timer = window.setInterval(fetchLocations, 10000);
    return () => { cancelled = true; window.clearInterval(timer); };
  }, [navigate]);

  const metrics = useMemo(() => {
    const active = users.filter(user => user.is_active);
    return { total: users.length, active: active.length, disabled: users.length - active.length, privileged: active.filter(user => ['Admin', 'Manager'].includes(user.role)).length };
  }, [users]);

  const filteredUsers = useMemo(() => users.filter(user => {
    const query = search.trim().toLowerCase();
    const matchesSearch = !query || `${user.name} ${user.employee_id}`.toLowerCase().includes(query);
    return matchesSearch && (roleFilter === 'All' || user.role === roleFilter) && (statusFilter === 'All' || (statusFilter === 'Active' ? user.is_active : !user.is_active));
  }), [users, search, roleFilter, statusFilter]);

  const runAction = async () => {
    if (!confirmAction) return;
    setActionLoading(true);
    try {
      if (confirmAction.type === 'delete') await api.delete(`/users/${confirmAction.employeeId}/hard`);
      else if (confirmAction.active) await api.delete(`/users/${confirmAction.employeeId}`);
      else await api.post(`/users/${confirmAction.employeeId}/activate`);
      setConfirmAction(null);
      setNotice(confirmAction.type === 'delete' ? 'User permanently deleted.' : confirmAction.active ? 'Access revoked. Mobile sessions will be signed out on their next check.' : 'User access restored.');
      await fetchUsers(true);
    } catch (err) {
      setError(err.response?.data?.detail || `Action failed (${err.response?.status || 'network error'}).`);
    } finally { setActionLoading(false); }
  };

  const copyId = async (id) => {
    try { await navigator.clipboard.writeText(id); setCopied(id); window.setTimeout(() => setCopied(''), 1600); } catch { setError('Copy is not available in this browser.'); }
  };
  const signOut = () => { sessionStorage.removeItem('token'); navigate('/login'); };
  const formatTime = date => date ? date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }) : '—';
  const openAction = (user, type) => setConfirmAction({ type, employeeId: user.employee_id, name: user.name, role: user.role, active: user.is_active });

  return <AppShell onLogout={signOut}>
    <main className="app-content animate-fade-in">
      <header className="page-toolbar">
        <div><div className="eyebrow"><span className="eyebrow-dot" /> ACCESS CONTROL <span> / </span> ADMIN CONSOLE</div><h1>User management</h1><p>Control workforce access across every connected SmartLoad device.</p></div>
        <div className="toolbar-actions"><div className="sync-status"><span className="status-dot" /> Live sync <span className="sync-time">{formatTime(lastUpdated)}</span></div><button className="icon-button" onClick={() => fetchUsers()} disabled={refreshing} title="Refresh directory" aria-label="Refresh directory"><RefreshCcw size={17} className={refreshing ? 'spin' : ''} /></button><button className="button button-primary" onClick={() => navigate('/create-user')}><Plus size={17} /> Add user</button></div>
      </header>

      {error && <div className="alert alert-danger" role="alert"><ShieldAlert size={17} /><span>{error}</span><button onClick={() => setError('')} aria-label="Dismiss error"><X size={16} /></button></div>}
      {notice && <div className="alert alert-success" role="status"><CheckCircle2 size={17} /><span>{notice}</span><button onClick={() => setNotice('')} aria-label="Dismiss notification"><X size={16} /></button></div>}

      <section className="metrics-grid" aria-label="Directory summary">
        <Metric icon={Users} label="Registered users" value={metrics.total} note="All accounts" tone="blue" />
        <Metric icon={UserCheck} label="Active access" value={metrics.active} note="Can sign in now" tone="green" />
        <Metric icon={ShieldCheck} label="Privileged" value={metrics.privileged} note="Admin & manager" tone="purple" />
        <Metric icon={UserX} label="Revoked access" value={metrics.disabled} note="Blocked accounts" tone="red" />
      </section>

      <section className="directory-panel location-panel">
        <div className="directory-heading">
          <div><div className="section-kicker">ADMIN ONLY</div><h2>Live employee locations <span>{liveLocations.length}</span></h2><p>Latest authenticated device positions. Refreshes every 10 seconds.</p></div>
          <MapPin size={22} aria-hidden="true" />
        </div>
        <LiveLocationMap locations={liveLocations} />
        {liveLocations.length === 0 ? <div className="empty-state"><div className="empty-icon"><MapPin size={22} /></div><h3>No active locations</h3><p>No connected employee device has sent a location yet.</p></div> : <div className="table-wrap"><table className="user-table"><thead><tr><th>Employee</th><th>Last update</th><th>Accuracy</th><th>Coordinates</th></tr></thead><tbody>{liveLocations.map(location => <tr key={location.employee_id}><td><div className="user-cell"><div className="avatar">{location.employee_name?.charAt(0).toUpperCase()}</div><div><strong>{location.employee_name}</strong><span className="id-copy">{location.employee_id} · {location.role}</span></div></div></td><td>{new Date(location.recorded_at).toLocaleString()}</td><td>{location.accuracy_meters == null ? '—' : `${Math.round(location.accuracy_meters)} m`}</td><td><a href={`https://www.google.com/maps?q=${location.latitude},${location.longitude}`} target="_blank" rel="noreferrer">{location.latitude.toFixed(6)}, {location.longitude.toFixed(6)}</a></td></tr>)}</tbody></table></div>}
      </section>

      <section className="directory-panel">
        <div className="directory-heading"><div><div className="section-kicker">DIRECTORY</div><h2>Workforce accounts <span>{filteredUsers.length}</span></h2><p>Manage credentials, roles, and device access.</p></div><div className="view-switch" role="group" aria-label="Directory view"><button className={view === 'table' ? 'selected' : ''} onClick={() => setView('table')} aria-label="Table view"><List size={16} /></button><button className={view === 'grid' ? 'selected' : ''} onClick={() => setView('grid')} aria-label="Grid view"><LayoutGrid size={16} /></button></div></div>
        <div className="directory-toolbar">
          <label className="search-field"><Search size={17} /><span className="sr-only">Search users</span><input value={search} onChange={e => setSearch(e.target.value)} placeholder="Search by name or employee ID" /></label>
          <label className="select-field"><Filter size={16} /><span className="sr-only">Filter by role</span><select value={roleFilter} onChange={e => setRoleFilter(e.target.value)}>{roleOptions.map(role => <option key={role} value={role}>{role === 'All' ? 'All roles' : role}</option>)}</select><ChevronDown size={15} /></label>
          <label className="select-field"><span className="sr-only">Filter by status</span><select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}><option value="All">All statuses</option><option value="Active">Active</option><option value="Disabled">Disabled</option></select><ChevronDown size={15} /></label>
          {(search || roleFilter !== 'All' || statusFilter !== 'All') && <button className="clear-filters" onClick={() => { setSearch(''); setRoleFilter('All'); setStatusFilter('All'); }}>Clear filters</button>}
        </div>

        {loading ? <div className="empty-state"><div className="loading-orb"><RefreshCcw size={20} className="spin" /></div><h3>Loading directory</h3><p>Synchronizing account status…</p></div> : filteredUsers.length === 0 ? <div className="empty-state"><div className="empty-icon"><Users size={22} /></div><h3>{users.length ? 'No matching users' : 'No users yet'}</h3><p>{users.length ? 'Try changing your search or filters.' : 'Provision the first workforce account to get started.'}</p>{!users.length && <button className="button button-primary" onClick={() => navigate('/create-user')}><Plus size={16} /> Add first user</button>}</div> : view === 'table' ? <div className="table-wrap"><table className="user-table"><thead><tr><th>User</th><th>Role</th><th>Status</th><th>Created</th><th><span className="sr-only">Actions</span></th></tr></thead><tbody>{filteredUsers.map(user => <tr key={user.id}><td><div className="user-cell"><div className="avatar">{user.name?.charAt(0).toUpperCase()}</div><div><strong>{user.name}</strong><button className="id-copy" onClick={() => copyId(user.employee_id)} title="Copy employee ID">{user.employee_id} {copied === user.employee_id ? <Check size={13} /> : <Copy size={13} />}</button></div></div></td><td><span className={`role-badge role-${user.role.toLowerCase()}`}>{user.role}</span></td><td><span className={`status-badge ${user.is_active ? 'active' : 'inactive'}`}><span className="status-dot" />{user.is_active ? 'Active' : 'Access revoked'}</span></td><td className="date-cell">{user.created_at ? new Date(user.created_at).toLocaleDateString() : '—'}</td><td><div className="row-actions"><button className={`text-action ${user.is_active ? 'danger' : 'success'}`} onClick={() => openAction(user, 'access')}>{user.is_active ? 'Revoke' : 'Restore'}</button><button className="icon-button danger" onClick={() => openAction(user, 'delete')} title="Permanently delete user" aria-label={`Delete ${user.name}`}><Trash2 size={16} /></button></div></td></tr>)}</tbody></table></div> : <div className="user-card-grid">{filteredUsers.map(user => <article key={user.id} className={`user-card ${!user.is_active ? 'is-disabled' : ''}`}><div className="user-card-header"><div className="user-cell"><div className="avatar">{user.name?.charAt(0).toUpperCase()}</div><div><strong>{user.name}</strong><button className="id-copy" onClick={() => copyId(user.employee_id)}>{user.employee_id} {copied === user.employee_id ? <Check size={13} /> : <Copy size={13} />}</button></div></div><span className={`status-badge ${user.is_active ? 'active' : 'inactive'}`}><span className="status-dot" />{user.is_active ? 'Active' : 'Revoked'}</span></div><div className="card-meta"><span className={`role-badge role-${user.role.toLowerCase()}`}>{user.role}</span><span>{user.created_at ? new Date(user.created_at).toLocaleDateString() : 'No date'}</span></div><div className="card-actions"><button className={`button button-small ${user.is_active ? 'button-danger' : 'button-success'}`} onClick={() => openAction(user, 'access')}>{user.is_active ? 'Revoke access' : 'Restore access'}</button><button className="icon-button danger" onClick={() => openAction(user, 'delete')} aria-label={`Delete ${user.name}`}><Trash2 size={16} /></button></div></article>)}</div>}
        <div className="directory-footer"><span><span className="online-dot" /> Updates automatically every 10 seconds</span><span>Last checked {formatTime(lastUpdated)}</span></div>
      </section>
    </main>
    <ConfirmDialog action={confirmAction} onCancel={() => !actionLoading && setConfirmAction(null)} onConfirm={runAction} loading={actionLoading} />
  </AppShell>;
}
