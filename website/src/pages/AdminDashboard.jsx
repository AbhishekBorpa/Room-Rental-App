import React, { useState, useEffect } from 'react';
import { 
  BarChart3, Users, Home, Calendar, 
  Settings, LogOut, Search, Bell,
  TrendingUp, ArrowUpRight, Filter,
  CheckCircle, XCircle, Trash2, Eye
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { adminAPI, userAPI, bookingAPI } from '../services/api';
import { useAuth } from '../context/AuthContext';
import { useNavigate } from 'react-router-dom';

const AdminDashboard = () => {
  const [activeTab, setActiveTab] = useState('overview');
  const [stats, setStats] = useState(null);
  const [users, setUsers] = useState([]);
  const [rooms, setRooms] = useState([]);
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  
  const { logout } = useAuth();
  const navigate = useNavigate();

  useEffect(() => {
    fetchData();
  }, [activeTab]);

  const fetchData = async () => {
    setLoading(true);
    try {
      if (activeTab === 'overview') {
        const res = await adminAPI.getStats();
        setStats(res.data);
      } else if (activeTab === 'users') {
        const res = await adminAPI.getUsers();
        setUsers(res.data);
      } else if (activeTab === 'properties') {
        const res = await adminAPI.getRooms();
        setRooms(res.data);
      } else if (activeTab === 'bookings') {
        const res = await adminAPI.getBookings();
        setBookings(res.data);
      }
    } catch (err) {
      console.error('Error fetching admin data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  const handleDeleteUser = async (id) => {
    if (window.confirm('Are you sure you want to delete this user?')) {
      try {
        await userAPI.deleteUser(id);
        setUsers(users.filter(u => u._id !== id));
      } catch (err) { alert('Failed to delete user'); }
    }
  };

  return (
    <div style={{ display: 'flex', height: '100vh', background: 'var(--bg)' }}>
      {/* Sidebar */}
      <aside style={{ width: '280px', borderRight: '1px solid var(--border)', padding: '24px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '40px' }}>
          <div style={{ background: 'var(--primary)', padding: '8px', borderRadius: '10px' }}>
            <Shield size={24} color="white" />
          </div>
          <span style={{ fontSize: '20px', fontWeight: 'bold' }}>RoomFlow Admin</span>
        </div>

        <nav style={{ flex: 1 }}>
          <NavItem active={activeTab === 'overview'} onClick={() => setActiveTab('overview')} icon={<BarChart3 size={20} />} label="Overview" />
          <NavItem active={activeTab === 'users'} onClick={() => setActiveTab('users')} icon={<Users size={20} />} label="Manage Users" />
          <NavItem active={activeTab === 'properties'} onClick={() => setActiveTab('properties')} icon={<Home size={20} />} label="Property Audit" />
          <NavItem active={activeTab === 'bookings'} onClick={() => setActiveTab('bookings')} icon={<Calendar size={20} />} label="Bookings Feed" />
          <div style={{ margin: '24px 0', borderTop: '1px solid var(--border)' }} />
          <NavItem icon={<Settings size={20} />} label="Settings" />
        </nav>

        <button 
          onClick={handleLogout}
          style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '12px', color: '#ff4444', background: 'transparent' }}
        >
          <LogOut size={20} />
          <span style={{ fontWeight: '500' }}>Sign Out</span>
        </button>
      </aside>

      {/* Main Content */}
      <main style={{ flex: 1, overflowY: 'auto' }}>
        {/* Header */}
        <header style={{ padding: '24px 40px', borderBottom: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', position: 'sticky', top: 0, background: 'rgba(9, 9, 11, 0.8)', backdropFilter: 'blur(8px)', zIndex: 10 }}>
           <div style={{ position: 'relative' }}>
              <Search size={18} style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input 
                type="text" 
                placeholder="Search platform..." 
                style={{ background: 'var(--card)', border: '1px solid var(--border)', borderRadius: '10px', padding: '10px 12px 10px 40px', width: '300px', color: 'white' }}
              />
           </div>
           <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
              <button style={{ color: 'var(--text-muted)', background: 'transparent' }}><Bell size={20} /></button>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px', padding: '4px 12px', border: '1px solid var(--border)', borderRadius: '25px' }}>
                 <div style={{ width: '28px', height: '28px', background: 'var(--primary)', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '12px' }}>A</div>
                 <span style={{ fontSize: '14px', fontWeight: '500' }}>System Admin</span>
              </div>
           </div>
        </header>

        <div style={{ padding: '40px' }}>
          <AnimatePresence mode="wait">
            {loading ? (
              <motion.div 
                key="loader"
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                exit={{ opacity: 0 }}
                style={{ display: 'flex', justifyContent: 'center', padding: '100px' }}
              >
                <div className="loader">Loading secure data...</div>
              </motion.div>
            ) : (
              <motion.div 
                key={activeTab}
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.4 }}
              >
                {activeTab === 'overview' && stats && (
                  <>
                    <div style={{ marginBottom: '32px' }}>
                      <h1 style={{ fontSize: '32px' }}>Platform Overview</h1>
                      <p style={{ color: 'var(--text-muted)' }}>Real-time metrics from the global room rental ecosystem.</p>
                    </div>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '24px', marginBottom: '40px' }}>
                      <StatCard label="Total Users" value={stats.users.total} change={`Owners: ${stats.users.owners}`} icon={<Users size={20} />} />
                      <StatCard label="Active Listings" value={stats.rooms.total} change="Across all cities" icon={<Home size={20} />} />
                      <StatCard label="Total Bookings" value={stats.bookings.total} change={`Confirmed: ${stats.bookings.confirmed}`} icon={<Calendar size={20} />} />
                      <StatCard label="Pending Approval" value={stats.bookings.pending} change="Requires attention" icon={<TrendingUp size={20} />} accent="#f59e0b" />
                    </div>
                  </>
                )}

                {activeTab === 'users' && (
                  <div className="premium-card">
                    <h3 style={{ fontSize: '20px', marginBottom: '24px' }}>User Management</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                      <thead>
                        <tr style={{ color: 'var(--text-muted)', fontSize: '13px', textAlign: 'left', borderBottom: '1px solid var(--border)' }}>
                          <th style={{ paddingBottom: '12px' }}>NAME</th>
                          <th style={{ paddingBottom: '12px' }}>EMAIL</th>
                          <th style={{ paddingBottom: '12px' }}>ROLE</th>
                          <th style={{ paddingBottom: '12px' }}>JOINED</th>
                          <th style={{ paddingBottom: '12px', textAlign: 'right' }}>ACTIONS</th>
                        </tr>
                      </thead>
                      <tbody>
                        {users.map(u => (
                          <tr key={u._id} style={{ borderBottom: '1px solid var(--border)', fontSize: '14px' }}>
                            <td style={{ padding: '16px 0' }}>{u.name}</td>
                            <td style={{ padding: '16px 0', color: 'var(--text-muted)' }}>{u.email}</td>
                            <td style={{ padding: '16px 0' }}>
                              <span style={{ background: 'rgba(99, 102, 241, 0.1)', color: 'var(--primary)', padding: '4px 10px', borderRadius: '12px', fontSize: '12px', fontWeight: 'bold' }}>
                                {u.role.toUpperCase()}
                              </span>
                            </td>
                            <td style={{ padding: '16px 0', color: 'var(--text-muted)' }}>{new Date(u.createdAt).toLocaleDateString()}</td>
                            <td style={{ padding: '16px 0', textAlign: 'right' }}>
                              <button onClick={() => handleDeleteUser(u._id)} style={{ color: '#ef4444', background: 'transparent' }}><Trash2 size={18} /></button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}

                {activeTab === 'properties' && (
                  <div className="premium-card">
                    <h3 style={{ fontSize: '20px', marginBottom: '24px' }}>Property Audit Queue</h3>
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '20px' }}>
                      {rooms.map(r => (
                        <div key={r._id} className="glass" style={{ borderRadius: '16px', overflow: 'hidden', border: '1px solid var(--border)' }}>
                          <div style={{ height: '160px', background: 'var(--card)', position: 'relative' }}>
                            {r.images[0] && <img src={r.images[0]} style={{ width: '100%', height: '100%', objectFit: 'cover' }} alt="" />}
                            <div style={{ position: 'absolute', top: '12px', right: '12px', background: 'var(--bg)', padding: '4px 8px', borderRadius: '6px', fontSize: '12px', fontWeight: 'bold' }}>
                              ₹{r.rent}
                            </div>
                          </div>
                          <div style={{ padding: '16px' }}>
                            <h4 style={{ fontSize: '16px', marginBottom: '4px' }}>{r.title}</h4>
                            <p style={{ color: 'var(--text-muted)', fontSize: '13px', marginBottom: '16px' }}>{r.city}</p>
                            <div style={{ display: 'flex', gap: '8px' }}>
                              <button style={{ flex: 1, padding: '8px', borderRadius: '8px', background: 'var(--secondary)', color: 'white', fontSize: '12px', fontWeight: 'bold' }}>APPROVE</button>
                              <button style={{ flex: 1, padding: '8px', borderRadius: '8px', background: 'rgba(239, 68, 68, 0.1)', color: '#ef4444', border: '1px solid rgba(239, 68, 68, 0.2)', fontSize: '12px', fontWeight: 'bold' }}>REJECT</button>
                            </div>
                          </div>
                        </div>
                      ))}
                    </div>
                  </div>
                )}

                {activeTab === 'bookings' && (
                  <div className="premium-card">
                    <h3 style={{ fontSize: '20px', marginBottom: '24px' }}>Global Booking Feed</h3>
                    <table style={{ width: '100%', borderCollapse: 'collapse' }}>
                      <thead>
                        <tr style={{ color: 'var(--text-muted)', fontSize: '13px', textAlign: 'left', borderBottom: '1px solid var(--border)' }}>
                          <th style={{ paddingBottom: '12px' }}>ROOM</th>
                          <th style={{ paddingBottom: '12px' }}>TENANT</th>
                          <th style={{ paddingBottom: '12px' }}>OWNER</th>
                          <th style={{ paddingBottom: '12px' }}>STATUS</th>
                          <th style={{ paddingBottom: '12px', textAlign: 'right' }}>DATE</th>
                        </tr>
                      </thead>
                      <tbody>
                        {bookings.map(b => (
                          <tr key={b._id} style={{ borderBottom: '1px solid var(--border)', fontSize: '14px' }}>
                            <td style={{ padding: '16px 0' }}>{b.roomId?.title || 'Deleted Room'}</td>
                            <td style={{ padding: '16px 0' }}>{b.tenantId?.name}</td>
                            <td style={{ padding: '16px 0' }}>{b.ownerId?.name}</td>
                            <td style={{ padding: '16px 0' }}>
                              <span style={{ 
                                background: b.status === 'confirmed' ? 'rgba(16, 185, 129, 0.1)' : 'rgba(245, 158, 11, 0.1)',
                                color: b.status === 'confirmed' ? 'var(--secondary)' : '#f59e0b',
                                padding: '4px 10px',
                                borderRadius: '20px',
                                fontSize: '12px',
                                fontWeight: '600'
                              }}>
                                {b.status}
                              </span>
                            </td>
                            <td style={{ padding: '16px 0', textAlign: 'right', color: 'var(--text-muted)' }}>
                              {new Date(b.createdAt).toLocaleDateString()}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </main>
    </div>
  );
};

const NavItem = ({ icon, label, active = false, onClick }) => (
  <button 
    onClick={onClick}
    style={{ 
      display: 'flex', 
      alignItems: 'center', 
      gap: '12px', 
      padding: '12px', 
      width: '100%', 
      background: active ? 'rgba(99, 102, 241, 0.1)' : 'transparent', 
      color: active ? 'var(--primary)' : 'var(--text-muted)',
      borderRadius: '10px',
      marginBottom: '4px',
      fontSize: '15px'
    }}
  >
    {icon}
    <span style={{ fontWeight: '500' }}>{label}</span>
  </button>
);

const StatCard = ({ label, value, change, icon, accent = 'var(--primary)' }) => (
  <div className="premium-card">
    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px' }}>
      <div style={{ color: accent, background: `${accent}1a`, padding: '8px', borderRadius: '8px' }}>{icon}</div>
      <span style={{ color: 'var(--text-muted)', fontSize: '13px' }}>{change}</span>
    </div>
    <div style={{ color: 'var(--text-muted)', fontSize: '14px', fontWeight: '500' }}>{label}</div>
    <div style={{ fontSize: '28px', fontWeight: 'bold', marginTop: '4px' }}>{value}</div>
  </div>
);

export default AdminDashboard;
