const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { upload } = require('../config/cloudinary');
const roomController = require('../controllers/roomController');

router.get('/', roomController.getAllRooms);
router.get('/owner/my-listings', auth, roomController.getOwnerRooms);
router.get('/:id', roomController.getRoomById);
router.post('/', auth, upload.array('media', 10), roomController.createRoom);
router.put('/:id', auth, upload.array('media', 10), roomController.updateRoom);
router.delete('/:id', auth, roomController.deleteRoom);

module.exports = router;