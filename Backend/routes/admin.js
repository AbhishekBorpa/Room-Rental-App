const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const adminAuth = require('../middleware/adminAuth');
const adminController = require('../controllers/adminController');

// All routes here require both authentication and admin role
router.get('/stats', [auth, adminAuth], adminController.getDashboardStats);
router.get('/users', [auth, adminAuth], adminController.getAllUsers);
router.get('/rooms', [auth, adminAuth], adminController.getAllRoomsDetail);
router.get('/bookings', [auth, adminAuth], adminController.getAllBookingsDetail);

module.exports = router;
