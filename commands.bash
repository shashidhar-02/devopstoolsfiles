#add coments to explain each command
pwd # Print the current working directory
ls -la # List all files and directories with detailed information
cd /home # Change directory to /home
cd ~ # Change directory to the home directory
cd . . # Move up one directory level
tree # Display directory structure in a tree-like format
mkdir -p ~/practice/{dir1,dir2,dir3} # Create directories dir1, dir2, and dir3 inside ~/practice
cd ~/practice # Change directory to ~/practice
touch file1.txt file2.txt  file3.txt  # Create three empty files: file1.txt, file2.txt, and file3.txt
echo "hello world">file1.txt # Write "hello world" to file1.txt
cat file1.txt # Display the contents of file1.txt
cp file1.txt file1_backup.txt # Copy file1.txt to file1_backup.txt
mv file2.txt file2_renamed.txt # Rename file2.txt to file2_renamed.txt
rm file3.txt # Remove file3.txt
rmdir dir3 # Remove directory dir3
mkdir  test_dir # Create a new directory named test_dir
cd test_dir # Change directory to test_dir
touch test_file.txt # Create an empty file named test_file.txt
cp -r dir1 dir1_backup # Copy directory dir1 to dir1_backup
mv dir2 dir2_renamed # Rename directory dir2 to dir2_renamed
rm -r dir3 # Remove directory dir3 and its contents
ls -l  file1.txt # List detailed information about file1.txt
chmod 644 file1.txt # Set permissions to rw-r--r-- for file1.txt
chmod  755 file1.txt # Set permissions to rwxr-xr-x for file1.txt
chmod 777 file1.txt # Set permissions to rwxrwxrwx for file1.txt
chmod u+w file1.txt # Add write permission for the user on file1.txt    
chmod g-w file1.txt # Remove write permission for the group on file1.txt
chmod o+r file1.txt # Add read permission for others on file1.txt
sudo chown $user:$user file1.txt # Change ownership of file1.txt to the specified user and group
sudo  chown -R $user:$user ~/practice # Recursively change ownership of ~/practice to the specified user and group
echo "seecret data">secret.txt # Write "seecret data" to secret.txt
chmod 600 secret.txt # Set permissions to rw------- for secret.txt
chmod 644 public.txt # Set permissions to rw-r--r-- for public.txt
chmod 755  script.sh # Set permissions to rwxr-xr-x for script.sh
#add more commands related to file viewing and text processing

