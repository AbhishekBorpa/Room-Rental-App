const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: String,
    city: {
        type: String,
        enum: ['Mumbai', 'Delhi', 'Bangalore', 'Chennai', 'Kolkata', 'Hyderabad', 'Pune', 'Ahmedabad', 'Jaipur'],
        required: true
    },
    locality: String,
    rent: { type: Number, required: true },          // Monthly rent in ₹
    deposit: { type: Number, default: 0 },
    availableFrom: Date,
    roomType: { type: String, enum: ['single', 'double', 'dorm', 'shared'], default: 'single' },
    furnishing: { type: String, enum: ['fully', 'semi', 'unfurnished'], default: 'unfurnished' },
    bathroom: { type: String, enum: ['attached', 'shared', 'common'], default: 'shared' },
    foodIncluded: { type: Boolean, default: false },   // PG style
    foodType: { type: String, enum: ['veg', 'non-veg', 'both'], default: 'veg' },
    genderPreference: { type: String, enum: ['male', 'female', 'any'], default: 'any' },
    bachelorsAllowed: { type: Boolean, default: true },
    nearMetro: { type: Boolean, default: false },
    latitude: { type: Number },
    longitude: { type: Number },
    images: [String],   // array of image URLs or base64
    ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    createdAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Room', roomSchema);