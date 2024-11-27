const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: String,
    description: String,
    price: Number,
    salePrice: Number,
    imageUrl: String,
    additionalImages: [String],
    sizes: [String],
    colors: [String],
    brand: String,
    inStock: Boolean,
});
// Text index cho tìm kiếm
productSchema.index({ name: 'text', brand: 'text' });

module.exports = mongoose.model('Product', productSchema);
