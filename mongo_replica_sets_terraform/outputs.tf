output "Mongo_Private_IP" {
  value =  toset([
    for ip in module.mongo_ec2_instance : ip.private_ip
  ])
}

output "Mongo_Public_IP" {
    value =  toset([
    for ip in module.mongo_ec2_instance : ip.public_ip
      ])
}

output "Bastion_Public_IP" {
    value =  toset([
    for ip in module.bastion_ec2_instance : ip.public_ip
      ])
}
