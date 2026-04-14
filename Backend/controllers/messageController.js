const Message = require('../models/Message');

exports.getChatThreads = async (req, res) => {
    try {
        const messages = await Message.find({
            $or: [{ senderId: req.user.id }, { receiverId: req.user.id }]
        })
        .populate('senderId', 'name')
        .populate('receiverId', 'name')
        .populate('roomId', 'title')
        .sort({ createdAt: -1 });

        const threads = {};
        messages.forEach(msg => {
            const threadKey = `${[msg.senderId._id, msg.receiverId._id].sort().join('_')}_${msg.roomId._id}`;
            if (!threads[threadKey]) threads[threadKey] = msg;
        });

        res.json(Object.values(threads));
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getThreadMessages = async (req, res) => {
    try {
        const messages = await Message.find({
            roomId: req.params.roomId,
            $or: [
                { senderId: req.user.id, receiverId: req.params.userId },
                { senderId: req.params.userId, receiverId: req.user.id }
            ]
        }).sort({ createdAt: 1 });
        res.json(messages);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.sendMessage = async (req, res) => {
    try {
        const { receiverId, roomId, content } = req.body;
        const msg = new Message({
            senderId: req.user.id,
            receiverId,
            roomId,
            content
        });
        await msg.save();
        res.json(msg);
    } catch (err) { res.status(500).send('Server error'); }
};
