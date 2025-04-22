<%@page contentType="text/html" pageEncoding="UTF-8"%>

<footer class="bg-gray-800 text-white mt-12">
    <div class="container mx-auto px-4 py-12">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <!-- About -->
            <div>
                <h3 class="text-lg font-bold mb-4">About ShopEasy</h3>
                <p class="text-gray-400 mb-4">
                    ShopEasy is your one-stop shop for all your shopping needs. We offer a wide range of products at competitive prices.
                </p>
                <div class="flex space-x-4">
                    <a href="#" class="text-gray-400 hover:text-white transition">
                        <i class="fab fa-facebook-f"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition">
                        <i class="fab fa-twitter"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition">
                        <i class="fab fa-instagram"></i>
                    </a>
                    <a href="#" class="text-gray-400 hover:text-white transition">
                        <i class="fab fa-linkedin-in"></i>
                    </a>
                </div>
            </div>
            
            <!-- Quick Links -->
            <div>
                <h3 class="text-lg font-bold mb-4">Quick Links</h3>
                <ul class="space-y-2">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/dashboard" class="text-gray-400 hover:text-white transition">
                            Home
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/products" class="text-gray-400 hover:text-white transition">
                            Products
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/cart" class="text-gray-400 hover:text-white transition">
                            Cart
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/order/history" class="text-gray-400 hover:text-white transition">
                            Orders
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Categories -->
            <div>
                <h3 class="text-lg font-bold mb-4">Categories</h3>
                <ul class="space-y-2">
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/product/category?category=Kitchen Appliances" class="text-gray-400 hover:text-white transition">
                            Kitchen Appliances
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/product/category?category=Refrigerators %26 Freezers" class="text-gray-400 hover:text-white transition">
                            Refrigerators & Freezers
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/product/category?category=Washing Machines" class="text-gray-400 hover:text-white transition">
                            Washing Machines
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/customer/product/category?category=Air Conditioners" class="text-gray-400 hover:text-white transition">
                            Air Conditioners
                        </a>
                    </li>
                </ul>
            </div>
            
            <!-- Contact -->
            <div>
                <h3 class="text-lg font-bold mb-4">Contact Us</h3>
                <address class="not-italic text-gray-400">
                    <p class="mb-2">
                        <i class="fas fa-map-marker-alt mr-2"></i> 123 Shopping Street, Retail City
                    </p>
                    <p class="mb-2">
                        <i class="fas fa-phone-alt mr-2"></i> +1 234 567 8901
                    </p>
                    <p class="mb-2">
                        <i class="fas fa-envelope mr-2"></i> info@shopeasy.com
                    </p>
                </address>
            </div>
        </div>
        
        <div class="border-t border-gray-700 mt-8 pt-8 text-center text-gray-400">
            <p>&copy; ${java.time.Year.now().getValue()} ShopEasy. All rights reserved.</p>
        </div>
    </div>
</footer> 