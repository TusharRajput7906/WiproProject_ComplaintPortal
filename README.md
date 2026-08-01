# Smart Complaint & Service Management Portal

A Spring Boot enterprise web application designed to log, manage, assign, track, and resolve service complaints. It features a responsive JSP + AJAX frontend, RESTful APIs, secure BCrypt password hashing, and auto-history log auditing.

---

## 🛠️ Technology Stack
- **Java**: Version 17
- **Framework**: Spring Boot (v3.x)
- **Persistence**: Spring Data JPA & Hibernate
- **Database**: MySQL Driver (3306)
- **UI Engine**: JSP (JavaServer Pages), JSTL, and AJAX (using Fetch API)
- **Security**: Spring Security Crypto (BCrypt password encoder)
- **Build Tool**: Maven

---

## 🚀 Setup Instructions

### 1. Database Configuration
1. Make sure MySQL server is running on `localhost:3306`.
2. Connect to MySQL and create a database named `complaint_portal`:
   ```sql
   CREATE DATABASE complaint_portal;
   ```
3. Run the SQL initialization script located at [schema.sql](file:///c:/Users/Hp/ComplaintPortal/src/main/resources/schema.sql) to create tables and seed default admin/agent roles.

### 2. Application Properties Configuration
Open [application.properties](file:///c:/Users/Hp/ComplaintPortal/src/main/resources/application.properties) and update database credentials:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/complaint_portal?useSSL=false&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=YOUR_MYSQL_PASSWORD_HERE
```

### 3. Run the Application
Start the application from the root directory by running:
```bash
mvn spring-boot:run
```
Once started, the application will be hosted locally at:
👉 **[http://localhost:8080/](http://localhost:8080/)**

---

## 📁 Packages Structure
- `com.mciet.complaintportal.controller`: Handles view navigation routing and API controllers.
- `com.mciet.complaintportal.service`: Core business logic interface/implementations (e.g. BCrypt logic, audit trailing).
- `com.mciet.complaintportal.repository`: Spring Data JPA repository layers.
- `com.mciet.complaintportal.entity`: JPA persistence mappings to MySQL tables.
- `com.mciet.complaintportal.dto`: Strongly typed JSON request/response transfer objects.
- `com.mciet.complaintportal.exception`: Global Rest Advice handler and custom application exceptions.

---

## 📍 API Reference List

### 🔒 Authentication (`/api/auth`)
* `POST /api/auth/register` - Registers a new user (Customer, Agent, or Admin).
* `POST /api/auth/login` - Validates user credentials, returns user details on success.

### 📋 Complaints Management (`/api/complaints`)
* `POST /api/complaints` - Submits a new customer complaint.
* `GET /api/complaints/{id}` - Retrieves detailed information about a single complaint.
* `GET /api/complaints/customer/{customerId}` - Lists all complaints filed by a customer.
* `GET /api/complaints/agent/{agentId}` - Lists all complaints assigned to an agent.
* `PUT /api/complaints/{id}/status` - Updates a complaint's status with remarks.

### 👑 Admin Utilities (`/api/admin`)
* `GET /api/admin/users` - Lists all users registered in the system (no password output).
* `GET /api/admin/users/role/{role}` - Lists users filtered by role.
* `GET /api/admin/complaints` - Lists all registered complaints.
* `PUT /api/admin/complaints/{complaintId}/assign/{agentId}` - Assigns/re-assigns a support agent to a complaint.
* `GET /api/admin/dashboard/stats` - Fetches aggregate counts of system components.

### 🎧 Agent Actions (`/api/agent`)
* `GET /api/agent/{agentId}/complaints` - Lists complaints assigned to the agent.
* `PUT /api/agent/{agentId}/complaints/{complaintId}/resolve` - Marks a complaint as RESOLVED with remarks.
* `GET /api/agent/{agentId}/complaints/{complaintId}/history` - Fetches status history timeline for auditing.
