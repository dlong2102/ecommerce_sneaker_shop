const paypal = require('@paypal/checkout-server-sdk');
const Payment = require('../models/payment');

// PayPal configuration
const environment = new paypal.core.SandboxEnvironment(
    process.env.PAYPAL_CLIENT_ID,
    process.env.PAYPAL_CLIENT_SECRET
);
const client = new paypal.core.PayPalHttpClient(environment);

const paymentController = {
    async createOrder(req, res) {
        try {
            const { amount, orderId } = req.body;
            const request = new paypal.orders.OrdersCreateRequest();
            request.prefer("return=representation");
            request.requestBody({
                intent: 'CAPTURE',
                purchase_units: [{
                    amount: {
                        currency_code: 'USD',
                        value: amount
                    },
                    reference_id: orderId
                }],
                application_context: {
                    user_action: 'PAY_NOW',
                    brand_name: 'Ecommerce Sneaker Store',
                    locale: 'en-US',
                    landing_page: 'LOGIN',
                    // Thêm custom scheme để đóng WebView
                    return_url: `http://10.0.2.2:5000/payment/success`,
                    cancel_url: 'http://10.0.2.2:5000/payment/cancel'
                }
            });

            const order = await client.execute(request);

            const payment = new Payment({
                orderId,
                amount,
                paymentMethod: 'paypal',
                paypalOrderId: order.result.id,
                status: 'CREATED'
            });
            await payment.save();

            res.json({
                success: true,
                orderId: orderId,
                paypalOrderId: order.result.id,
                amount: req.body.amount,
                approveUrl: order.result.links.find(link => link.rel === 'approve').href
            });
        } catch (err) {
            console.error('Error creating PayPal order:', err);
            res.status(500).json({
                success: false,
                error: 'Error creating PayPal order'
            });
        }
    },
    async createCodOrder(req, res) {
        try {
            const { amount, orderId } = req.body;

            // Validate input
            if (!amount || !orderId) {
                return res.status(400).json({
                    success: false,
                    error: 'Missing required fields: amount and orderId'
                });
            }

            // Kiểm tra xem orderId đã tồn tại chưa
            const existingPayment = await Payment.findOne({ orderId });
            if (existingPayment) {
                return res.status(400).json({
                    success: false,
                    error: 'Order already exists'
                });
            }

            // Tạo payment record mới
            const payment = new Payment({
                orderId,
                amount,
                paymentMethod: 'cod',
                status: 'CREATED',
                createdAt: new Date(),
                updatedAt: new Date()
            });

            await payment.save();

            // Trả về thông tin đơn hàng
            res.json({
                success: true,
                payment: {
                    orderId: payment.orderId,
                    amount: payment.amount,
                    status: payment.status,
                    paymentMethod: payment.paymentMethod,
                    createdAt: payment.createdAt
                }
            });

        } catch (err) {
            console.error('Error creating COD order:', err);
            res.status(500).json({
                success: false,
                error: 'Error creating COD order'
            });
        }
    },
    async getPaymentHistory(req, res) {
        try {
            const payments = await Payment.find()
                .sort({ createdAt: -1 });

            const paymentHistory = payments.map(payment => ({
                orderId: payment.orderId || '',
                amount: payment.amount || 0.0,
                status: payment.status || '',
                paymentMethod: payment.paymentMethod || '',
                paypalOrderId: payment.paypalOrderId || null,
                createdAt: payment.createdAt || new Date(),
            }));

            res.json({
                success: true,
                payment: paymentHistory
            });

        } catch (error) {
            console.error('Error getting payment history:', error);
            res.status(500).json({
                success: false,
                error: 'Error getting payment history',
                payment: [] // Return empty array on error
            });
        }
    },
    async capturePayment(req, res) {
        try {
            const { orderId } = req.body;

            const request = new paypal.orders.OrdersCaptureRequest(orderId);
            const capture = await client.execute(request);

            // Update payment status in database
            const payment = await Payment.findOne({ orderId });
            if (payment) {
                payment.status = 'CAPTURED';
                payment.captureId = capture.result.purchase_units[0].payments.captures[0].id;
                payment.payerId = capture.result.payer.payer_id;
                payment.updatedAt = Date.now();
                await payment.save();
            }

            res.json({
                success: true,
                captureData: capture.result
            });
        } catch (err) {
            console.error('Error capturing PayPal payment:', err);
            res.status(500).json({
                success: false,
                error: 'Error capturing payment'
            });
        }
    },
    async handlePaymentSuccess(req, res) {
        try {
            const { token: paypalOrderId, PayerID } = req.query;
            console.log('Payment success callback received:', { paypalOrderId, PayerID });

            const payment = await Payment.findOne({ paypalOrderId });
            if (!payment) {
                // Trả về HTML với script đóng WebView
                return res.send(`
                    <html>
                        <body>
                            <script>
                                window.location.href = 'flutter://payment/error?message=Payment_not_found';
                            </script>
                        </body>
                    </html>
                `);
            }

            if (payment.status === 'COMPLETED') {
                // Trả về HTML với script đóng WebView
                return res.send(`
                    <html>
                        <body>
                            <script>
                                window.location.href = 'flutter://payment/success?token=${payment.paypalOrderId}&PayerID=${payment.payerId}';
                            </script>
                        </body>
                    </html>
                `);
            }

            const request = new paypal.orders.OrdersCaptureRequest(paypalOrderId);
            const capture = await client.execute(request);

            if (capture.result.status === 'COMPLETED') {
                const updatedPayment = await Payment.findOneAndUpdate(
                    { paypalOrderId },
                    {
                        status: 'COMPLETED',
                        captureId: capture.result.purchase_units[0].payments.captures[0].id,
                        payerId: PayerID,
                        updatedAt: new Date()
                    },
                    { new: true }
                );

                // Trả về HTML với script đóng WebView
                return res.send(`
                    <html>
                        <body>
                            <script>
                                window.location.href = 'flutter://payment/success?token=${updatedPayment.paypalOrderId}&PayerID=${updatedPayment.payerId}';
                            </script>
                        </body>
                    </html>
                `);
            } else {
                throw new Error('Payment capture was not completed');
            }
        } catch (error) {
            console.error('Payment processing error:', error);
            // Trả về HTML với script đóng WebView khi có lỗi
            return res.send(`
                <html>
                    <body>
                        <script>
                            window.location.href = 'flutter://payment/error?message=${encodeURIComponent(error.message)}';
                        </script>
                    </body>
                </html>
            `);
        }
    },

    async handlePaymentCancel(req, res) {
        try {
            const { token: paypalOrderId } = req.query;

            await Payment.findOneAndUpdate(
                { paypalOrderId },
                {
                    status: 'CANCELLED',
                    updatedAt: new Date()
                },
                { new: true }
            );

            // Trả về HTML với script đóng WebView
            return res.send(`
                <html>
                    <body>
                        <script>
                            window.location.href = 'flutter://payment/cancel';
                        </script>
                    </body>
                </html>
            `);
        } catch (error) {
            console.error('Cancel payment error:', error);
            // Trả về HTML với script đóng WebView khi có lỗi
            return res.send(`
                <html>
                    <body>
                        <script>
                            window.location.href = 'flutter://payment/error?message=${encodeURIComponent(error.message)}';
                        </script>
                    </body>
                </html>
            `);
        }
    },
    async getOrderStatus(req, res) {
        try {
            const { paypalOrderId } = req.params;
            console.log('Checking order status:', paypalOrderId);

            const payment = await Payment.findOne({ paypalOrderId });
            if (!payment) {
                return res.status(404).json({
                    success: false,
                    message: 'Payment not found'
                });
            }
            console.log('Payment found:', payment.status);
            if (payment.status === 'COMPLETED') {
                return res.json({
                    success: true,
                    payment
                });
            }
        } catch (error) {
            console.error('Error checking order status:', error);
            return res.status(500).json({
                success: false,
                message: 'Error checking order status',
                error: error.message
            });
        }
    }
};

module.exports = paymentController;