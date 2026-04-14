import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Shield, Lock, Mail, ArrowRight, Home } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { motion } from 'framer-motion';

const LandingPage = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const { login } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    try {
      const data = await login(email, password);
      if (data.user.role === 'admin') {
        navigate('/admin');
      } else {
        setError('Unauthorized: System Admin access only.');
      }
    } catch (err) {
      setError('Invalid credentials or portal error.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="landing-container" style={{ 
      height: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      background: 'radial-gradient(circle at center, rgba(99, 102, 241, 0.15) 0%, var(--bg) 100%)'
    }}>
      <motion.div 
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.5 }}
        className="premium-card glass" 
        style={{ width: '100%', maxWidth: '440px', padding: '48px' }}
      >
        <div style={{ textAlign: 'center', marginBottom: '40px' }}>
          <div style={{ 
            background: 'var(--primary)', 
            width: '64px', 
            height: '64px', 
            borderRadius: '16px', 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'center',
            margin: '0 auto 20px',
            boxShadow: '0 0 30px rgba(99, 102, 241, 0.4)'
          }}>
            <Shield size={32} color="white" />
          </div>
          <h1 style={{ fontSize: '32px', marginBottom: '8px' }}>Admin Portal</h1>
          <p style={{ color: 'var(--text-muted)' }}>Secure System Command Center</p>
        </div>

        {error && (
          <motion.div 
            initial={{ opacity: 0, x: -10 }}
            animate={{ opacity: 1, x: 0 }}
            style={{ 
              background: 'rgba(239, 68, 68, 0.1)', 
              color: '#ef4444', 
              padding: '12px', 
              borderRadius: '10px', 
              fontSize: '14px', 
              marginBottom: '24px',
              border: '1px solid rgba(239, 68, 68, 0.2)',
              textAlign: 'center'
            }}
          >
            {error}
          </motion.div>
        )}

        <form onSubmit={handleSubmit}>
          <div style={{ marginBottom: '20px' }}>
            <label style={{ display: 'block', fontSize: '13px', fontWeight: '500', color: 'var(--text-muted)', marginBottom: '8px' }}>ADMIN EMAIL</label>
            <div style={{ position: 'relative' }}>
              <Mail size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input 
                type="email" 
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="admin@roomflow.com" 
                style={{ 
                  width: '100%', 
                  background: 'rgba(255, 255, 255, 0.03)', 
                  border: '1px solid var(--border)', 
                  borderRadius: '12px', 
                  padding: '14px 14px 14px 48px',
                  color: 'white',
                  outline: 'none',
                  transition: 'border-color 0.2s'
                }}
                className="portal-input"
              />
            </div>
          </div>

          <div style={{ marginBottom: '32px' }}>
            <label style={{ display: 'block', fontSize: '13px', fontWeight: '500', color: 'var(--text-muted)', marginBottom: '8px' }}>ACCESS KEY</label>
            <div style={{ position: 'relative' }}>
              <Lock size={18} style={{ position: 'absolute', left: '16px', top: '50%', transform: 'translateY(-50%)', color: 'var(--text-muted)' }} />
              <input 
                type="password" 
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="••••••••" 
                style={{ 
                  width: '100%', 
                  background: 'rgba(255, 255, 255, 0.03)', 
                  border: '1px solid var(--border)', 
                  borderRadius: '12px', 
                  padding: '14px 14px 14px 48px',
                  color: 'white',
                  outline: 'none'
                }}
              />
            </div>
          </div>

          <button 
            type="submit" 
            className="btn-primary" 
            disabled={isLoading}
            style={{ 
              width: '100%', 
              padding: '16px', 
              fontSize: '16px', 
              display: 'flex', 
              alignItems: 'center', 
              justifyContent: 'center', 
              gap: '12px' 
            }}
          >
            {isLoading ? 'Verifying Credentials...' : (
              <>
                Initialize Session <ArrowRight size={20} />
              </>
            )}
          </button>
        </form>

        <div style={{ marginTop: '40px', paddingTop: '24px', borderTop: '1px solid var(--border)', textAlign: 'center' }}>
          <p style={{ color: 'var(--text-muted)', fontSize: '12px', letterSpacing: '1px' }}>
            ENCRYPTED SYSTEM ACCESS • v2.4.0
          </p>
        </div>
      </motion.div>
    </div>
  );
};

export default LandingPage;
