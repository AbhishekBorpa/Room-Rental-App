const Room = require('../models/Room');
const redis = require('../config/redis');

const clearRoomCache = async () => {
  try {
    const keys = await redis.keys("rooms:all:*");
    if (keys.length > 0) {
      await redis.del(...keys);
    }
  } catch (err) {
    console.error("Redis Cache Clear Error:", err);
  }
};

exports.getAllRooms = async (req, res) => {
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

    // Keyword Search
    if (req.query.search) {
      filter.$or = [
        { title: { $regex: req.query.search, $options: 'i' } },
        { locality: { $regex: req.query.search, $options: 'i' } },
        { city: { $regex: req.query.search, $options: 'i' } }
      ];
    }


    const cacheKey = `rooms:all:${JSON.stringify(req.query)}`;
    const cachedData = await redis.get(cacheKey);
    if (cachedData) {
      console.log('Serving from cache:', cacheKey);
      return res.json(cachedData);
    }

    const rooms = await Room.find(filter).populate('ownerId', 'name phone').sort({ createdAt: -1 });
    
    // Cache the result for 1 hour
    await redis.set(cacheKey, rooms, { ex: 3600 });
    
    res.json(rooms);
  } catch (err) { 
    console.error(err);
    res.status(500).send('Server error'); 
  }
};

exports.getRoomById = async (req, res) => {
  try {
    const room = await Room.findById(req.params.id).populate('ownerId', 'name phone');
    if (!room) return res.status(404).json({ msg: 'Room not found' });
    res.json(room);
  } catch (err) { res.status(500).send('Server error'); }
};

exports.createRoom = async (req, res) => {
  try {
    if (req.user.role !== 'owner') return res.status(403).json({ msg: 'Only owners can list rooms' });
    
    let uploadedImages = [];
    if (req.files && req.files.length > 0) {
        uploadedImages = req.files.map(file => file.path);
    }
    
    const newRoom = new Room({ ...req.body, images: uploadedImages, ownerId: req.user.id });
    await newRoom.save();
    
    await clearRoomCache(); // Invalidate cache
    
    res.status(201).json(newRoom);
  } catch (err) { res.status(500).send('Server error'); }
};

exports.getOwnerRooms = async (req, res) => {
  try {
    if (req.user.role !== 'owner') return res.status(403).json({ msg: 'Must be an owner' });
    const rooms = await Room.find({ ownerId: req.user.id }).sort({ createdAt: -1 });
    res.json(rooms);
  } catch (err) { res.status(500).send('Server error'); }
};

exports.updateRoom = async (req, res) => {
  try {
    let room = await Room.findById(req.params.id);
    if (!room) return res.status(404).json({ msg: 'Room not found' });
    if (room.ownerId.toString() !== req.user.id) return res.status(401).json({ msg: 'Not authorized' });

    let updatedData = { ...req.body };
    if (req.files && req.files.length > 0) {
        const newImages = req.files.map(file => file.path);
        
        // If frontend passes existing images in `req.body.images` array, retain them
        let existing = updatedData.images || room.images;
        if (!Array.isArray(existing)) existing = [existing].filter(Boolean);
        
        updatedData.images = [...existing, ...newImages];
    }

    room = await Room.findByIdAndUpdate(req.params.id, { $set: updatedData }, { new: true });
    
    await clearRoomCache(); // Invalidate cache
    
    res.json(room);
  } catch (err) { res.status(500).send('Server error'); }
};

exports.deleteRoom = async (req, res) => {
  try {
    const room = await Room.findById(req.params.id);
    if (!room) return res.status(404).json({ msg: 'Room not found' });
    if (room.ownerId.toString() !== req.user.id) return res.status(401).json({ msg: 'Not authorized' });

    await Room.findByIdAndDelete(req.params.id);
    
    await clearRoomCache(); // Invalidate cache
    
    res.json({ msg: 'Room removed' });
  } catch (err) { res.status(500).send('Server error'); }
};
