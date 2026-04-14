const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const messageController = require('../controllers/messageController');

router.get('/', auth, messageController.getChatThreads);
router.get('/:roomId/:userId', auth, messageController.getThreadMessages);
router.post('/', auth, messageController.sendMessage);

module.exports = router;
