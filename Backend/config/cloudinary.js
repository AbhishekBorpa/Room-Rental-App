const cloudinary = require('cloudinary').v2;
const { CloudinaryStorage } = require('multer-storage-cloudinary');
const multer = require('multer');

// Configure Cloudinary using .env credentials
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET
});

// Configure Multer storage to stream directly to Cloudinary
const storage = new CloudinaryStorage({
  cloudinary: cloudinary,
  params: {
    folder: 'room_rental_uploads',
    resource_type: 'auto', // Allows uploading both images and videos seamlessly
    allowed_formats: ['jpg', 'jpeg', 'png', 'webp', 'mp4'],
  },
});

const upload = multer({ storage: storage });

module.exports = { cloudinary, upload };
