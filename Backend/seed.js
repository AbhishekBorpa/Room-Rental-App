require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const cloudinary = require('cloudinary').v2;
const User = require('./models/User');
const Room = require('./models/Room');

// Configure Cloudinary
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET
});

const unsplashTemplates = [
    [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1c2f448109?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=800&q=80'
    ],
    [
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1484154218962-a197022b5858?auto=format&fit=crop&w=800&q=80'
    ],
    [
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1505691938895-1758d7bef511?auto=format&fit=crop&w=800&q=80'
    ],
    [
        'https://images.unsplash.com/photo-1554995207-c18c203602cb?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80'
    ]
];

const cities = ['Mumbai', 'Delhi', 'Bangalore', 'Pune', 'Hyderabad'];
const roomTypes = ['single', 'double', 'dorm', 'shared'];
const furnishings = ['fully', 'semi', 'unfurnished'];
const genderPrefs = ['any', 'male', 'female'];

// Helper to upload images to Cloudinary
async function uploadTemplates() {
    console.log('Migrating template images to Cloudinary...');
    const migratedTemplates = [];
    
    for (const group of unsplashTemplates) {
        const migratedGroup = [];
        for (const url of group) {
            try {
                const result = await cloudinary.uploader.upload(url, {
                    folder: 'seed_data',
                    resource_type: 'image'
                });
                migratedGroup.push(result.secure_url);
                console.log(`Uploaded: ${result.secure_url}`);
            } catch (e) {
                console.error(`Failed to upload ${url}: ${e.message}`);
                migratedGroup.push(url); // fallback to raw unsplash
            }
        }
        migratedTemplates.push(migratedGroup);
    }
    return migratedTemplates;
}

const cityCoords = {
    'Mumbai': [
        { lat: 19.0760, lng: 72.8777 }, { lat: 19.1136, lng: 72.8697 }, { lat: 19.2183, lng: 72.9781 }
    ],
    'Delhi': [
        { lat: 28.6139, lng: 77.2090 }, { lat: 28.5355, lng: 77.3910 }, { lat: 28.4595, lng: 77.0266 }
    ],
    'Bangalore': [
        { lat: 12.9716, lng: 77.5946 }, { lat: 12.9279, lng: 77.6271 }, { lat: 13.0358, lng: 77.5970 }
    ],
    'Pune': [
        { lat: 18.5204, lng: 73.8567 }, { lat: 18.5089, lng: 73.9259 }, { lat: 18.5679, lng: 73.9143 }
    ],
    'Hyderabad': [
        { lat: 17.3850, lng: 78.4867 }, { lat: 17.4483, lng: 78.3915 }, { lat: 17.4065, lng: 78.4691 }
    ]
};

const generateRooms = (ownerId, cloudinaryTemplates) => {
    const rooms = [];
    for (let i = 1; i <= 20; i++) { // Increased to 20
        const city = cities[Math.floor(Math.random() * cities.length)];
        const rent = Math.floor(Math.random() * 15000) + 5000;
        
        // Pick a random coordinate for the city
        const coords = cityCoords[city][Math.floor(Math.random() * cityCoords[city].length)];
        // Add a small random offset so markers don't overlap perfectly
        const lat = coords.lat + (Math.random() - 0.5) * 0.02;
        const lng = coords.lng + (Math.random() - 0.5) * 0.02;

        rooms.push({
            title: `Premium ${roomTypes[Math.floor(Math.random() * roomTypes.length)]} Room in ${city}`,
            description: 'A beautiful, well-ventilated room with great society amenities. Perfect for students or working professionals.',
            rent: rent,
            deposit: rent * 2,
            city: city,
            locality: `Sector ${Math.floor(Math.random() * 50) + 1}`,
            images: cloudinaryTemplates[Math.floor(Math.random() * cloudinaryTemplates.length)],
            roomType: roomTypes[Math.floor(Math.random() * roomTypes.length)],
            furnishing: furnishings[Math.floor(Math.random() * furnishings.length)],
            genderPreference: genderPrefs[Math.floor(Math.random() * genderPrefs.length)],
            bachelorsAllowed: Math.random() > 0.3,
            foodType: ['both', 'veg', 'non-veg'][Math.floor(Math.random() * 3)],
            nearMetro: Math.random() > 0.4,
            bathroom: Math.random() > 0.5 ? 'attached' : 'common',
            latitude: lat,
            longitude: lng,
            ownerId: ownerId
        });
    }
    return rooms;
};

const seedDB = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        console.log('Connected to MongoDB');

        // Clean db
        await Room.deleteMany({});
        console.log('Cleared existing rooms');

        // Create a default owner user if not exists
        let owner = await User.findOne({ email: 'owner@seed.com' });
        if (!owner) {
            const salt = await bcrypt.genSalt(10);
            const hashed = await bcrypt.hash('password123', salt);
            owner = new User({
                name: 'Seed Owner',
                email: 'owner@seed.com',
                password: hashed,
                phone: '9999999999',
                role: 'owner'
            });
            await owner.save();
            console.log('Created Seed Owner: owner@seed.com / password123');
        }

        // Upload images to Cloudinary first
        const cloudinaryTemplates = await uploadTemplates();

        const rooms = generateRooms(owner._id, cloudinaryTemplates);
        await Room.insertMany(rooms);
        console.log(`Successfully seeded ${rooms.length} rooms with Cloudinary images!`);

        process.exit();
    } catch (err) {
        console.error(err);
        process.exit(1);
    }
};

seedDB();
