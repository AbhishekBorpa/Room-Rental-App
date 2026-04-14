const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const bookingController = require('../controllers/bookingController');

router.post('/', auth, bookingController.createBooking);
router.post('/create-order', auth, bookingController.createRazorpayOrder);
router.post('/verify-payment', auth, bookingController.verifyPayment);
router.get('/my', auth, bookingController.getMyBookings);
router.get('/owner/my', auth, bookingController.getOwnerBookings);
router.put('/:id/status', auth, bookingController.updateBookingStatus);

module.exports = router;
