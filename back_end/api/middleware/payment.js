const validatePayment = (req, res, next) => {
    if (req.method === 'GET') {
        // Với GET request, kiểm tra query params thay vì body
        const { amount, orderId } = req.query;

        if (!amount || isNaN(amount) || amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid payment amount in query params'
            });
        }

        if (!orderId) {
            return res.status(400).json({
                success: false,
                error: 'Invalid order ID in query params'
            });
        }

    } else {
        // Với POST request, kiểm tra body như cũ
        const { amount, orderId } = req.body;

        if (!amount || isNaN(amount) || amount <= 0) {
            return res.status(400).json({
                success: false,
                error: 'Invalid payment amount'
            });
        }

        if (!orderId || typeof orderId !== 'string') {
            return res.status(400).json({
                success: false,
                error: 'Invalid order ID'
            });
        }
    }

    next();
};

// Middleware xác thực JWT (nếu cần)
const authMiddleware = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];

    if (!token) {
        return res.status(401).json({
            success: false,
            error: 'No token provided'
        });
    }

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded;
        next();
    } catch (err) {
        return res.status(401).json({
            success: false,
            error: 'Invalid token'
        });
    }
};

module.exports = {
    validatePayment,
    authMiddleware
};