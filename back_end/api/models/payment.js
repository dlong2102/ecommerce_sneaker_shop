const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
    orderId: {
        type: String,
        required: true,
        unique: true
    },
    amount: {
        type: Number,
        required: true
    },
    currency: {
        type: String,
        required: true,
        default: 'VNĐ'
    },
    status: {
        type: String,
        enum: ['CREATED', 'CAPTURED', 'FAILED', 'COMPLETED', 'ERROR'],
        default: 'CREATED'
    },
    paypalOrderId: String,
    paymentMethod: {
        type: String,
        enum: ['paypal', 'cod'],
        required: true
    },
    payerId: String,
    createdAt: {
        type: Date,
        default: Date.now
    },
    updatedAt: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model('Payment', paymentSchema);