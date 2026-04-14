const Booking = require('../models/Booking');
const Room = require('../models/Room');
const Razorpay = require('razorpay');
const crypto = require('crypto');

const razorpay = new Razorpay({
    key_id: process.env.RAZORPAY_KEY_ID,
    key_secret: process.env.RAZORPAY_KEY_SECRET
});

exports.createRazorpayOrder = async (req, res) => {
    try {
        const { amount } = req.body;
        const options = {
            amount: amount * 100, // amount in the smallest currency unit (paise)
            currency: "INR",
            receipt: `receipt_${Date.now()}`
        };
        const order = await razorpay.orders.create(options);
        res.json(order);
    } catch (err) {
        console.error(err);
        res.status(500).send('Error creating Razorpay order');
    }
};

exports.verifyPayment = async (req, res) => {
    try {
        const {
            razorpay_order_id,
            razorpay_payment_id,
            razorpay_signature,
            roomId,
            startDate,
            endDate,
            amount
        } = req.body;

        const body = razorpay_order_id + "|" + razorpay_payment_id;
        const expectedSignature = crypto
            .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
            .update(body.toString())
            .digest('hex');

        if (expectedSignature === razorpay_signature) {
            // Payment is verified, create the booking
            const room = await Room.findById(roomId);
            if (!room) return res.status(404).json({ msg: 'Room not found' });

            const booking = new Booking({
                tenantId: req.user.id,
                ownerId: room.ownerId,
                roomId,
                startDate,
                endDate,
                amount,
                razorpayOrderId: razorpay_order_id,
                razorpayPaymentId: razorpay_payment_id,
                razorpaySignature: razorpay_signature,
                paymentStatus: 'paid',
                status: 'pending'
            });

            await booking.save();
            res.json({ success: true, booking });
        } else {
            res.status(400).json({ success: false, msg: 'Invalid signature' });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send('Server error during verification');
    }
};

exports.createBooking = async (req, res) => {
    try {
        const { roomId, startDate, endDate, amount } = req.body;
        const room = await Room.findById(roomId);
        if (!room) return res.status(404).json({ msg: 'Room not found' });
        
        const booking = new Booking({
            tenantId: req.user.id,
            ownerId: room.ownerId,
            roomId,
            startDate,
            endDate,
            amount,
            status: 'pending'
        });
        await booking.save();
        res.json(booking);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getMyBookings = async (req, res) => {
    try {
        const bookings = await Booking.find({ tenantId: req.user.id })
            .populate('roomId')
            .populate('ownerId', 'name phone')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getOwnerBookings = async (req, res) => {
    try {
        if (req.user.role !== 'owner') return res.status(403).json({ msg: 'Not authorized' });
        const bookings = await Booking.find({ ownerId: req.user.id })
            .populate('roomId', 'title')
            .populate('tenantId', 'name phone')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.updateBookingStatus = async (req, res) => {
    try {
        if (req.user.role !== 'owner') return res.status(403).json({ msg: 'Not authorized' });
        const { status } = req.body;
        
        let booking = await Booking.findById(req.params.id);
        if(!booking) return res.status(404).json({ msg: 'Booking not found' });
        if(booking.ownerId.toString() !== req.user.id) return res.status(401).json({ msg: 'Not authorization to update this booking' });

        booking.status = status;
        await booking.save();
        res.json(booking);
    } catch (err) { res.status(500).send('Server error'); }
};