#cat>sample.txt<<EOF
#explain the commands below
cat sample.txt  # Display the contents of sample.txt
head -n  3 sample.txt # Display the first 3 lines of sample.txt
tail -n  2 sample.txt # Display the last 2 lines of sample.txt
less sample.txt # View the contents of sample.txt one screen at a time
more sammple.txt # View the contents of sample.txt one screen at a time (alternative to less)
ggrep "apple" sample.txt # Search for the string "apple" in sample.txt (GNU grep)
grep -i "apple" sample.txt # Search for the string "apple" in sample.txt, case-insensitive
grep -v "APPLE" sample.txt # Display lines that do not contain "APPLE" in sample.txt
grep -n "cherry " sample.txt  # Display lines containing "cherry" with line numbers in sample.txt
cat sample.txt | sort  # Sort the contents of sample.txt in ascending order
cat sample.txt | sort -r # Sort the contents of sample.txt in descending order
cat sample.txt | uniq # Display unique lines from sample.txt
wc -l sample.txt # Count the number of lines in sample.txt
sed 's/apple/banana/g' sample.txt # Replace all occurrences of "apple" with "banana" in sample.txt
sed 's/apple/banana/g' sample.txt # Replace all occurrences of "apple" with "banana" in sample.txt
sed '2d' sample.txt # Delete the second line from sample.txt
sed -n '1,3p' sample.txt # Print lines 1 to 3 from sample.txt
echo "john 25 engineer">people.txt # Write "john 25 engineer" to people.txt
echo "jane 30 doctor">>people.txt
echo "bob 22 artist">>people.txt
ls -la people.txt # List detailed information about people.txt
ls  -la /home # List detailed information about /home directory
ps -p $$ # Display information about the current shell process
bash --version # Display the version of Bash
cd ~ # Change directory to the home directory
echo $SHELL # Display the current shell
export MY_VAR="Hello World" # Set an environment variable MY_VAR to "Hello World"
alias ll='ls -la' # Create an alias ll for the command 'ls -la'
ls  # List files and directories
grep "Hello" # Search for the string "Hello" in the output of the previous command
cat  # Display the contents of the file provided by the previous command
#--- add more commands related to process management, networking, and system monitoring
top # Display real-time system processes and resource usage
htop # Interactive process viewer (if installed)
ps aux # Display detailed information about all running processes
kill <PID> # Terminate a process with the specified PID
kill -9 <PID> # Forcefully terminate a process with the specified PID
netstat -tuln # Display active network connections and listening ports
ss -tuln # Display active network connections and listening ports (alternative to netstat)
ping google.com # Send ICMP echo requests to google.com to check connectivity
curl http://example.com # Fetch the contents of example.com
df -h # Display disk space usage in a human-readable format
pwd # Print the current working directory
ls -la # List all files and directories with detailed information
tree # Display directory structure in a tree-like format
cp -r dir1 dir1_backup # Copy directory dir1 to dir1_backup
ls -l file1.txt # List detailed information about file1.txt
chmod 644 file1.txt # Set permissions to rw-r--r-- for file1.txt
awk  '{print $1,$3}' people.txt # Print the first and third columns from people.txt
top # Display real-time system processes and resource usage
htop # Interactive process viewer (if installed)
ps aux # Display detailed information about all running processes
kill <PID> # Terminate a process with the specified PID
kill -9 <PID> # Forcefully terminate a process with the specified PID
netstat -tuln # Display active network connections and listening ports
curl http://example.com # Fetch the contents of example.com
df -h
du -h # Display disk usage of files and directories in a human-readable format
ls -l /bin/ls # List detailed information about the /bin/ls executable
which init
# Locate the path of the init command
ls -la /etc/passwd # List detailed information about the /etc/passwd file
ls -la /etc/hostname # List detailed information about the /etc/hostname file
ls -la /etc/ssh/ # List detailed information about the /etc/ssh/ directory
cat /etc/hostname # Display the contents of the /etc/hostname file
cat /etc/os-release # Display the contents of the /etc/os-release file
cat /etc/fstab # Display the contents of the /etc/fstab file
cat /etc/ccrontab # Display the contents of the /etc/crontab file
ls -la ~
ls -la ~/documents
ls -la ~/.bashrc
ls -la  ~/.ssh/
sudo ls  -la /root
ls -la  /var/log/   # List detailed information about the /var/log/ directory
ls -la /var.log/syslog # List detailed information about the /var/log/syslog file
ls -la /var/log/auth.log # List detailed information about the /var/log/auth.log file
cat /var/log/syslog # Display the contents of the /var/log/syslog file
tail -f  /var/log/  syslog # Continuously monitor the /var/log/syslog file for new entries
ls -la /var/cache/ # List detailed information about the /var/cache/ directory
ls -la /var/mail/ # List detailed information about the /var/mail/ directory
ls -la /var/html # List detailed information about the /var/html directory
ls -la /tmp/ # List detailed information about the /tmp/ directory
df -h  /tmp # Display disk space usage for the /tmp directory in a human-readable format
mktemp      # Create a temporary file and display its name
mktemp -d # Create a temporary directory and display its name
ls -la  /usr/bin/ # List detailed information about the /usr/bin/ directory
which useradd # Locate the path of the useradd command
ls -la /usr/bin/    useradd # List detailed information about the /usr/bin/useradd executable
lss -la /usr/lib/python3.*/ # List detailed information about the /usr/lib/python3.x/ directory
ls -la /usr/local/bin/ # List detailed information about the /usr/local/bin/
ls -la /usr/local/etc/ # List detailed information about the /usr/local/etc/ directory
ls -la /usr/share/doc/ # List detailed information about the /usr/share/doc/ directory
ls -la /usr/share/man/ # List detailed information about the
man ls # Display the manual page for the ls
ls -la /opt/ # List detailed information about the /opt/ directory
sudo la -la /boot/ # List detailed information about the /boot/ directory
sudo ls -la /boot/grub/grub.cfg # List detailed information about the /boot/grub/grub.cfg file
ls -la /dev/ # List detailed information about the /dev/ directory
ls -la /dev/sda # List detailed information about the /dev/sda device file
ls -la /dev/sda1 # List detailed information about the /dev/sda1 device file
ls -la /dev/null # List detailed information about the /dev/null device file
ls -la /dev/random # List detailed information about the /dev/random device file 
echo "test"</dev/null # Redirect input from /dev/null to the echo command
lsblk # List information about all block devices
ls -la /proc/ # List detailed information about the /proc/ directory
cat /proc/cpuinfo # Display CPU information from /proc/cpuinfo
cat /proc/meminfo 
# Display memory information from /proc/meminfo
cat /proc/version # Display kernel version information from /proc/version
cat /proc/uptime # Display system uptime information from /proc/uptime
ls -la /proc/sellf/     # List detailed information about the /proc/self/ directory
cat /proc/sys/  
# Display system configuration information from /proc/sys/
ls -la /sys/ # List detailed information about the /sys/ directory
ls -la /sys/class/net/ # List detailed information about the /sys/class/net/ directory
ls -la /sys/block/ # List detailed information about the /sys/block/ directory
ls -la /run/ # List detailed information about the /run/ directory
ls -la /run/user/ # List detailed information about the /run/user/ directory
ls -la /mnt/ # List detailed information about the /mnt/ directory
sudo mount /dev/sdb1 /mnt/external # Mount the /dev/sdb1 device to /mnt/external
ls -la /media/ # List detailed information about the /media/ directory
ls -la /media/$user/ # List detailed information about the /media/$user/ directory
ls -la /srv/ # List detailed information about the /srv/ directory
ls -la /srv/ftp/ # List detailed information about the /srv/ftp/ directory
ls -la /srv/www/ # List detailed information about the /srv/www/ directory
ls -la /lib/ # List detailed information about the /lib/ directory
ls -la /lib64/ # List detailed information about the /lib64/ directory
ls -la /lib/modules/ # List detailed information about the /lib/modules/ directory
cd /home/user/documents # Change directory to /home/user/documents
cat /etc/passwd     
# Display the contents of the /etc/passwd file
cat /vr/log/syslog 
# Display the contents of the /var/log/syslog file
cd documents # Change directory to documents
cat ../file1.txt # Display the contents of file1.txt located in the parent directory
ls ../.. /tmp # List files and directories in the /tmp directory located two levels up
cd .    
# Stay in the current directory
cd .. 
# Move up one directory level
cd ~
# Change directory to the home directory
cd -
# Change to the previous directory
pwd
# Print the current working directory
ls .
# List files and directories in the current directory   
ls ..
# List files and directories in the parent directory
ls ../..        
# List files and directories two levels up
cd /home/user/Documents     
# Change directory to /home/user/Documents
pwd     

