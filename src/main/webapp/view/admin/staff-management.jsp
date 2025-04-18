<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<%@ include file="admin-template.jsp" %>

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

<!-- Staff Management Section -->
<div class="bg-white rounded-lg shadow-md overflow-hidden animate-section">
    <div class="p-4 bg-purple-500 text-white flex justify-between items-center">
        <h2 class="text-lg font-semibold">Staff Members</h2>
        <a href="${pageContext.request.contextPath}/manager/staff/add" class="bg-white text-purple-500 hover:bg-purple-50 py-1 px-3 rounded-full text-sm font-medium flex items-center transition-colors">
            <i class="fas fa-user-plus mr-1"></i> Add New Staff
        </a>
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
                    <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                </tr>
            </thead>
            <tbody class="bg-white divide-y divide-gray-200">
                <c:if test="${empty staffList}">
                    <tr>
                        <td colspan="6" class="px-6 py-4 text-center text-sm text-gray-500">
                            <div class="flex flex-col items-center justify-center py-8">
                                <i class="fas fa-users text-gray-300 text-5xl mb-4"></i>
                                <p class="text-gray-500 font-medium">No staff members found</p>
                                <p class="text-gray-400 text-sm">Add a new staff member to get started</p>
                                <a href="${pageContext.request.contextPath}/manager/staff/add" class="mt-4 inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-purple-500 hover:bg-purple-600">
                                    <i class="fas fa-user-plus mr-2"></i> Add New Staff
                                </a>
                            </div>
                        </td>
                    </tr>
                </c:if>
                
                <c:forEach var="staff" items="${staffList}">
                    <tr class="hover:bg-gray-50 transition-colors">
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.userId}</td>
                        <td class="px-6 py-4 whitespace-nowrap">
                            <div class="flex items-center">
                                <div class="flex-shrink-0 h-10 w-10 rounded-full bg-purple-100 flex items-center justify-center">
                                    <i class="fas fa-user text-purple-500"></i>
                                </div>
                                <div class="ml-4">
                                    <div class="text-sm font-medium text-gray-900">${staff.name}</div>
                                    <div class="text-xs text-gray-500 capitalize">${staff.role}</div>
                                </div>
                            </div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.username}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.email}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">${staff.contactNumber}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm font-medium">
                            <div class="flex space-x-2">
                                <a href="${pageContext.request.contextPath}/manager/staff/edit?id=${staff.userId}" class="text-indigo-600 hover:text-indigo-900 transition-colors" title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="#" onclick="confirmDelete(${staff.userId}, '${staff.name}')" class="text-red-600 hover:text-red-900 transition-colors" title="Delete">
                                    <i class="fas fa-trash"></i>
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

<!-- JavaScript for Delete Confirmation -->
<script>
    function confirmDelete(staffId, staffName) {
        const modal = document.getElementById('deleteModal');
        const staffNameSpan = document.getElementById('staffName');
        const confirmBtn = document.getElementById('confirmDeleteBtn');
        
        staffNameSpan.textContent = staffName;
        confirmBtn.href = "${pageContext.request.contextPath}/manager/staff/delete?id=" + staffId;
        
        modal.classList.remove('hidden');
    }
    
    document.getElementById('closeModal').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
    document.getElementById('cancelDelete').addEventListener('click', function() {
        document.getElementById('deleteModal').classList.add('hidden');
    });
    
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