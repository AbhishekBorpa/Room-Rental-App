const express = require('express');
const Room = require('../models/Room');
const auth = require('../middleware/auth');
const router = express.Router();

// Get all rooms with filters (India specific)
router.get('/', async (req, res) => {
  try {
    let filter = {};
    if (req.query.city) filter.city = req.query.city;
    if (req.query.minRent) filter.rent = { $gte: parseInt(req.query.minRent) };
    if (req.query.maxRent) filter.rent = { ...filter.rent, $lte: parseInt(req.query.maxRent) };
    if (req.query.genderPreference) filter.genderPreference = req.query.genderPreference;
    if (req.query.foodIncluded === 'true') filter.foodIncluded = true;
    if (req.query.bachelorsAllowed === 'true') filter.bachelorsAllowed = true;
    if (req.query.nearMetro === 'true') filter.nearMetro = true;
    if (req.query.roomType) filter.roomType = req.query.roomType;

    const rooms = await Room.find(filter).populate('ownerId', 'name phone').sort({ createdAt: -1 });
    res.json(rooms);
  } catch (err) { res.status(500).send('Server error'); }
});

// Get single room
router.get('/:id', async (req, res) => {
  try {
    const room = await Room.findById(req.params.id).populate('ownerId', 'name phone');
    if (!room) return res.status(404).json({ msg: 'Room not found' });
    res.json(room);
  } catch (err) { res.status(500).send('Server error'); }
});

// Create listing (only owner)
router.post('/', auth, async (req, res) => {
  try {
    if (req.user.role !== 'owner') return res.status(403).json({ msg: 'Only owners can list rooms' });
    const newRoom = new Room({ ...req.body, ownerId: req.user.id });
    await newRoom.save();
    res.status(201).json(newRoom);
  } catch (err) { res.status(500).send('Server error'); }
});

// Update / Delete (owner only) – omitted for brevity, similar pattern

module.exports = router;