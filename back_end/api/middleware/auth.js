const jwt = require('jsonwebtoken');
const User = require('../models/user');

const auth = async (req, res, next) => {
    try {
        // Check Authorization header
        const authHeader = req.get('Authorization');
        if (!authHeader) {
            return res.status(401).json({
                success: false,
                message: 'Authorization header is missing'
            });
        }

        // Check token format
        if (!authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Invalid token format. Must be Bearer token'
            });
        }

        // Extract and verify token
        const token = authHeader.replace('Bearer ', '');
        let decoded;
        try {
            decoded = jwt.verify(token, process.env.JWT_SECRET);
        } catch (jwtError) {
            return res.status(401).json({
                success: false,
                message: 'Invalid or expired token',
                error: jwtError.message
            });
        }

        // Check for user ID in decoded token
        if (!decoded || !decoded.id) {
            return res.status(401).json({
                success: false,
                message: 'Token payload is invalid'
            });
        }

        // Handle admin-specific case
        if (decoded.id === 'admin') {
            req.user = { id: 'admin', email: 'admin@gmail.com', isAdmin: true };
            return next();
        }

        // Find user by decoded ID
        const user = await User.findById(decoded.id).select('-password');
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'User not found or deactivated'
            });
        }
        // Attach user object to req
        req.user = user;
        req.token = token;

        next();
    } catch (error) {
        console.error('Auth Middleware Error:', error);
        return res.status(500).json({
            success: false,
            message: 'Internal server error during authentication',
            error: error.message
        });
    }
};

const isAdmin = async (req, res, next) => {
    try {
        const adminHeader = req.get('Authorization');
        if (!adminHeader) {
            return res.status(401).json({
                success: false,
                message: 'Authorization header is missing'
            });
        }

        // Check token format
        if (!adminHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                message: 'Invalid token format. Must be Bearer token'
            });
        }

        // Extract and verify token
        const token = adminHeader.replace('Bearer ', '');
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Handle admin-specific case
        if (decoded.id === 'admin') {
            req.user = { id: 'admin', email: 'admin@gmail.com', isAdmin: true };
            return next();
        }

        // Validate ObjectId
        if (!mongoose.Types.ObjectId.isValid(decoded.id)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid ObjectId format'
            });
        }

        // Verify user in database
        const user = await User.findById(decoded.id);
        if (!user || !user.isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Not authorized as admin'
            });
        }

        req.user = user;
        next();
    } catch (error) {
        console.error('isAdmin Middleware Error:', error);
        res.status(401).json({
            success: false,
            message: 'Invalid token'
        });
    }
};
module.exports = auth, isAdmin;
