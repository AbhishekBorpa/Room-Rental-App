const User = require('../models/User');
const Room = require('../models/Room');
const Booking = require('../models/Booking');

exports.getDashboardStats = async (req, res) => {
    try {
        const totalUsers = await User.countDocuments();
        const totalOwners = await User.countDocuments({ role: 'owner' });
        const totalTenants = await User.countDocuments({ role: 'tenant' });
        const totalRooms = await Room.countDocuments();
        const totalBookings = await Booking.countDocuments();
        const pendingBookings = await Booking.countDocuments({ status: 'pending' });
        const confirmedBookings = await Booking.countDocuments({ status: 'confirmed' });

        res.json({
            users: { total: totalUsers, owners: totalOwners, tenants: totalTenants },
            rooms: { total: totalRooms },
            bookings: { total: totalBookings, pending: pendingBookings, confirmed: confirmedBookings }
        });
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getAllUsers = async (req, res) => {
    try {
        const users = await User.find().select('-password').sort({ createdAt: -1 });
        res.json(users);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getAllRoomsDetail = async (req, res) => {
    try {
        const rooms = await Room.find().populate('ownerId', 'name email').sort({ createdAt: -1 });
        res.json(rooms);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getAllBookingsDetail = async (req, res) => {
    try {
        const bookings = await Booking.find()
            .populate('roomId', 'title')
            .populate('tenantId', 'name email')
            .populate('ownerId', 'name email')
            .sort({ createdAt: -1 });
        res.json(bookings);
    } catch (err) { res.status(500).send('Server error'); }
};
