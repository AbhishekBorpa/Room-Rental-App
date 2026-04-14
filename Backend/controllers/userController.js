const User = require('../models/User');

exports.getProfile = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).select('-password').populate('favorites');
        res.json(user);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.updateProfile = async (req, res) => {
    try {
        const { name, phone } = req.body;
        const user = await User.findByIdAndUpdate(
            req.user.id, 
            { $set: { name, phone } }, 
            { new: true }
        ).select('-password');
        res.json(user);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.getFavorites = async (req, res) => {
    try {
        const user = await User.findById(req.user.id).populate('favorites');
        res.json(user.favorites);
    } catch (err) { res.status(500).send('Server error'); }
};

exports.toggleFavorite = async (req, res) => {
    try {
        const user = await User.findById(req.user.id);
        const index = user.favorites.indexOf(req.params.roomId);
        if (index === -1) {
            user.favorites.push(req.params.roomId);
        } else {
            user.favorites.splice(index, 1);
        }
        await user.save();
        res.json(user.favorites);
    } catch (err) { res.status(500).send('Server error'); }
};
