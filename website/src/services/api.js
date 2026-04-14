import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:5001/api',
});

// Add a request interceptor to include the auth token
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('token');
    if (token) {
      config.headers['x-auth-token'] = token;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

export const authAPI = {
  login: (credentials) => api.post('/auth/login', credentials),
  getMe: () => api.get('/auth/me'),
};

export const adminAPI = {
  getStats: () => api.get('/admin/stats'),
  getUsers: () => api.get('/admin/users'),
  getRooms: () => api.get('/admin/rooms'),
  getBookings: () => api.get('/admin/bookings'),
};

export const roomAPI = {
  getRooms: (params) => api.get('/rooms', { params }),
  getRoom: (id) => api.get(`/rooms/${id}`),
};

export const bookingAPI = {
  updateStatus: (id, status) => api.patch(`/bookings/${id}/status`, { status }),
};

export const userAPI = {
  deleteUser: (id) => api.delete(`/admin/users/${id}`), // Admin delete
};

export default api;
