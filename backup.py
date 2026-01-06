import netmiko
import boto3
from datetime import datetime

# ১. রাউটার কানেকশন ডিটেইলস
device = {
    'device_type': 'cisco_ios',
    'host': 'ROUTER_PUBLIC_IP', # Terraform থেকে পাওয়া আইপি এখানে বসাবেন
    'username': 'backup_user',
    'password': 'YourPassword123',
}

# ২. ব্যাকআপ নেওয়া (গ্লোবাল কনফিগ ছাড়াই)
print("Connecting to router...")
net_connect = netmiko.ConnectHandler(**device)
config_data = net_connect.send_command("show running-config")
net_connect.disconnect()

# ৩. ফাইল তৈরি করা
file_name = f"cisco_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

# ৪. সরাসরি S3 তে পাঠানো
s3 = boto3.client('s3')
s3.put_object(
    Bucket='faruk-terraform-lab-001', 
    Key=f"backups/{file_name}", 
    Body=config_data
)

print(f"Success! Backup saved to S3 as backups/{file_name}")