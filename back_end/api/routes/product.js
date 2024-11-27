const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');
const isAdmin = require('../middleware/auth');

router.get('/', productController.getAllProducts);
router.get('/search', productController.searchProducts);
router.get('/:id', productController.getProductById);

router.get('/', isAdmin, productController.getAllProducts);
router.post('/create', productController.addProduct);
router.put('/:id', isAdmin, productController.updateProduct);
router.delete('/:id', isAdmin, productController.deleteProduct);

module.exports = router;