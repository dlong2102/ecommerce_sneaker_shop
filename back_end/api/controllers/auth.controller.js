const User = require('../models/user');
const jwt = require('jsonwebtoken');
const ADMIN_EMAIL = 'admin@gmail.com';
const ADMIN_PASSWORD = '123456';
const emailService = require('../config/email_service');

exports.verifyToken = async (req, res) => {
    try {
        const user = await User.findById(req.user._id);
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        res.json({
            success: true,
            data: {
                user: {
                    id: user._id,
                    email: user.email,
                    name: user.name,
                    isAdmin: user.isAdmin
                }
            }
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error verifying token'
        });
    }
};
exports.register = async (req, res) => {
    try {
        const { email, password, name, phoneNumber, address, dateOfBirth } = req.body;

        // Validate required fields
        if (!email || !password || !name) {
            return res.status(400).json({
                success: false,
                message: 'Email, password and name are required'
            });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({
                success: false,
                message: 'Invalid email format'
            });
        }

        // Check existing user
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({
                success: false,
                message: 'Email already exists'
            });
        }

        // Create new user
        const user = new User({
            email,
            password,
            name,
            phoneNumber,
            address,
            dateOfBirth: dateOfBirth ? new Date(dateOfBirth) : undefined,
        });

        await user.save();

        // Generate token
        const token = jwt.sign(
            { id: user._id },
            process.env.JWT_SECRET,
            { expiresIn: '7d' } // Token hết hạn sau 7 ngày
        );

        // Remove password from response
        const userResponse = user.toObject();
        delete userResponse.password;

        res.status(201).json({
            success: true,
            message: 'User registered successfully',
            data: { user: userResponse, token }
        });
    } catch (error) {
        console.error('Register Error:', error);
        res.status(500).json({
            success: false,
            message: 'Error in registration',
            error: error.message
        });
    }
};

exports.login = async (req, res) => {
    try {
        const { email, password } = req.body;

        // Validate input
        if (!email || !password) {
            return res.status(400).json({
                success: false,
                message: 'Email and password are required'
            });
        }
        // Check if it's admin login
        if (email === ADMIN_EMAIL && password === ADMIN_PASSWORD) {
            // Generate admin token
            const token = jwt.sign(
                {
                    id: 'admin',
                    isAdmin: true
                },
                process.env.JWT_SECRET,
                { expiresIn: '7d' }
            );

            return res.json({
                success: true,
                message: 'Admin login successful',
                data: {
                    user: {
                        email: ADMIN_EMAIL,
                        isAdmin: true,
                        role: 'admin'
                    },
                    token,
                    isAdmin: true
                }
            });
        }

        // Find user
        const user = await User.findOne({ email }).select('+password');
        if (!user) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Compare password
        const isMatch = await user.comparePassword(password);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Invalid credentials'
            });
        }

        // Generate token
        const token = jwt.sign(
            {
                id: user._id,
                isAdmin: user.isAdmin || false
            },
            process.env.JWT_SECRET,
            { expiresIn: '7d' } // Token hết hạn sau 7 ngày
        );

        // Remove password from response
        const userResponse = user.toObject();
        delete userResponse.password;

        res.json({
            success: true,
            message: 'Login successful',
            data: { user: userResponse, token, isAdmin: userResponse.isAdmin || false }
        });
    } catch (error) {
        console.error('Login Error:', error);
        res.status(500).json({
            success: false,
            message: 'Error in login',
            error: error.message
        });
    }
};
exports.getUserProfile = async (req, res) => {
    console.log('req.user:', req.user);
    try {
        // Check if user exists in request (set by auth middleware)
        if (!req.user) {
            return res.status(401).json({
                success: false,
                message: 'Authentication required'
            });
        }
        res.json({
            success: true,
            message: 'Profile fetched successfully',
            data: req.user
        });
    } catch (error) {
        console.error('Get Profile Error:', error);
        res.status(500).json({
            success: false,
            message: 'Error fetching profile',
            error: error.message
        });
    }
};
exports.updateUserProfile = async (req, res) => {
    console.log('req.user:', req.user);
    try {
        const email = req.user.email;
        const { name, address, dateOfBirth, phoneNumber, imgUrl } = req.body;

        // Ensure at least one field is provided for update
        if (!name && !address && !dateOfBirth) {
            return res.status(400).json({
                success: false,
                message: 'At least one field is required for update'
            });
        }

        // Initialize an update object
        const updateData = {};

        // Validate and assign fields if provided
        if (name) updateData.name = name;
        if (address) updateData.address = address;
        if (phoneNumber) updateData.phoneNumber = phoneNumber;
        if (imgUrl) updateData.imgUrl = imgUrl

        if (dateOfBirth) {
            // Validate date format using regex (e.g., YYYY-MM-DD format)
            const datePattern = /^\d{4}-\d{2}-\d{2}$/;
            if (!datePattern.test(dateOfBirth)) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid date format; please use YYYY-MM-DD'
                });
            }

            // Convert to Date object and check validity
            const date = new Date(dateOfBirth);
            if (isNaN(date.getTime())) {
                return res.status(400).json({
                    success: false,
                    message: 'Invalid date value'
                });
            }
            updateData.dateOfBirth = date;
        }

        // Attempt to update the user profile
        const updatedUser = await User.findOneAndUpdate(
            { email: email },
            { $set: updateData },
            {
                new: true,
                runValidators: true,
                select: '-password'
            }
        );

        if (!updatedUser) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Respond with success and updated user data
        res.json({
            success: true,
            message: 'Profile updated successfully',
            data: updatedUser
        });
    } catch (error) {
        console.error('Update Profile Error:', error);
        res.status(500).json({
            success: false,
            message: 'Error updating profile',
            error: error.message
        });
    }
};
exports.forgotPassword = async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({
                success: false,
                message: 'Email is required'
            });
        }

        const user = await User.findOne({ email });
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found with this email'
            });
        }

        // Generate new 6-character password
        const newPassword = Math.random().toString(36).slice(-6);

        // Update user's password in database
        user.password = newPassword;
        await user.save();

        // Send new password via email
        try {
            await emailService.sendNewPasswordEmail(email, newPassword);
            console.log('Email : ', email);
            console.log('New Password : ', newPassword);
            res.json({
                success: true,
                message: 'New password has been sent to your email'
            });
        } catch (emailError) {
            console.error('Send Email Error:', emailError);
            res.status(500).json({
                success: false,
                message: 'Failed to send new password email'
            });
        }
    } catch (error) {
        console.error('Forgot Password Error:', error);
        res.status(500).json({
            success: false,
            message: error.message || 'Error in forgot password process'
        });
    }
};
// Thêm hàm đổi mật khẩu (nếu cần)
exports.changePassword = async (req, res) => {
    try {
        const { currentPassword, newPassword } = req.body;
        const userId = req.user._id;

        // Validate input
        if (!currentPassword || !newPassword) {
            return res.status(400).json({
                success: false,
                message: 'Current password and new password are required'
            });
        }

        // Get user with password
        const user = await User.findById(userId).select('+password');
        if (!user) {
            return res.status(404).json({
                success: false,
                message: 'User not found'
            });
        }

        // Verify current password
        const isMatch = await user.comparePassword(currentPassword);
        if (!isMatch) {
            return res.status(401).json({
                success: false,
                message: 'Current password is incorrect'
            });
        }

        // Update password
        user.password = newPassword;
        await user.save();

        res.json({
            success: true,
            message: 'Password changed successfully'
        });
    } catch (error) {
        console.error('Change Password Error:', error);
        res.status(500).json({
            success: false,
            message: 'Error changing password',
            error: error.message
        });
    }
};