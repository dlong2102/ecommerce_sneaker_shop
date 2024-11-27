const express = require('express');
const router = express.Router();
const paymentController = require('../controllers/payment.controller');
const { validatePayment } = require('../middleware/payment');

router.post('/create-order', validatePayment, paymentController.createOrder);
router.post('/capture-order', validatePayment, paymentController.capturePayment);
router.post('/create-cod-order', paymentController.createCodOrder);
router.get('/success', paymentController.handlePaymentSuccess);
router.get('/cancel', paymentController.handlePaymentCancel);
router.get('/orders-status/:paypalOrderId', paymentController.getOrderStatus);
router.get('/history', paymentController.getPaymentHistory);

module.exports = router;