# Print the current working directory
cd ../downloads    
# Change directory to ../downloads
pwd    
# Print the current working directory
cd -    
# Change to the previous directory
cd ../../etc
# Change directory to ../../etc
cd ~ 
# Change directory to the home directory
cd /    
# Change directory to the root directory
cd -    
# Change to the previous directory
find /name  "*.conf" -type  f 2>/dev/null # Find all .conf files starting from the root directory, suppressing error messages
find /etc -name "*.conf "
find ~ -name "*.txt" -mtime -7 # Find all .txt files in the home directory modified in the last 7 days
find /var/log -name "*.log" -size +10M # Find all .log files in /var/log larger than 10MB
sudo updatedb # Update the database used by the locate command
locate sshd_comfig # Locate the sshd_config file using the locate command
locate -i readme 
# Locate files named readme, case-insensitive
grep -r "error" /var/log/
# Recursively search for the string "error" in /var/log/ directory
grep  -r "todo" ~/projects/ # Recursively search for the string "todo" in ~/projects/ directory
du  -sh /home/*  
# Display the disk usage of each subdirectory in /home/ in a human-readable format
du  -sh /var/* | sort -h # Display the disk usage of each subdirectory in /var/ sorted in human-readable format
ncdu  / # Open an interactive disk usage analyzer for the root directory
watch -n 1 'df -h ' # Continuously monitor disk space usage every second
tail -f /var/log/syslog # Continuously monitor the /var/log/syslog file for new entries
inotifywait -m /tmp # Monitor the /tmp directory for file system events
uname -a # Display detailed system information
lsb_release -a # Display Linux distribution information
hostnamectl  # Display system hostname and related information
df -h # Display disk space usage in a human-readable format
free -h # Display memory usage in a human-readable format
uptime # Display system uptime
mkdir -p ~/projects/{work.personal.learning} # Create directories work, personal, and learning inside ~/projects
mkdir -p ~/documents/{work,personal} # Create directories work and personal inside ~/documents
mkdir -p ~/scripts
mkdir -p ~/bin
find ~/documents -type  f  -exec  chmod  644 {} \; # Set permissions to rw-r--r-- for all files in ~/documents
find ~/documents -type d -exec  chmod 755 {} \; # Set permissions to rwxr-xr-x for all directories in ~/documents
tar -czf ~/backup-$(date +%Y%m%d).tar.gz ~/documents # Create a compressed tarball of ~/documents with the current date in the filename
df -h # Display disk space usage in a human-readable format
du 0sh /home/*
# Display the disk usage of each subdirectory in /home/ in a human-readable format
du -sh /var/* 
# Display the disk usage of each subdirectory in /var/ in a human-readable format
sudo apt autoremove  -y # Remove unnecessary packages and dependencies on Debian-based systems
sudo apt clean 
# Clean up the local repository of retrieved package files on Debian-based systems
rm -rf ~/.cache/* # Remove all files in the user's cache directory to free up space
journalctl --vacuum-size=100M # Reduce the size of systemd journal logs to 100MB
ln -s /var/log/syslog ~/syslog-link # Create a symbolic link to /var/log/syslog in the home directory
ls -l ~/syslog-link # List detailed information about the syslog-link symbolic link
readlink ~/syslog-link # Display the target of the syslog-link symbolic link
ln /path/to/file  /path/to/hardlink # Create a hard link to /path/to/file at /path/to/hardlink
ls -li /path/to/file /path/to/hardlink # List inode numbers to verify that both files point to the same inode
lsattr file1.txt # Display file attributes of file1.txt
sudo chattr +i file.txt # Make file1.txt immutable (cannot be modified or deleted)
sudo chattr -i file.txt # Remove the immutable attribute from file1.txt
getfacl  file.txt # Display the access control list (ACL) of file1.txt
setfacl -m u:username:rw file.txt # Modify the ACL of file1.txt to give read and write permissions to the specified user
setfacl -x u:username file.txt # Remove the ACL entry for the specified user from file1.txt
setfacl -b file.txt # Remove all ACL entries from file1.txt
lsblk 
# List information about all block devices
sudo mount /dev/sdb1 /mnt/usb
sudo unmount /mnt/usb # Unmount the /mnt/usb directory
mount |gep "^/dev"
# Display currently mounted filesystems and filter for those starting with /dev
sudo fcsk /dev/sdb1 # Check and repair the filesystem on /dev/sdb1
sudo e2fsck -f /dev/sdb1 # Forcefully check and repair the ext2/ext3/ext4 filesystem on /dev/sdb1
df -i 
ls -i file.txt # Display the inode number of file1.txt
stat file.txt # Display detailed information about file1.txt, including inode number
pwd # Print the current working directory
cd /path/to/directory # Change directory to /path/to/directory
cd  ../relative/path # Change directory to a relative path
cd ~ # Change directory to the home directory
cd - # Change to the previous directory
ls -lh # List files and directories with human-readable file sizes
ls -lhs # List files and directories with human-readable file sizes and include hidden files
ls -lht # List files and directories sorted by modification time, newest first
ls -lhtr # List files and directories sorted by modification time, oldest first
ls -ld */ # List only directories in the current directory
ls -R # Recursively list all files and directories
ls -lu # List files and directories sorted by access time
ls -lc # List files and directories sorted by change time
touch -a  filename # Update the access time of filename to the current time
touch -m  filename # Update the modification time of filename to the current time
touch -d "2024-01-01 12:00:00" filename # Set the access and modification time of filename to a specific date and time
cat file.txxt # Display the contents of file.txt
head -n  20 file.txt # Display the first 20 lines of file.txt
tail -n 15 file.txt # Display the last 15 lines of file.txt
tail -f  /var/log/syslog/nested/dir # Continuously monitor the /var/log/syslog/nested/dir file for new entries
touch  file{1.. 10}.txt # Create multiple empty files: file1.txt to file10.txt
cp -r  source /destination/ #recursively copy the source directory to the destination directory
mv oldname.txt newname.txt # Rename oldname.txt to newname.txt
rm -rf directory/ # Recursively remove the directory and its contents
ps aux # Display detailed information about all running processes
cat file.txt  | grep nginx # Search for the string "nginx" in file.txt
df -h | grep  -v tmpfs # Display disk space usage excluding tmpfs filesystems
command >file.txt #overwrite the output of command to file.txt
command >>file.txt #append the output of command to file.txt
command 2 >error.log # Redirect standard error of command to error.log
command &>all.log # Redirect both standard output and standard error of command to all.log
command 2>&1 | tee log.txt # Redirect both standard output and standard error of command to log.txt and display it on the terminal
find /path -name "*.log" # Find all .log files starting from /path
find /path -type f -mtime -7 # Find all files in /path modified in the last 7 days
find /path -type f -size +100M # Find all files in /path larger than 100MB
find /path -type f -empty # Find all empty files in /path
whichh python3 # Locate the path of the python3 command
locate sshd_connfig # Locate the sshd_config file using the locate command
grep -r "ERROR" /var/log/ # Recursively search for the string "error" in /var/log/ directory
grep -i "error" /var/log/syslog # Search for the string "error" in /var/log/syslog, case-insensitive
grep -v "exclude" file.txt # Display lines that do not contain "exclude" in file.txt
grep -A  5 "pattern" file 
grep -B  5 "pattern" file
grep -C  5 "paattern" file 
diff file1.txt file2.txt
# Compare the contents of file1.txt and file2.txt and display the differences
diff  file1.txt file2.txt  
# Compare the contents of file1.txt and file2.txt and display the differences side by side
sha256sum file.txt # Generate the SHA-256 checksum of file.txt
tar -czf backup.tar.gz /path/to/dir/ # Create a compressed tarball of /path/to/dir/
tar -xzf backup.tar.gz  # Extract the contents of the tarball
tar -xzf backup-$(date +%Y%m%d).tar.gz -C /important/data/ # Extract the contents of the tarball to /important/data/
sudo  useradd newuser -m -s /bin/bash  # Create a new user named newuser with a home directory and bash shell
sudo usermod -aG sudo newuser # Add newuser to the sudo group
id username # Display user ID and group ID information for the specified username
groups username # Display the groups that the specified username belongs to
chmod  644 file.txt 
chmod 755 script.sh
chmod 600 private.txt 
chmod -R 755 /var/www/ # Recursively set permissions to rwxr-xr-x for all files and directories in /var/www/
sudo chown user:group file.txt 
sudo chown -R www-data:www-data /var/www/ # Recursively change ownership of /var/www/ to the www-data user and group
chmod u+s /path/to/binary # Set the setuid bit on the specified binary
chmod g+s /path/to/directory  
chmod +t /tmp # Set the sticky bit on the /tmp directory
ps aux | grep nginx # Search for nginx processes in the list of running processes
ngrep -a nginx 
top 
htop 
kill -15 PID 
kill -9 PID 
killall process_name 
pkill -f pattern 
command & 
jobs 
fg %1 # Bring the first background job to the foreground
bg %1 # Resume the first stopped job in the background
nohup  command & # Run command in the background, immune to hangups
ip addr show # Display network interfaces and their IP addresses
ip  route show # Display the routing table
ss -tuln 
netstat -tuln 
lsof -i:80 # List processes listening on port 80 
ping -c 4 google.com # Send 4 ICMP echo requests to google.com to check connectivity
traceroute google.com #trace the route packets take to reach google.com
curl -I https://example.com # Fetch only the HTTP headers of example.com
wget https://example.com/file.zip # Download file.zip from example.com
ssh  user@hostname # Connect to a remote host via SSH
ssh -i key.pemuser@host  # Connect to a remote host via SSH using a specific private key
scp file.txt user@host:/path/   # Copy file.txt to a remote host via SCP
rsync -avz source/ dest/ # Synchronize files from source/ to dest/ using rsync
sudo apt update # Update package lists on Debian-based systems
sudo apt upgrade -y # Upgrade all packages on Debian-based systems
sudo apt install package    -y # Install a package on Debian-based systems
sudo apt remove package 
sudo apt autoremove     # Remove unnecessary packages and dependencies on Debian-based systems
apt search keyword # Search for packages related to the keyword on Debian-based systems
apt show package # Display detailed information about a package on Debian-based systems
sudo dnf update # Update package lists on Red Hat-based systems
sudo dnf install package 
sudo dnf remove package
sudo dnf autoremove # Remove unnecessary packages and dependencies on Red Hat-based systems
dnf search keyword # Search for packages related to the keyword on Red Hat-based systems
dnf info package # Display detailed information about a package on Red Hat-based systems
sudo systemctl starrt nginx
sudo systemctl stop nginx 
sudo systemctl  restart nginx
sudo systemctl status nginx 
sudo systemctl reload nginx
sudo systeemctl enable nginx
sudo  systemctl disable nginx
jouranlctl -u nginx -f # Follow real-time logs for the nginx service
crontab -e # Edit the crontab file for the current user
crontab -l # List the current user's crontab entries
0 2 * * * /path/to/backup.sh # Example cron job to run backup.sh daily at 2 AM
df -h # Display disk space usage in a human-readable format
du -sh /path/* 
lsblk 
sudo mount /dev/sdb1 /mnt   # Mount the /dev/sdb1 device to /mnt
sudo unmount /mnt # Unmount the /mnt directory
free -h 
uptime 
dmesg | tail -n 20 # Display the last 20 lines of kernel messages
uname -a 
set -euo pipefail
backup_dir="/backup"
log_file="/var/log/backup.log"
date=$(date +%Y%m%d -%H%M%S)
log(){
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $*"| tee -a "$log_file" # Log messages with timestamp

}
error_exit(){
    log "error:$1"
    exit 1
}
main(){
    log "script started "
    if [[ $EUID -ne 0 ]]:then 
        error_exit "this script must be run as root"
    fi 
    log "script completed successfully"

}
main "$@"
ssh-keygen -t ed25519  -C "you@email.com" # Generate a new SSH key pair using the Ed25519 algorithm with a comment
ssh-copy-id user@host 
chmod 600 ~/.ssh/id_rsa # Set permissions to rw------- for the private SSH key
chmod 644 ~/.ssh/id_rsa.pub # Set permissions to rw-r--r-- for
chmod 700 ~/.ssh # Set permissions to rwxr-xr-x for the .ssh directory
sudo ufw enable # Enable the UFW firewall
sudo uffw allow 22/tcp # Allow incoming SSH connections on port 22
sudo ufw allow 80/tcp # Allow incoming HTTP connections on port 80
sudo ufw allow 443/tcp # Allow incoming HTTPS connections on port 443
sudo ufw status     # Display the status of the UFW firewall
sudo ss -tuln 
sudo netstat -tuln
sudo kill -9 $(sudo lsof -t -i :8080 ) # Kill the process listening on port 8080
find /path -name "*.log" -type  f -size +100M -exec ls -ls {} \;2>/dev/null |sort -k  5 -hr |  head -10 # Find the top 10 largest .log files over 100MB in /path and list them with detailed information
for file in *.txt; do mv  "$file" "${file%.txt }.bak "; done # rename all .txt files in the current directory to .bak extension
iostat -x  1 
ss -tan | awk '{print $1}' |sort | uniq -c  # Count unique TCP connection states
ps aux --sort=-%mem | head  -10  
#write comments for the following  ones  in aws commands 
--profile <name>#write comments for this aws  command 
--output <style>
--help 
--endpoint-url <url>
--region
--version
#confihuration commands
aws configure 
aws configure sso 
aws configure list 
aws configure set <key> <value>
aws  configure get key  
aws configure --profile <name>
aws configure list-profiles
aws sts get-caller-identity
#IAM  commands
aws iam list-users 
aws  iam list-groups 
aws iam list-roles
aws iam list-policies
aws iam create-user --user-name <name>
aws iam create-group --group-name <name> 
aws iam create-role --role-name <name>  --assume-role-policy-document  <policy>
aws iam create-policy --policy-name <name> --policy-document <policy>
#EC2 commands
aws ec2-desribe instances 
aws ec2 run-instances --image-d <id>  --instance-ype <type> 
aws ec2 terminate-instances --instance-ids <id> 
aws ec2 stop-instances --instance-ids <id> #stop instances 
aws ec2 start-instances --instance-ids <id> #start instances
#eks commands
aws eks list-clusters
aws eks create-cluster --name <name> --role-arn <arn> --resources -vpc-config subnetIds=<subnet-ids>,securityGroupIds=<sg-ids>
aws eks descibe-cluster --name <name>
aws eks  delete-cluster --name <name> 
#rds commands 
aws rds descibe -db-instances 
aws rds describe -db-clusters 
aws rds create -db-cluster-snapshot 
#s3 commands
aws s3 ls 
aws s3 ls s3://<bucket>
aws s3 mb s3://<bucket>
aws s3 rb   s3://<bucket>
aws s3 cp  <src> <dest>
aws s3 rm s3://<bucket>/<object>
aws s3 sync  s3://bucket <dir>
aws s3 sync <dir> s3://<bucket>
#other commands 
list buckets 
list objects in bucket 
copy a file from /to s3
delete an object 
sync a bucket to a local dir 
sync  a local directory  to an s3 bucket 
aws --version
aws help
aws <command> --help
description 
show version
show help for a  specific command
#docker commands 
docker run <image> 
docker run  -p 8080:80 <image>
docker run -d <image>
docker run -v  <host>:<contanier> <image>
doceker ps 
docker ps --all 
docker logs  <container-name>
docker logs -f <container-name>
docker stop <container-name>
docker start <container-name>
docker rm <container-name>
#executing  docker commands inside a running  conatainer 
docker exec -it <container-name> bash
#image commands 
docker build -t <image> .
docker images 
docker rmi <image-id>
docker login
docker logout
docker push <image>
docker pull <image> 
docker search <image>
docker system df 
docker system prune 
docker system prune -a 
docker compose 
docker compose up 
docker compose up -d # Start services in detached mode
docker compose up --build 
docker compose stopp
docker compose start
docker compose down
docker compose ps 
docker compose logs 
docker compose logs <service-name>
docker compose logs -f 
docker compose pull 
dcoker compose build 
docker compose buil --pull
FROM  <image> set the base image for the Dockerfile
RUN ["exec","param1","param2"] execute commands in the container during build
CMD ["exec","param1","param2"]
ENTRYPOINT ["exec","pram1","param2"]
ENV <key> =<value>  
EXPOSE <port>
COPY <src> <dest> #copy files from src to dest
ADD <src> <dest> #copy files from src to dest
WORKDIR <path> #set the working directory inside the container
COPY --from=<name> <src> <dest> 
VOLUME <path>
USER <user>
ARG <name>
ARG <name>=<default> 
label <key>=<value>
HEALTHCHECK <command>
services:
    service1:
        image:<image>
        build: . 
        volumes:
            - ./host/path:/container/path
        ports:
            - "8080:80"
        environment:
            - key=value 
services.<name>.build:
services.<name>.image:
services.<name>.build.context:
servicees .<name>.build.target:
sservices.<name>.build.arguments:
services.<name>.command:
services.<name>.entrypoint:
services.<name>.volumes:
services.<name>.ports:
services.<name>.encvironment:
services.<name>.restart:
services.<name>.scale:
services.<name>.networks:
services.<name>.depends.on:
services.<name>.labels:
networks.<name>.driver:
networks A
networks.<name>.external:
volumes A
volumes.<name>.name:
volumes.<name>.driver:
configs A
secrets A
#git commands
git init
git clone url 
git log
git log --oneline 
git show
git shortlog
git blame <file>
git status
git  add <file>
git add  -p 
git diff
git diff --staged
git commit 
git commit -m "first commit"
git  commit --amend
git reset HEAD~1
git checkout .. <file>
git  branch 
git branch -r 
gkit branch <name>
git git checkout <branch-name>
git checkout -b <branch>
git  merge <branch>
gti branch -d <branch>
git tag
git tag <tag>
git tag -a <tag> 
gti tag  -s <tag>
git tag -d <tag>
git show tag
git remote -v
git remote add origin url
git fetch <remote>
git  pull <remote>
git pull  <remote> <branch>
git push <remote> <branch>
git push  <remote> --delete <branch>
git  push <remote> --tags 
git stash
git stash list
git stash pop 
git staash apply
git stash drop 
git stash clear 
#helm 
--kube-context <name>
--namespace <name>
helm   repo add <name> <url>
helm  repo list
helm repo update
helm   repo  remove <name>
helm  search repo 
helm  search repo <keyword>
helm install <name> <chart>
helm install <chart> --generate-name
helm  install <name> <chart>  --namespace <namespace>
helm install <name>  <chart> --values <file>
helm install <name> <chart> --set <key>=<value>
helm install <name> <chart> --values  <file>
helm install <name> <chart> --dry-run --debug 
helm install <name> <chart>  --verify
helm install <name> <chart> --dependency-update 
helm uninstall <name> 
helm uninstall <name> --keep-history 
helm list 
helm list --all-namespaces 
helm  ist -l <label>=<value>
helm list --date
helm list  --(pending |faiiled| deployed| supreseded|uninstalled)
helm status <name>
helm upgrade <name> <chart>
helm upgrade <name> <chart> --atomic
helm  upgrade <name> <chart> --dependancy-update
helm upgrade <name> <chart> --version <version>
helm upgrade <name> <chart> --set <key>=<value>
helm  rollback <release> <version>
helm create <name >
helm  package <chart-path>
helm  lint <chart>
helm show all <chart>
helm show   values <chart>
helm template <name> <chart>
helm  template <name> <chart>  --set <key>=/<value>
pipeline{
    agent any
    environment{
        docker_registry="docker.io"
        dcoker_credentials="dockerhub-credentials"
        image_naame="${docker_registry}/myapp:${env.BUILD_NUMBER}"
        image_tag="myapp:${env.BUILD_NUMBER}"
        app_name="myapp"
        namespace="production"
        aws_region="us-east-1"
        aws_credentials="aws-credentials"
    }
    parameters{
        choice(
            name:'ENVIRONMENT',
            choices:['development','staging','production'],
            description:'Select the deployment environment'
        )
        booleanParam(
            name:'RUN_TESTS',
            defaultValue:true,
            description:'Whether to run tests before deployment'
        )
        string(
            name:'branch_name',
            defaultValue:'main',
            description:'Git branch to build from'
        )
        }
    }
}
- name:configure web servers
    hosts:webservers
    become:yes
    gather_facts:yes
    vars:
    app_name:my_app
    app_port:8080
    nodejs_version:18
    deploy_user:appuser
    app_directory:/opt/{{ app_name }}
    vars_files
    -vars/common.yaml
    -vars/{{ansible_ditribution}}.yml
    