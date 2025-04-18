<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<jsp:include page="admin-template.jsp">
    <jsp:param name="section" value="header" />
</jsp:include>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Registration Keys');
    });
</script>

<!-- Success/Error Messages -->
<c:if test="${param.success != null}">
    <div class="bg-green-100 border-l-4 border-green-500 text-green-700 p-4 mb-6 rounded animate__animated animate__fadeIn" role="alert">
        <div class="flex">
            <div class="py-1"><i class="fas fa-check-circle text-green-500 mr-3"></i></div>
            <div>
                <p class="font-bold">Success</p>
                <c:choose>
                    <c:when test="${param.success == 'generated'}">
                        <p>Registration key was successfully generated.</p>
                        <c:if test="${not empty param.key}">
                            <div class="mt-2 p-2 bg-gray-100 rounded flex items-center">
                                <code class="text-sm font-mono flex-1 text-indigo-600">${param.key}</code>
                                <button onclick="copyKey('${param.key}')" class="text-gray-500 hover:text-gray-700 ml-2">
                                    <i class="fas fa-copy"></i>
                                </button>
                            </div>
                        </c:if>
                    </c:when>
                    <c:when test="${param.success == 'deleted'}">
                        <p>Registration key was successfully deleted.</p>
                    </c:when>
                    <c:otherwise>
                        <p>Operation completed successfully.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<c:if test="${param.error != null}">
    <div class="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 mb-6 rounded animate__animated animate__headShake" role="alert">
        <div class="flex">
            <div class="py-1"><i class="fas fa-exclamation-circle text-red-500 mr-3"></i></div>
            <div>
                <p class="font-bold">Error</p>
                <c:choose>
                    <c:when test="${param.error == 'invalidrole'}">
                        <p>Invalid role specified for key.</p>
                    </c:when>
                    <c:when test="${param.error == 'generatefailed'}">
                        <p>Failed to generate registration key.</p>
                    </c:when>
                    <c:when test="${param.error == 'deletefailed'}">
                        <p>Failed to delete registration key.</p>
                    </c:when>
                    <c:otherwise>
                        <p>An error occurred during the operation.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<!-- Generate Key Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6 animate-section">
    <div class="p-4 bg-yellow-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Generate New Registration Key</h2>
        <span class="bg-white text-yellow-500 py-1 px-3 rounded-full text-xs font-medium">Manager Only</span>
    </div>
    <div class="p-6">
        <p class="text-gray-600 mb-4">
            Create registration keys for new staff or manager accounts. These keys can be shared with individuals who need to create an account with special permissions.
        </p>
        
        <form action="${pageContext.request.contextPath}/manager/keys/generate" method="POST" class="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
                <label for="role" class="block text-sm font-medium text-gray-700 mb-1">Role <span class="text-red-500">*</span></label>
                <select id="role" name="role" required class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-yellow-500 focus:border-yellow-500 sm:text-sm">
                    <option value="">Select a role</option>
                    <option value="staff">Staff</option>
                    <option value="manager">Manager</option>
                </select>
            </div>
            
            <div>
                <label for="validDays" class="block text-sm font-medium text-gray-700 mb-1">Valid For (Days) <span class="text-red-500">*</span></label>
                <input type="number" id="validDays" name="validDays" value="7" min="1" max="30" required 
                       class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-yellow-500 focus:border-yellow-500 sm:text-sm">
            </div>
            
            <div class="flex items-end">
                <button type="submit" class="inline-flex items-center justify-center w-full py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-yellow-600 hover:bg-yellow-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-yellow-500">
                    <i class="fas fa-key mr-2"></i> Generate Key
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Active Keys Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-yellow-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Active Registration Keys</h2>
        <span class="text-xs bg-white text-yellow-500 py-1 px-2 rounded-full">Unused keys only</span>
    </div>
    
    <!-- Keys Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Key</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Generated</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Expires</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                <c:if test="${empty keyList}">
                    <tr>
                        <td colspan="6" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-key text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No active registration keys found</p>
                                <p class="text-gray-400 text-sm">Generate a new key using the form above</p>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="key" items="${keyList}">
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${key.keyId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <code class="text-xs font-mono text-indigo-600">${key.keyValue}</code>
                                <button onclick="copyKey('${key.keyValue}')" class="text-gray-500 hover:text-gray-700 ml-2">
                                    <i class="fas fa-copy"></i>
                                </button>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                ${key.role == 'manager' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'}">
                                ${key.role}
                            </span>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${key.createdAt}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${key.expiresAt}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <a href="#" onclick="confirmDelete(${key.keyId}, '${key.keyValue}')" class="text-red-600 hover:text-red-900 transition-colors" title="Delete">
                                <i class="fas fa-trash"></i>
                            </a>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div id="deleteModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-red-500">Confirm Delete</p>
                <button id="closeModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <p class="mb-4">Are you sure you want to delete this registration key?</p>
            <p class="mb-2 text-sm font-mono bg-gray-100 p-2 rounded"><span id="keyValue" class="text-indigo-600"></span></p>
            <p class="mb-4 text-sm text-gray-600">This action cannot be undone.</p>
            <div class="flex justify-end pt-2">
                <button id="cancelDelete" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                <a id="confirmDeleteBtn" href="#" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors">Delete</a>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript for Delete Confirmation and Copy Key -->
<script>
    function confirmDelete(keyId, keyValue) {
        const modal = document.getElementById('deleteModal');
        const keyValueSpan = document.getElementById('keyValue');
        const confirmBtn = document.getElementById('confirmDeleteBtn');
        
        keyValueSpan.textContent = keyValue;
        confirmBtn.href = "${pageContext.request.contextPath}/manager/keys/delete?id=" + keyId;
        
        modal.classList.remove('hidden');
    }
    
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    // Copy key to clipboard
    function copyKey(key) {
        navigator.clipboard.writeText(key)
            .then(() => {
                // Show a temporary success message
                const toast = document.createElement('div');
                toast.className = 'fixed bottom-4 right-4 bg-green-500 text-white px-4 py-2 rounded shadow-lg animate__animated animate__fadeIn';
                toast.innerHTML = '<i class="fas fa-check mr-2"></i> Key copied to clipboard';
                document.body.appendChild(toast);
                
                // Remove after 3 seconds
                setTimeout(() => {
                    toast.className += ' animate__fadeOut';
                    setTimeout(() => {
                        document.body.removeChild(toast);
                    }, 1000);
                }, 3000);
            })
            .catch(err => {
                console.error('Failed to copy: ', err);
                alert('Failed to copy key to clipboard');
            });
    }
    
    // Close modal when clicking outside
    document.addEventListener('click', function(event) {
        const modal = document.getElementById('deleteModal');
        const modalContent = document.querySelector('.modal-content');
        
        if (modal && !modal.classList.contains('hidden') && !modalContent.contains(event.target) && !event.target.matches('[onclick^="confirmDelete"]')) {
            modal.classList.add('hidden');
        }
    });
</script>

<jsp:include page="admin-template.jsp">
    <jsp:param name="section" value="footer" />
</jsp:include>