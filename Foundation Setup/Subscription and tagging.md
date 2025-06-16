# Azure Cloud Journey: Setting Up the Foundation  

This project documents my journey in learning Azure cloud fundamentals, starting with core services like subscriptions, resource management, and organization strategies.  

---

## 1. Setting Up the Foundation  

### 📌 1.1 Creating and Managing Azure Subscriptions  
Azure subscriptions are the backbone of resource billing and access control. I explored:  
- **Pay-As-You-Go** (for individual/personal use)  
- **Enterprise Agreements** (for organizations)  

**Screenshots:**  
<!-- SCREENSHOT: Azure Subscriptions Page (Portal > Subscriptions > Show list with types) -->
![Subscription List](screenshots/subscription-list.png)  

<!-- SCREENSHOT: 'Add Subscription' flow (Portal > Subscriptions > + Add) -->
![Add Subscription](screenshots/add-subscription.png)  

---

### 📌 1.2 Navigating the Azure Portal & Azure CLI  
Efficient cloud management requires familiarity with both tools.  

**Screenshots:**  
<!-- SCREENSHOT: Azure Portal default dashboard with key services -->
![Screenshot 2025-06-17 010308](https://github.com/user-attachments/assets/f1b73d70-7669-422d-b244-7214d9f0d72c)  

<!-- SCREENSHOT: Azure CLI running 'az account show' or similar -->
![Screenshot 2025-06-17 010647](https://github.com/user-attachments/assets/7c857beb-8a5f-4533-8366-8f64da17528b)

---

### 📌 1.3 Resource Groups & Tagging Strategies  
Organizing resources is critical for cost management.  

**Screenshots:**  
<!-- SCREENSHOT: Resource Groups list (Portal > Resource Groups) -->
![Resource Groups List](screenshots/resource-groups.png)  

<!-- SCREENSHOT: Tags tab on a resource (e.g., Env=Dev, Project=Demo) -->
![Resource Tagging](screenshots/tagging.png)  


---

## How to Replicate  
```bash
# Create resource group
az group create --name MyResourceGroup --location eastus

# Add tags
az tag create --resource-id /subscriptions/{sub-id}/resourceGroups/MyResourceGroup --tags Env=Dev Project=Demo
