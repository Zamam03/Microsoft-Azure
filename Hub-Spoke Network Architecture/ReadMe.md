# Azure Cloud Journey: Networking & Security in Azure

A secure and well-architected network forms the backbone of any resilient cloud infrastructure. This section dives into creating secure network boundaries using Virtual Networks (VNets), configuring firewall rules, and safely accessing virtual machines using **Azure Bastion**. We'll also deploy a simple web server (NGINX) and restrict access to it using **NSGs** and **IP whitelisting**.

---

## 3. Networking & Security in Azure

### 3.1 Virtual Networks & Subnets

Azure Virtual Networks (VNets) provide isolated, logically segmented environments in which we can run Azure resources securely. 

**Screenshots:**

1. **VNet Creation**
![VNet](https://github.com/user-attachments/assets/vnet-example)  
*Purpose*: Sets up network boundary and segmentation  
*Key Features*:  
- Defined address spaces  
- Segregated subnets for workload separation  
- DNS customization options  

---

### 3.2 Network Security Groups (NSGs)

NSGs control inbound and outbound traffic at both subnet and NIC level.

**Screenshot:**

2. **NSG Configuration**
![NSG](https://github.com/user-attachments/assets/nsg-example)  
*Purpose*: Enforces traffic filtering rules  
*Key Features*:  
- Source IP filtering  
- Port/protocol-based rules  
- Applied to subnet or VM level  

---

### 3.3 Secure Access with Azure Bastion

Azure Bastion allows secure RDP/SSH access to virtual machines **without exposing public IP addresses**.

**Scenario: Deploy VM, access it via Bastion, and install NGINX**

#### Step-by-Step:

** 1. Create VM in a subnet with NSG attached**

```bash
az vm create \
  --resource-group MyRG \
  --name MyVM \
  --image UbuntuLTS \
  --admin-username azureuser \
  --generate-ssh-keys \
  --vnet-name MyVNet \
  --subnet MySubnet \
  --nsg MyNSG \
  --public-ip-address "" \
  --enable-bastion true
```

** 2. Deploy Azure Bastion to the VNet**

```bash
az network bastion create \
  --name MyBastion \
  --public-ip-address MyBastionIP \
  --resource-group MyRG \
  --vnet-name MyVNet \
  --location eastus \
  --scale-units 2
```

 *Now connect to the VM using the Azure Portal > Bastion tab (no public IP required).*

---

### 3.4 Installing and Securing NGINX

Once inside the VM via Bastion:

```bash
# Inside the VM
sudo apt update
sudo apt install nginx -y
echo "hello world" | sudo tee /var/www/html/index.html
```

Test locally from the VM:

```bash
curl http://localhost
# Should return: hello world
```

---

### 3.5 Locking Down Access with NSG + Firewall Rule

**Objective**: Only allow your IP to access the NGINX web server over port 80.

```bash
az network nsg rule create \
  --resource-group MyRG \
  --nsg-name MyNSG \
  --name AllowWebFromMyIP \
  --priority 100 \
  --direction Inbound \
  --access Allow \
  --protocol Tcp \
  --source-address-prefixes YOUR.IP.ADDRESS.HERE \
  --source-port-ranges "*" \
  --destination-port-ranges 80 \
  --destination-address-prefixes "*" 
```

 *Other inbound access will be implicitly denied unless explicitly allowed.*

---

### Validation & Access

From your **local machine**, you can now access the deployed web app:

```url
http://<VM_PRIVATE_IP>
```

If accessed from your whitelisted IP: "hello world"

If not: Access Denied (thanks to NSG)

---

## Final Notes

- Azure Bastion eliminates the need for public IPs, keeping VMs secure.
- NSGs offer granular control, enabling IP whitelisting and port restrictions.
- Combining these with proper subnet design ensures strong network boundaries.
