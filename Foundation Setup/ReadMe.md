# Azure Cloud Journey: Setting Up the Foundation

This performing simple operations through the Azure portal. These operations can also be managed through ARM templates (IaC).

---

## 1. Setting Up the Foundation

### 🔷 1.1 Creating and Managing Azure Subscriptions
Azure subscriptions form the billing/security boundary for resources.

**Screenshots:**

1. **Subscription List View**  
![Subscription Overview](https://github.com/user-attachments/assets/a416f77a-3976-4807-a3de-94423f3c56e3)  
*Purpose*: Shows active subscriptions with types (PAYG highlighted) and status  
*Key Features*:  
- Subscription type identification  
- Health monitoring interface  
- Management options  

2. **Add Subscription Flow**  
![Add Subscription](https://github.com/user-attachments/assets/e9e77fb4-0e86-466f-9492-88b0345b5807)  
*Purpose*: Documents subscription creation process  
*Key Features*:  
- Offer type selection  
- Security-blurred sensitive fields  
- Provisioning workflow  

---

### 🔷 1.2 Navigating Azure Tools

**Screenshots:**

3. **Portal Dashboard**  
![Portal Home](https://github.com/user-attachments/assets/23c2a4ab-de33-4585-ba97-8ec4f862b437)  
*Purpose*: Main Azure management interface  
*Key Features*:  
- Service navigation menu  
- Resource quick-access  
- Customizable dashboard  

4. **CLI Example**  
![CLI Output](https://github.com/user-attachments/assets/3aeca79e-dadd-4417-a5b5-dff551a3ad71)  
*Purpose*: Shows programmatic management  
*Key Features*:  
- `az account show` command  
- Safe output structure  
- Redacted sensitive data  

---

### 🔷 1.3 Resource Organization

**Screenshots:**

5. **Resource Groups**  
![RG List](https://github.com/user-attachments/assets/d1fcf697-3f3f-4d37-adad-caf53644d5f5)  
*Purpose*: Logical resource grouping  
*Key Features*:  
- Naming conventions  
- Location mapping  
- Subscription association  

6. **Tagging Example**  
![Tags](https://github.com/user-attachments/assets/71a6adde-7f3d-4f5e-b160-104ae8f6bdfa)  
*Purpose*: Cost/resource management  
*Key Features*:  
- Env=Dev, Project=Demo tags  
- Tag management interface  
- Organization strategy  

---

## Replication Commands
```bash
# Create resource group
az group create --name MyRG --location eastus --tags 'Owner=YourName' 'Env=Demo'

# Apply tags to existing RG (replace SUB_ID)
az tag create --resource-id /subscriptions/SUB_ID/resourceGroups/MyRG \
  --tags Department=Finance Project=Migration
