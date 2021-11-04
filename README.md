# Mongo ReplicaSets

Provisioned using 
- Ansible and Terraform

### EC2 VM Provisioning.

We need 3 VM to setup a cluster.

sh ```
#---------------
terraform init
terraform plan
terraform apply
#---------------
```


### Generate the certificate for Mongo ReplicaSet TLS

sh```
#--------------------------------------------------------------------------------------------------------------------
openssl genrsa -out mongoCA.key -aes256 8192
openssl req -x509 -new -extensions v3_ca -key mongoCA.key -days 365 -out mongoCA.crt
#--------------------------------------------------------------------------------------------------------------------
openssl req -new -nodes -newkey rsa:4096 -keyout mongo-001.key -out mongo-001.csr
openssl x509 -CA mongoCA.crt -CAkey mongoCA.key -CAcreateserial -req -days 365 -in mongo-001.csr -out mongo-001.crt
cat mongo-001.key mongo-001.crt > mongo1.pem
#--------------------------------------------------------------------------------------------------------------------
openssl req -new -nodes -newkey rsa:4096 -keyout mongo-002.key -out mongo-002.csr 
openssl x509 -CA mongoCA.crt -CAkey mongoCA.key -CAcreateserial -req -days 365 -in mongo-002.csr -out mongo-002.crt 
cat mongo-002.key mongo-002.crt > mongo2.pem
#--------------------------------------------------------------------------------------------------------------------
openssl req -new -nodes -newkey rsa:4096 -keyout mongo-003.key -out mongo-003.csr 
openssl x509 -CA mongoCA.crt -CAkey mongoCA.key -CAcreateserial -req -days 365 -in mongo-003.csr -out mongo-003.crt 
cat mongo-003.key mongo-003.crt > mongo3.pem
#--------------------------------------------------------------------------------------------------------------------
```

Install MongoDB with Ansible.

Add the Ec2 IP to the Inventory file and perform the installation.

sh ```
#--------------------------------------------------------------------------------------------------------------------
ansible-galaxy collection install community.mongodb
#--------------------------------------------------------------------------------------------------------------------
ansible-playbook -i inventory.yaml  install-mongo.yaml --private-key=rsa-pemkey
#--------------------------------------------------------------------------------------------------------------------
```