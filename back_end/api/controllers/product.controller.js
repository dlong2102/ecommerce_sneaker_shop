const Product = require('../models/product');

exports.getAllProducts = async (req, res) => {
    try {
        const products = await Product.find();
        res.json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.searchProducts = async (req, res) => {
    try {
        const { q } = req.query;
        const products = await Product.find(
            { $text: { $search: q } },
            { score: { $meta: 'textScore' } }
        ).sort({ score: { $meta: 'textScore' } });

        res.json(products);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getProductById = async (req, res) => {
    try {
        const product = await Product.findById(req.params.id);
        if (!product) {
            return res.status(404).json({ error: 'Product not found' });
        }
        res.json(product);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.addProduct = async (req, res) => {
    try {
        // Kiểm tra quyền admin
        if (!req.user.isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Only admin can add products'
            });
        }

        const product = new Product(req.body);
        await product.save();

        res.status(201).json({
            success: true,
            message: 'Product added successfully',
            data: product
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error adding product',
            error: error.message
        });
    }
};

exports.updateProduct = async (req, res) => {
    try {
        // Kiểm tra quyền admin
        if (!req.user.isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Only admin can update products'
            });
        }

        const product = await Product.findByIdAndUpdate(
            req.params.id,
            req.body,
            { new: true, runValidators: true }
        );

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        res.json({
            success: true,
            message: 'Product updated successfully',
            data: product
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error updating product',
            error: error.message
        });
    }
};

// Xóa sản phẩm
exports.deleteProduct = async (req, res) => {
    try {
        // Kiểm tra quyền admin
        if (!req.user.isAdmin) {
            return res.status(403).json({
                success: false,
                message: 'Only admin can delete products'
            });
        }

        const product = await Product.findByIdAndDelete(req.params.id);

        if (!product) {
            return res.status(404).json({
                success: false,
                message: 'Product not found'
            });
        }

        res.json({
            success: true,
            message: 'Product deleted successfully'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: 'Error deleting product',
            error: error.message
        });
    }
};
