<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<%@ include file="../dashboard-template.jsp" %>

<!-- Set page title -->
<script>
    document.addEventListener('DOMContentLoaded', function() {
        setPageTitle('Staff Management');
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
                    <c:when test="${param.success == 'added'}">
                        <p>Staff member was successfully added.</p>
                    </c:when>
                    <c:when test="${param.success == 'updated'}">
                        <p>Staff member was successfully updated.</p>
                    </c:when>
                    <c:when test="${param.success == 'deleted'}">
                        <p>Staff member was successfully deleted.</p>
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
                    <c:when test="${param.error == 'invalid'}">
                        <p>Invalid staff data provided.</p>
                    </c:when>
                    <c:when test="${param.error == 'notfound'}">
                        <p>Staff member not found.</p>
                    </c:when>
                    <c:when test="${param.error == 'deletefailed'}">
                        <p>Failed to delete staff member.</p>
                    </c:when>
                    <c:otherwise>
                        <p>An error occurred during the operation.</p>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</c:if>

<!-- Quick Add Staff Form -->
<div class="bg-white rounded-lg shadow-md overflow-hidden mb-6 animate-section">
    <div class="p-4 bg-purple-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Quick Add Staff</h2>
        <a href="${pageContext.request.contextPath}/manager/staff/add" class="bg-white text-purple-500 hover:bg-purple-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
            <i class="fas fa-user-plus mr-1"></i> Advanced Form
        </a>
    </div>
    <div class="p-4">
        <form action="${pageContext.request.contextPath}/manager/staff/add" method="POST" class="grid grid-cols-1 md:grid-cols-6 gap-4">
            <div class="md:col-span-1">
                <label for="username" class="block text-sm font-medium text-gray-700 mb-1">Username <span class="text-red-500">*</span></label>
                <input type="text" id="username" name="username" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="password" class="block text-sm font-medium text-gray-700 mb-1">Password <span class="text-red-500">*</span></label>
                <input type="password" id="password" name="password" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="name" class="block text-sm font-medium text-gray-700 mb-1">Full Name <span class="text-red-500">*</span></label>
                <input type="text" id="name" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="email" class="block text-sm font-medium text-gray-700 mb-1">Email <span class="text-red-500">*</span></label>
                <input type="email" id="email" name="email" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="contactNumber" class="block text-sm font-medium text-gray-700 mb-1">Contact <span class="text-red-500">*</span></label>
                <input type="text" id="contactNumber" name="contactNumber" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
            </div>
            
            <div class="md:col-span-1">
                <label for="role" class="block text-sm font-medium text-gray-700 mb-1">Role <span class="text-red-500">*</span></label>
                <div class="flex items-center h-10">
                    <select id="role" name="role" required class="block w-full h-full px-3 py-2 border border-gray-300 rounded-l-md shadow-sm focus:outline-none focus:ring-purple-500 focus:border-purple-500 sm:text-sm">
                        <option value="staff">Staff</option>
                        <option value="manager">Manager</option>
                    </select>
                    <button type="submit" class="h-full flex items-center justify-center px-4 border border-l-0 border-transparent text-sm font-medium rounded-r-md text-white bg-purple-600 hover:bg-purple-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-500">
                        <i class="fas fa-plus mr-2"></i> Add
                    </button>
                </div>
            </div>
        </form>
    </div>
</div>

<!-- Staff Management Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-purple-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Staff Members</h2>
        <div class="flex space-x-2">
            <select id="roleFilter" class="bg-white text-gray-700 text-sm rounded-full px-3 py-1 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-purple-300">
                <option value="all">All Roles</option>
                <option value="staff">Staff Only</option>
                <option value="manager">Managers Only</option>
            </select>
        </div>
    </div>
    
    <!-- Staff Table -->
    <div class="overflow-x-auto">
        <table class="min-w-full divide-y divide-gray-200">
            <thead class="bg-gray-50">
                <tr>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">ID</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Username</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Contact</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200" id="staffTableBody">
                <c:if test="${empty staffList}">
                    <tr class="empty-message">
                        <td colspan="7" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-users text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No staff members found</p>
                                <p class="text-gray-400 text-sm">Add a new staff member using the form above</p>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="staff" items="${staffList}">
                    <tr class="hover:bg-gray-50 transition-colors staff-row" data-role="${staff.role}">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.userId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-10 w-10 rounded-full bg-purple-100 flex items-center justify-center">
                                    <i class="fas fa-user text-purple-500"></i>
                                </div>
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">${staff.name}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.username}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.email}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.contactNumber}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <span class="px-2 inline-flex text-xs leading-5 font-semibold rounded-full 
                                    ${staff.role == 'manager' ? 'bg-purple-100 text-purple-800' : 'bg-blue-100 text-blue-800'} capitalize">
                                    ${staff.role}
                                </span>
                                <button onclick="changeRole(${staff.userId}, '${staff.role}', '${staff.name}')" class="ml-2 text-indigo-600 hover:text-indigo-900 transition-colors text-xs fas fa-exchange-alt">
                                </button>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-2">
                                <a href="#" onclick="editStaff(${staff.userId}, '${staff.username}', '${staff.name}', '${staff.email}', '${staff.contactNumber}', '${staff.role}')" class="text-indigo-600 hover:text-indigo-900 transition-colors fas fa-edit" title="Edit">
                                </a>
                                <a href="#" onclick="confirmDelete(${staff.userId}, '${staff.name}')" class="text-red-600 hover:text-red-900 transition-colors fas fa-trash" title="Delete">
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
    </div>
    
    <!-- Pagination -->
    <c:if test="${not empty staffList}">
        <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200 sm:px-6">
            <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                <div>
                    <p class="text-sm text-gray-700">
                        Showing <span class="font-medium">1</span> to <span class="font-medium">${staffList.size()}</span> of <span class="font-medium">${staffList.size()}</span> results
                    </p>
                </div>
                <div>
                    <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px" aria-label="Pagination">
                        <a href="#" class="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Previous</span>
                            <i class="fas fa-chevron-left"></i>
                        </a>
                        <a href="#" aria-current="page" class="z-10 bg-indigo-50 border-indigo-500 text-indigo-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium">
                            1
                        </a>
                        <a href="#" class="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50">
                            <span class="sr-only">Next</span>
                            <i class="fas fa-chevron-right"></i>
                        </a>
                    </nav>
                </div>
            </div>
        </div>
    </c:if>
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
            <p class="mb-4">Are you sure you want to delete staff member "<span id="staffName" class="font-semibold"></span>"?</p>
            <p class="mb-4 text-sm text-gray-600">This action cannot be undone.</p>
            <div class="flex justify-end pt-2">
                <button id="cancelDelete" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                <a id="confirmDeleteBtn" href="#" class="px-4 py-2 bg-red-500 text-white rounded hover:bg-red-600 transition-colors">Delete</a>
            </div>
        </div>
    </div>
</div>

<!-- Change Role Modal -->
<div id="roleModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-indigo-500">Change Role</p>
                <button id="closeRoleModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            <p class="mb-4">Change role for "<span id="roleStaffName" class="font-semibold"></span>":</p>
            
            <form action="${pageContext.request.contextPath}/manager/staff/edit" method="POST" id="roleForm">
                <input type="hidden" id="roleUserId" name="userId" value="">
                <input type="hidden" name="updateRole" value="true">
                
                <div class="mb-4">
                    <label for="newRole" class="block text-sm font-medium text-gray-700 mb-1">New Role</label>
                    <select id="newRole" name="role" class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                        <option value="staff">Staff</option>
                        <option value="manager">Manager</option>
                    </select>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelRole" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 transition-colors">
                        <i class="fas fa-save mr-1"></i> Save
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Edit Staff Modal -->
<div id="editModal" class="fixed inset-0 flex items-center justify-center z-50 hidden">
    <div class="modal-overlay absolute inset-0 bg-black opacity-50"></div>
    <div class="modal-container bg-white w-11/12 md:max-w-md mx-auto rounded shadow-lg z-50 overflow-y-auto">
        <div class="modal-content py-4 text-left px-6">
            <div class="flex justify-between items-center pb-3">
                <p class="text-xl font-bold text-indigo-500">Edit Staff Member</p>
                <button id="closeEditModal" class="modal-close cursor-pointer z-50">
                    <i class="fas fa-times text-gray-500 hover:text-gray-800"></i>
                </button>
            </div>
            
            <form action="${pageContext.request.contextPath}/manager/staff/edit" method="POST" id="editForm">
                <input type="hidden" id="editUserId" name="userId" value="">
                
                <div class="mb-4">
                    <label for="editUsername" class="block text-sm font-medium text-gray-700 mb-1">Username</label>
                    <input type="text" id="editUsername" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm bg-gray-100 sm:text-sm" readonly>
                </div>
                
                <div class="mb-4">
                    <label for="editPassword" class="block text-sm font-medium text-gray-700 mb-1">Password (leave blank to keep current)</label>
                    <input type="password" id="editPassword" name="password" class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editName" class="block text-sm font-medium text-gray-700 mb-1">Full Name <span class="text-red-500">*</span></label>
                    <input type="text" id="editName" name="name" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editEmail" class="block text-sm font-medium text-gray-700 mb-1">Email <span class="text-red-500">*</span></label>
                    <input type="email" id="editEmail" name="email" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editContact" class="block text-sm font-medium text-gray-700 mb-1">Contact <span class="text-red-500">*</span></label>
                    <input type="text" id="editContact" name="contactNumber" required class="appearance-none block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm placeholder-gray-400 focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                </div>
                
                <div class="mb-4">
                    <label for="editRole" class="block text-sm font-medium text-gray-700 mb-1">Role <span class="text-red-500">*</span></label>
                    <select id="editRole" name="role" required class="block w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm">
                        <option value="staff">Staff</option>
                        <option value="manager">Manager</option>
                    </select>
                </div>
                
                <div class="flex justify-end pt-2">
                    <button type="button" id="cancelEdit" class="px-4 py-2 bg-gray-300 text-gray-800 rounded mr-2 hover:bg-gray-400 transition-colors">Cancel</button>
                    <button type="submit" class="px-4 py-2 bg-indigo-500 text-white rounded hover:bg-indigo-600 transition-colors">
                        <i class="fas fa-save mr-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- JavaScript -->
<script>
    // Delete confirmation
    function confirmDelete(staffId, staffName) {
        const modal = document.getElementById('deleteModal');
        const staffNameSpan = document.getElementById('staffName');
        const confirmBtn = document.getElementById('confirmDeleteBtn');
        
        staffNameSpan.textContent = staffName;
        confirmBtn.href = "${pageContext.request.contextPath}/manager/staff/delete?id=" + staffId;
        
        modal.classList.remove('hidden');
    }
    
    // Change role function
    function changeRole(userId, currentRole, staffName) {
        const modal = document.getElementById('roleModal');
        const staffNameSpan = document.getElementById('roleStaffName');
        const userIdInput = document.getElementById('roleUserId');
        const roleSelect = document.getElementById('newRole');
        
        staffNameSpan.textContent = staffName;
        userIdInput.value = userId;
        roleSelect.value = currentRole; // Set current role as default
        
        modal.classList.remove('hidden');
    }
    
    // Edit staff function
    function editStaff(userId, username, name, email, contact, role) {
        const modal = document.getElementById('editModal');
        const userIdInput = document.getElementById('editUserId');
        const usernameInput = document.getElementById('editUsername');
        const nameInput = document.getElementById('editName');
        const emailInput = document.getElementById('editEmail');
        const contactInput = document.getElementById('editContact');
        const roleSelect = document.getElementById('editRole');
        
        // Set form values
        userIdInput.value = userId;
        usernameInput.value = username;
        nameInput.value = name;
        emailInput.value = email;
        contactInput.value = contact;
        roleSelect.value = role;
        
        // Clear password field (for security)
        document.getElementById('editPassword').value = '';
        
        // Show modal
        modal.classList.remove('hidden');
    }
    
    // Role filtering
    document.getElementById('roleFilter').addEventListener('change', function() {
        const selectedRole = this.value;
        const rows = document.querySelectorAll('.staff-row');
        const emptyMessage = document.querySelector('.empty-message');
        let visibleRows = 0;
        
        rows.forEach(row => {
            const roleValue = row.getAttribute('data-role');
            if (selectedRole === 'all' || selectedRole === roleValue) {
                row.classList.remove('hidden');
                visibleRows++;
            } else {
                row.classList.add('hidden');
            }
        });
        
        // Show/hide empty message
        if (emptyMessage) {
            if (visibleRows === 0) {
                emptyMessage.classList.remove('hidden');
            } else {
                emptyMessage.classList.add('hidden');
            }
        }
    });
    
    // Modal close handlers
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('closeRoleModal').addEventListener('click', function() {
        document.getElementById('roleModal').classList.add('hidden');
    });
    
    document.getElementById('cancelRole').addEventListener('click', function() {
        document.getElementById('roleModal').classList.add('hidden');
    });
    
    document.getElementById('closeEditModal').addEventListener('click', function() {
        document.getElementById('editModal').classList.add('hidden');
    });
    
    document.getElementById('cancelEdit').addEventListener('click', function() {
        document.getElementById('editModal').classList.add('hidden');
    });
    
    // Close modals when clicking outside
    document.addEventListener('click', function(event) {
        const deleteModal = document.getElementById('deleteModal');
        const roleModal = document.getElementById('roleModal');
        const editModal = document.getElementById('editModal');
        const deleteModalContent = deleteModal.querySelector('.modal-content');
        const roleModalContent = roleModal.querySelector('.modal-content');
        const editModalContent = editModal.querySelector('.modal-content');
        
        if (!deleteModal.classList.contains('hidden') && 
            !deleteModalContent.contains(event.target) && 
            !event.target.matches('[onclick^="confirmDelete"]')) {
            deleteModal.classList.add('hidden');
        }
        
        if (!roleModal.classList.contains('hidden') && 
            !roleModalContent.contains(event.target) && 
            !event.target.matches('[onclick^="changeRole"]')) {
            roleModal.classList.add('hidden');
        }
        
        if (!editModal.classList.contains('hidden') && 
            !editModalContent.contains(event.target) && 
            !event.target.matches('[onclick^="editStaff"]')) {
            editModal.classList.add('hidden');
        }
    });
</script>