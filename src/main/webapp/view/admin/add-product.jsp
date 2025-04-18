<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ include file="admin-header.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Add New Product');
    });
</script>

<!-- Add Product Form -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-blue-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Add New Product</h2>
        <a href="${pageContext.request.contextPath}/products" class="bg-white text-blue-500 hover:bg-blue-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
            <i class="fas fa-arrow-left mr-1"></i> Back to Products
        </a>
    </div>
    
    <c:if test="${error != null}">
        <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mx-4 my-4 rounded animate__animated animate__headShake" role="alert">
            <div class="flex">
                <div class="py-1"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i></div>
                <div>
                    <p class="font-bold">Error</p>
                    <p>${error}</p>
                </div>
            </div>
        </div>
    </c:if>
    
    <form action="${pageContext.request.contextPath}/product/add" method="POST" enctype="multipart/form-data" class="p-6 space-y-6">
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <!-- Product Name -->
            <div>
                <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Product Name <span class="text-red-500">*</span></label>
                <input type="text" id="name" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
            </div>
            
            <!-- Product Category -->
            <div>
                <label for="category" class="block text-sm font-medium text-gray-700 mb-1">Category <span class="text-red-500">*</span></label>
                <select id="category" name="category" required class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    <option value="">Select a category</option>
                    <option value="Electronics">Electronics</option>
                    <option value="Clothing">Clothing</option>
                    <option value="Home">Home</option>
                    <option value="Books">Books</option>
                    <option value="Sports">Sports</option>
                    <option value="Beauty">Beauty</option>
                    <option value="Toys">Toys</option>
                    <option value="Food">Food</option>
                    <option value="Other">Other</option>
                </select>
            </div>
            
            <!-- Product Price -->
            <div>
                <label for="price" class="block text-sm font-medium text-gray-700 mb-1">Price (in cents) <span class="text-red-500">*</span></label>
                <div class="mt-1 relative rounded-md shadow-sm">
                    <div class="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
                        <span class="text-gray-500 sm:text-sm">$</span>
                    </div>
                    <input type="number" id="price" name="price" min="0" required placeholder="0"
                           class="appearance-none block w-full pl-7 pr-12 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
                    <div class="absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none">
                        <span class="text-gray-500 sm:text-sm">cents</span>
                    </div>
                </div>
                <p class="mt-1 text-xs text-gray-500">Enter price in cents (e.g. 1999 for $19.99)</p>
            </div>
            
            <!-- Product Quantity -->
            <div>
                <label for="quantity" class="block text-sm font-medium text-gray-700 mb-1">Quantity <span class="text-red-500">*</span></label>
                <input type="number" id="quantity" name="quantity" min="0" required 
                       class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm">
            </div>
            
            <!-- Product Image -->
            <div class="md:col-span-2">
                <label for="image" class="block text-sm font-medium text-gray-700 mb-1">Product Image</label>
                <div class="mt-1 flex items-center">
                    <span class="inline-block h-12 w-12 rounded-md overflow-hidden bg-gray-100">
                        <img id="preview" src="#" alt="Preview" class="h-full w-full object-center object-cover hidden">
                        <svg id="placeholder" class="h-full w-full text-gray-300" fill="currentColor" viewBox="0 0 24 24">
                            <path d="M24 20.993V24H0v-2.996A14.977 14.977 0 0112.004 15c4.904 0 9.26 2.354 11.996 5.993zM16.002 8.999a4 4 0 11-8 0 4 4 0 018 0z" />
                        </svg>
                    </span>
                    <div class="ml-4">
                        <div class="relative bg-white py-2 px-3 border border-gray-300 rounded-md shadow-sm flex items-center cursor-pointer hover:bg-gray-50 focus-within:outline-none focus-within:ring-2 focus-within:ring-offset-2 focus-within:ring-blue-500">
                            <label for="image" class="relative text-sm font-medium text-blue-600 pointer-events-none">
                                <span>Upload a file</span>
                                <span class="sr-only"> product image</span>
                            </label>
                            <input id="image" name="image" type="file" accept="image/*" class="absolute inset-0 w-full h-full opacity-0 cursor-pointer" onchange="previewImage(this)">
                        </div>
                        <p class="mt-1 text-xs text-gray-500">PNG, JPG, GIF up to 5MB</p>
                    </div>
                </div>
            </div>
            
            <!-- Product Description -->
            <div class="md:col-span-2">
                <label for="description" class="block text-sm font-medium text-gray-700 mb-1">Description <span class="text-red-500">*</span></label>
                <textarea id="description" name="description" rows="4" required
                          class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-blue-500 focus:border-blue-500 sm:text-sm"></textarea>
            </div>
        </div>
        
        <div class="flex justify-end space-x-3 pt-4 border-t">
            <a href="${pageContext.request.contextPath}/products" class="inline-flex justify-center py-2 px-4 border border-gray-300 shadow-sm text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                Cancel
            </a>
            <button type="submit" class="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
                <i class="fas fa-save mr-2"></i> Save Product
            </button>
        </div>
    </form>
</div>

<!-- JavaScript for image preview -->
<script>
    function previewImage(input) {
        const preview = document.getElementById('preview');
        const placeholder = document.getElementById('placeholder');
        
        if (input.files && input.files[0]) {
            const reader = new FileReader();
            
            reader.onload = function(e) {
                preview.src = e.target.result;
                preview.classList.remove('hidden');
                placeholder.classList.add('hidden');
            }
            
            reader.readAsDataURL(input.files[0]);
        } else {
            preview.src = '#';
            preview.classList.add('hidden');
            placeholder.classList.remove('hidden');
        }
    }
    
    // Format the price input to show as currency
    document.getElementById('price').addEventListener('input', function(e) {
        // Keep only digits
        let value = e.target.value.replace(/\D/g, '');
        
        // Update the input value
        e.target.value = value;
    });
</script>

<%@ include file="admin-footer.jsp" %>