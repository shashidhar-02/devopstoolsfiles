##docker file to run npm nodejs application
FROM  alpine 
label maintainer="you name /email"
RUN apk  add --update nodejs npm 
WORKDIR ./app
COPY ./src
RUN  npm install
EXPOSE 3000
CMD["node","app.js"]
docker image build -t web.app:latest .
docker image ls
docker container runn -d  -p 3000:3000 web.app:latest
dcoker contianer ls
cd some_repo
echo "hello world">index.html
git  add index.html
git commit  -a   -m "first commit"
git   checkout -b dev
echo "dev branch ">index2.html
git add index2.html
git  commit -a  -m  "second  commmit "
git log
git  chekout master
git log
mkdir newdir && cd neewdir
git init
echo "hello">file.txt
git add >file.txt
git commit -a  -m "its my first commit"
git log
echo "mario"> newfile.txt
git add newfile.txt
git  commit -m "new file"
echo "mario && lugio">newfile.txt"
git  commit -a -m "added lugio"
git log
git rebase -i HEAD~2
pick 1st commit id 
pick 2nd commit id 
squash  2nd commit id
git log
git  rebase -i HEAD~2
git rebase -i --root iteratively
kubectl  run web  --image  registry.redhat.io/rhcl/httpd-24-rhel7 --port 80
kubectl exec web  --  ps
kubectl get po web
kubectl exec web --kill  1
kubectl get po web
kubectl exec web -- ps
kubectl run nginx --image:nginx --restart=never --port:80
kubectl get pods
cat >>web.yaml<<EOL
apiversion:apps/v1
kind:replicaset
metadata:
    name:web
    labels:
    app:somewebapp
    type:web
spec:
    replicas:2
    selector:
        matchLabels:
            app:web
            type:web
    template:
        metadata:
            labels:
                app:web
                type:web
        spec:
            containers:
            - name:web
                image:registry.redhat.io/rhcl/httpd-24-rhel7
                ports:
                - containerPort:80
EOL
kubectl apply -f web.yaml
kubectl get rs
kubectl   delete  pod   <pod-name>
kubectl delete -f web.yaml
kubectl get rs
cat >>web2.yaml<<EOL
apiversion:apps/v1
kind:replicaset
metadata:
    name:web
    Labels:
        app:somewebapp
        type:web
spec:
    replicas:2
    selector:
        matchLabels:
            app:web
            type:web
    template:
        metadata:
            labels:
                app:web
                type:web
            spec:
                containers:
                -name:httpd
                image:registry.redhat.io/rhcl/httpd-24-rhel-7
                ports:
                - containerPort:80
EOL
kubectl apply -f web2.yaml
kubectl get rs
kubectl delete -f web2.yaml  --cascade=orphan
kubectl get rs
kubectl et pods
kubectl apply -f web2.yaml
kubetcl describe rs web
cat >>web3.yaml<<EOL
apiVersion:apps/v1
kind:replicaset
metadata:
    name:web
    Labels:
        app:somewebapp
        type:web
spec:
    replicas:2
    selector:
        matchLabels:
            app:web
            type:web
    template:
        metadata:
            labels:
                app:web
                type:web
        spec:
            containers:
            - name:htppd
                image:registry.edhat.io/rhcl/httpd-24-rhel-7
                ports:
                - containerPort:80
EOL
kubectl apply -f wen3.yaml
kubectl get rs
kubectl get po >runningpods.txt
kubectl label pod <pod-name>
kubectl describe rs web
kubectl run nginx --image=nginx --restart=Never --port=80 --labels="app=nginx,env=dev"
cat<<EOF>nginx-svc.yaml
apiversion:v1
kind:Service
metadata:
    name:nginx-Service
spec:
    selector:
        app:dev-nginx
    ports:
    - protocol:TCP
        port:80
        targetPort:9372
EOF
kubectl apply -f nginx-svc.yaml 
##debug this yaml file below 
apiVersion: apps/v1
kind: Deployment
metadata:
        creationTimestamp: null 
            labels:
                app: dep
            name: dep
spec:
    replicas: 3
    selector:
    matchLabels:
        app: dep
    strategy: {}
    template:
    metadata:
            creationTimestamp: null
        labels:
            app: dep
    spec:
        containers:
        - image: redis
        name: redis
        resources: {}
status: {}
##Run a pod called "yay" with the image "python" and resources request of 64Mi memory and 250m CPU
kubectl run yay --image=python --requests='memory=64Mi,cpu=250m' --restart=never
kubectl get  pods
kubectl run  nginx-rtest --image=nginx
kubectl delete pod nginx-test
kubectl  get pods  -n kube-system
kubectl get -A |grep etc
kubectl get pods -A
kubectl get pods --all -namespaces
apiversion:v1
kind:pod
metadata:
    name:test
spec:
    containers:
    - image:alpine
    - name :alpine
    - image : nginx-unnprivileged
    - name :nginx-unnprivileged
EOL
kubectl create -f pod.yaml
kubectl  run some-pod   --image=redis -o yaml ==dry-run=client>pod.yaml
kubectl run some-pod -o yaml  --image nginx-unnprivileged  --dry-run=client >pod.yaml
lubectl create -f pod.yaml --dry-run
lubectl get pod  <pod-nam>| grep  -i image
kuubectl run remo  --image=redis:latest  -l year=2017
kubectl  get  pod --show-labels
kubectl delete pod namespace
kubectl  get pod -l env=prod
kubectl get pod -l env=prod | wc -l
k run some-pod --iimage=python  --commnand sleep 2017 --restart=Never --dry-run=client -o yaml >static-pod.yaml
kubectll desccribe pod  <pod-name>
#for specific conatainer 
kubectl describe podd <pod-name> -c<container-name>
kubectl get events 
kubectl describe pod < pod-name>
kbectl  get pod-name  -o wide
kubectl get pod -A | grep scheduler
kuectl logs pod-name
kubectl logs  pod-name -c container-name
kubectl  get  namespaces
kubectl create namespace  alle
kubectl get nss --no-headers | wc -l
kubectl get  pod -n dev
kubectl  create  ns  dev
kubectl  run  kratos --image=redis -n dev
kubectl get pod -A | grep  atreus
kuubectl get  nodes 
kubectl  get -o json>some-nodes.json
kubectl  get  no minikube  --show-labels
kubectl expose pod web --port=1991  --name=sevi 
kubectl describe  svc <service-name>
app-service .dev.svc.cluster.local
apiversion:v1
kind:Service
metadata:
        name:jabulik-service
        namespace:dev
spec:
    selector:
        app:jabulik-app
    ports:
    - protocol:TCP
        port:8080
        targetPort:8080
        type:NodePort
        nodePort:30000
EOL
kubectl expose  deployemnt jabulik --name-jaabulik-service  --traget-port=8080 ==type=NodePort  --port=8080 --dry-run=client -o yaml>svc.yaml
kubectl apply  -f svc.yaml
kubectl get rs
kubectl descibe  rs repli | grep  -i image
kubectl  descibe rs repli | grep -i "pod-status"
kubectl delete rs rori
kubectl edit rs rori
kubectl scale rs rori --replicas=5
kubectl scale rs rori  --replicas=1
apiVersion: apps/v1
kind: replicaset
metadata:
    name:redis
    labels:
        app:redis
        tier: cache
spec:
    selector:
        matchLabels:
            app:redis
            tier:cache
        template:
            metadata:
                labels:
                    tier:cachy
            spec:
                containers:
                - name : redis
                    image:redis
                    ports:
                    - containerPort:6379
EOL
kubectl get deploy 
kubectl describe deploy <deploy-name> | grep  image
kubectl create  deployment dep  -o yaml --image=redis --dry-run=client  --replicas=3 -o yaml>deploy.yaml
kubectl delete deploy depdep
kubectl   create deploy  pluck -o yaml --image=redis  --replicas=5>deploy.yaml
kubectl create deploy  blufer   --image=python --dry-run=client --replicas=3 -o yaml>>deploy.yaml
spec:
    affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
            - key: blufer
            operator: Exists
affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorsTerms:
        - matchExpresions:
            - key  :region 
            operator:In 
            values:
            - asia
            - emea
affinity:
    nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
            - key: region
            operator:NotIn
            values:
            - neverland
kubectl get pods -l  app=web
kubectl get  pods -l env=prod,type=web
kubbectl  label nodes some-nodes hw=max 
kubectl run  some-pod --image=redis  --dry-run=client -o yaml >pod.yaml
spec:
    nodeSelector:
        hw=max
EOL
kubectl  apply -f pod.yaml
kubectl describe node master | grep -i taints
kubectl  taint node minikube app=web:NoScedule
kubectl  describe  node minikube | grep -i  taints
kubectl describe pod some-pod | grep -i limits
kubectl run yay --image=python  --requests=memory=64Mi,cpu=250m   --dry-run=client -o yaml>pod.yaml
kubectl  run yay2 --image=python --requests=memory=64Mi,cpu=250m --limits=memory=128Mi,cpu=500m --dry-run=client -o yaml>pod.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/dowmload/componenets.yaml
kubectl htop nodes
kubectl top nodes
kubectl top pods 
kubectl top pods --all-namespaces
spec:
    containers:
    - command:
        - kube-scheduler:
        - -address=127.0.0.1
        -  -leader-elect=true
        -  --scheduler-name=some-custom-scheduler

kubectl get events
spec:
    schedulername:some-custom-scheduler
EOL
kubectl  run web  --image=registry.redhat.io/rhcl/httpd-24-rhel17
kubectl  exec  web -- ps
kuectl get pod web
kubectl exec  web  --kill 1
kubectl get po web
kubectl exec web --ps
kubeclt run nginx ---image=nginx --restart=Never 
kubectl get pods
apiversion:kustomize.config.k8s.io/v1beta1
kind:kustomization 
commonlabels:
    team-name:aces
resources:
--deployment.yaml
--sevice.yaml
kubectl  congfig   use-context
kubectl  aapi-resources
kubectl get nodes 
kubectl get noedes -o json >sone_nodes.json
kubectl get nodes   minikube --show-labels
kubectl  run mmy-pod  --image=nginx:alpine
kubectl  exec  web --ls
kubectl get pods -o wide
kubectl delete pod pod_name
kubectl get pods -l env=prod
kubbectl get pods
kubectl get pods --all -n namespaces
kubectl get pods -A | grep scheduler
kube-system namespace
kubectl get serviceaccounts -n kube-system
helm search hub 
helm install   --sset some_key=some_value
helm ls  || helm list 
helm roolback  release_name  revision_id
helm history  release_name
helm upgrade release_name chaart_name
kubectl  describe pod pod_name 
- effect :No Schedule
    key:app
    operator:Equal
    value:web
kubectl  taint  node  nodel  app=web:NoSchedule
kubectl  get pods -o wide 
print("hello world")
1>3  is true
1==1 is true 
4<1 - false
'two'>1 type-error exception 
from random  import choice 
print(choice(li))
def eat(self,food):
    print("nom nom nom ",food)
def bark(self):
    print(" woof  woof")
def add(x,y):
    return x+y
def subtract(x,y):
    return x-y
def multiply(x,y):
    return x*y
def divide(x,y):
    if y==0:
        return "cannot divide by zero"
    return x/y
def true_or_false():
    try:
        return True
    except:
        return False 
class myclass(object):
    x=1
    def_init(self,x):
        self.y=y
pipeline{
    agent any 
    options{timestamp()}
    stages{
        stage('build'){
            steps{
                checkout scm 
                sh 'npm ci'

            }

        }
        stage('test'){
            steps{
                sh 'npm test'
            }
            post{
                unsuccesful{
                    unstable('unit tests failed')

                }
            }
        }
        stage('deploy'){
            when{branch 'main'}
            steps{
                withcredentials([usernamepassword(credentials:'registry-creds',usernamevariable:'reg_user',passwordvariable:'re_pass')]){
                    sh 'docker login -u "$reg_user" -p "$reg_pass" registry.example.com'
                    sh 'docker buildd -t  regidtry.example.com/app:${BUILD_NUMBER} .'
                    SH 'docker push registry.example.com/app:${BUILD_NUMBER}'

                }
            }
        
        }
    }
    post{
        always{
            cleanWs()
        }
    }
}
kubernetes-deployemnt.yaml
apiversion:apps/v1
kind:Deployment
metadata:
    name:web-app
    labels:
        app:web-app
spec:
    replicas:3
    selectors:
        matchLabels:
            app:web-app
    template:
        metadata:
            Labels:
                app::web-app
        spec:
            containers:
            - name:web-app
                image:registry.example.com/app:latest
                ports:
                - containersPort:8080
                envFrom:
                - configMapRefs:
                    name:app-config
                - secretref:
                    name:db-credentials
                readinessProbe:
                    httpGet:
                        path:/health
                        port:8080
                    intialDelaySeconds:5
                    periodSeconds:10
                livenessprobe:
                    httpGet:
                        path:/health
                        port:8080
                    intialDelaySeconds:15
                    periodSeconds:20
variable  "vpc_id"{ type=string}
variable  "public_subnet_ids" {type = list(string)}
variable "taret_port"  { type= number  default=80}
variable  "tags" { type =map(string) deault={} }
resource "aws_lb" "this"{
    name = "lung-alb"
    load_balancer_type="application"
    internal= false
    subnets=vaar.public_siubnets_ids
    tags=var.tags
}
resource "aws_lb_listener" "this "{
    name="lung-alb-tg"
    port=var.target_port 
    protocol="HTTP"
    vpc_id=var.vpc_id
    health_check{
        path=/health

    }
    tags=var.tags
}
resource "aws_lb_target_group" "this"{
    load_balancer_arn=aws_lb.this.arn 
    port=  443
    protocol="HTTPS"
    ssl_policy="ELBSECURITYPOLICY-2016-08"
    certification_arn=aws_acm_certificcate.this.arn
    default_action{
        type="forward"
        target_group_arn=aws_lb_target_group.this.arn
    
    }

}
resource"aws_acm_certificate" "this"{
    domainn_name="example.com"
    validation_date="DNS"
    tags=var.tags
}
output  "alb_dns_name"{valuee= aws_lb.this.dns_name}
output "alb_arn"{value=aws_lb_target_group.this.arn}
--- 
- name =configure web server
    hosts: webservers
    become: true 
    roles:
    - role:  common 
    - role:  nginx
    tasks:
    - name :install  app  dependencies (debian only )
        apt: 
            name: "{{ item }}"
            state :present
            update_cache: true 
        loop:
        when : ansible_facts['os_family']== 'Debian'
        - name deploy application template 
        template:
            src:app.conf.j2
            dest:/etc/nginx.conf.d/app.conf
        notify: restart nginx 
handlers:
    - name: restart nginx
        service:
            name: nginx
            state: restarted
name: CI 
on: 
    push: 
        branches:[ main,develop]
    pull_request:
jobs:
    build-test:
        runs-on :ubuntu-latest
        strategy:
            matrix:
                node-version:[16,18]
        steps:
        - uses: actions/checkout@v2
        - uses : acrions/setup-node@v4
            with:
                node-version:${{matrix.node}}
            - run :npm ci
            - run : npm  test -- --coverage
            - uses :actions/upload-artifact@v4
                with:
                    name:coverage-${{matrix.node}}
                    path:coverage
    deploy:
        needs:build-test
        if : githubref == 'refs/heads/main'
        uses:org/reusable-ci/.github/workflows/deploy.yml@v2
        secrets:inherit
        with:
            image-name:registry.example.com/app
            filepath:.github.workflows/ci.yml
name :CI
on: 
    push: 
        branches:[ main,develop]
    pull_request:
jobs:
    build-test:
        runs-on :ubuntu-latest
        strategy:
            matrix:
                node-version:[16,18]
        steps:
        - uses: actions/checkout@v2
        - uses : acrions/setup-node@v4
            with:
                node-version:${{matrix.node}}
            - run :npm ci
            - run : npm  test -- --coverage
            - uses :actions/upload-artifact@v4
                with:
                    name:coverage-${{matrix.node}}
                    path:coverage
    deploy:
        needs:build-test
        if :githubref== 'reffs/heads/main'
        uses:org/reusable-ci/.github/workflows/deploy.yml@v2
        secrets:inherit
        with:
            image-name:registry.example.com/app
            filepath:.github.workflows/ci.yml
FROM alpine 
LABEL maintaainer="your name/email"
RUN  apk  add --updaate nodejs npm
WORKDIR /app
COPY ./src ./src
RUN npm install
EXPOSE 3000
CMD["node","app.js"]
docker imgage  build -t  web.app:latest .
docker image ls
docker  container run -d  -p  3000:3000 web.app:latest
docker container ls
git  checkout   master
mkdir  newdir &&  cd newdir  
git add file.txt
echo "mario && luigo ">newfile.txt
git  commit -a  -m "addded luigo"
git rebase -i HEAD~2
pick  <first-commit-id>
squash <second-commit-id>
apiversion:apps/v1
kind:deployment
metadata:
    name:web
    labels:
        app:somewebapp
        type:web
spec:
    replicas:2
    selector:
        matchlabels:
            app:web
            type:web
    template:
        metadata:
            labels:
                app:web
                type:web
        spec:
            containers:
            - name:web
                image:registry.redhat.io/rhcl/httpd-24-rhel17
                ports:
                -  comntainerPort:80
kubectl run nginx --image=nginx --restart=never --port=80
kubectl get pods --all -namespaces
kubectl  decribe pod <pod-name>
kubectl  create  deployment  dep --image=redis --dry-run=client  --replicas=3 -o yaml >deploy.yaml
kubectl  create deployment   quickapp  --image=nginx:latest  -port:80
kubectl expose deployemnt  quickapp  --type=Loadbalancer  --port:80
apiversion:apps/v1
kind:Deployment
metadata:
    name:web-app
    lables:
        app:web-app
spec:
    replicas:3
    selector:
        maatchlables:
            app:quick-app
        template:
            metadata:
                lables:
                    app:quick-app
            spec:
                containers:
                - name :quick-app
                    image:nginx:latest
                    ports:
                    - containerPort:80
apiversion:v1
kind:Service
metadata:
    name:quickapp 
spec:
    type:Loadbalancer
    ports:
    - port:80
    selector:
        app:quick-app
kubectl  apply -f  quickapp.yaml
kubectl get  deployemnts 
kubectl get pods 
kubectl  get serives 
minikiube  serive quickapp --url
sudo  lsof -i:8080
sudo netstat -tuln |  grep 8080
sudo ss  -tuln | grep 8080
find  /path/to/logs -name "*.log" -type  f -mtime +7 -exec rm{} \;
find /path/to/logs -name "*.log" -type f  -mtime  +7 exec ls -l {} \;
df -h  
du -h   --max-depth=1 /path | sort -hr 
find  /path  -type  f -size +100M -exec ls -lh {}  \;
top 
htop
iostat  -xz 1
iftop
FROm alpine 
RUN apk add  --update nodejs npm
WORKDIR /app
COPY ./src ./src
RUN npm  install
EXPOSE 3000
CMD["node","app.js"]
docker run -d -p 8080:8080 --memory="512m"  --name myapp image:tag
FROM node:16  AS  builder 
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY ..
RUN npm run build
#production image 
FROM node:16-alpine 
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY  --from=builder /app/node_modules ./node_modules 
EXPOSE 3000
CMD["node","dist/app.js"]
kubectl  deescribe  pod <pod-name>
kubectl logs <pod-name> -it  --image=busybox --share-processes  --copy-to=debug-pod
aapiversion:v1
kind:configMap
meatadata:
    name:app-config
data:
    APP_ENV:production
    LOG_level:info
apiversion:apps/v1
kind:Deployment
metadata:
    name:web-app
    lables:
        app:web-app
spec:
    replicas:3
    selector:
        matchlabels:
            app:web-app
    template:
        metadata:
            labels:
                app:web-app
        spec:
            containers:
            - name:web-app
                image:registry.example.com/app:latest
                ports:
                - containersPort:8080
                envFrom:
                - configMapRefs:
                    name:app-config
                - secretref:
                    name:db-credentials
                resources:
                    requests:
                        memory:"256mi"
                        cpu:"100m"
                    limits:
                        memory:"512mi"
                        cpu:"500m"
kubectl  set image deployment/my-app my-app:my-app:2.0 --record 
kubectl rollout  status  deployment/my-app
kubectl  rollout  undo  deployemnt/my-app
kubectl  edit deployment/my-app
git rebase -i HEAD~2 
pick<first-commit-id>
squash<second-comit-id>
git checkout -b  dev
echo "dev branch ">index2.html
git add index2.html 
git commit -a -m "second  commit"
git merge dev
kubectl desscribe pod <pod-name>
kubectl  logs  <pod-name>
kubectl logs <pod-name>  --previous 
kubectl get events
kubeclt    run yay --image=python  --requests='memory=64Mi,cpu=250m' --limits='memory=128Mi,cpu=500m'
ps aux
ps -ejH
ps -T -p 1234
ps -eo  pid,nlwp,cmd | sort  -rnk2
sudo  lsof -i:8080
sudo netstat -tuln  | grep 8080
sudo ss -tuln |grep  8080
sudo  fuser  8080/TCP
ls -i file.txt
df -i
find / -inum 12345
find / -type  d -exec sh -c  'echo  -n "{}";find "{}"| wc -l  \;|sort -k2 -nr | head
top 
htop
ps aux --sort=-%mem | head -10
uptime
pidstat -u 1 -p $(pgep process_name)
sar -u 5 3
chmod 755 script.sh 
chmod -R 755 directory/
chmod u=rwx,g=rx,o=rx script.sh
ls -l script.sh
find /var  -type f  -size +100M -exec ls -lh  {} \;
du -h --max-depth=1 /path | sort -hr
find /var/log -name "*.log" -type  f -mtime  +30 -print -exec -delete 
find /tmp -size  +500M -exec  rm -i {}\;
ln /path/to/original hardlink
ln -s /path/to/original symlink 
ls -l 
ls-i  file link
crontab -e
0 2 * * * /path/to/script.sh
0 15 * * 1 /path/to/weekly.sh
*/5 * * * * /path/to/fiveminnute.sh
0 0  1 * * /path/to/monthly.sh
cat >/etc/systemd/system/myscript.service<<EOL
[Unit]
Description=My Script Service
After=network.target
[Service]
ExecStart=/path/to/script.sh
User=yourusername
restartsec=5s
standardoutput=journal
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOL
systemctl daemon-reload
systemctl enable myapp
systemctl start myapp
free -h 
cat /proc/meminfo
ps aux --sort=-%mem | head -10
vmstat  5 3 
for file in /proc/*/status; do 
    awk '/VmSwap|Name /{print $2  "  "$3 }END {print ""}'$file
done | sort -k4 -nr | head -10
netstat -tuln
ss -tunapl 
netstat -nat | grep ESTABLISHED
netstat -anp | awk '{print $6} '| sort | uinq  -c | sort -n
lsblk
fdisk -l 
fdisk /dev/sdb 
mkfs.ext4/dev/sb1 
df -h 
mount /dev/sdb1 /mnt/data
getenforce 
sestatus 
chcon -t  httpd_sys_content_t /var/www/html/file.html
semannage fcontext -a -t htppd_sys_content_t "/var/www/html(./*)?"
restorecon  -Rv /var/www/html
aa-status
tail -f /var/log/syslog
tail -f /var/log/syslog /var/log/auth.log 
tail -f /var/log/syslog | grep error
grep -r  "ERROR" /var/log/
grep -B 3 -A  3 "ERROR " /var/log/syslog 
ulimit -a 
ulimit  -n 65536
cat>>/etc/security/limits.conf<<EOL
*  hard  nofile  65536
*  soft  nofile  65536
EOL
cat /proc/12354/limits 
juornalctl -b 
journalctl -b -1
dmesg
systemd-analyze blame
systemctl --failed
tar -cvf  archive.tar diirectory/file 
tar -czvf archive.tar.gz drectory/
tar -cjvf archive.tar.bz2  directory/
tar -xvf  archive.tar 
taar-xzvf archive.tar.gz -C /target/directory/
useradd -m -s /bin/bash username 
passwd username 
usermod -aG  sudo username 
usermod -aG wheel username 
echo "username  ALL=(ALL)ALL">etc/sudoers.d/username
chmod  440 /etc/sudoers.d/username 
cat /proc/1/status
cat /proc/cpuinfo 
ls /sys/class/net/
cat /sys/class/net/eth0/address
cat /sys/kernel/transparent_hugepage/enabled
chown user file.txt
chown -R user:group  file.txt
chown -R usser:group  /path/to/directory/
chgrp   group  file.txt
cp -p  source  dest
mount  /dev/sdb /mnt/data
unmount /mnt/data
df -h 
mount | grep  sdb
echoo "/dev/sdb1  /mnt/data ext4 defaults 0 2">>/etc/fstab
mount -a
du -hx  --max-depth=1 /mnt/data |sort -hr 
apt-get clean
dbf  clean all
jounalctl   --vacuum-time=2d 
apt autoremove 
package-cleanup --oldkernels --count=2
lvextend -r -L +10G /dev/mapper/vg-root
lsmod
modinfo e1000
modprobe  snd_hda_intel
modprobe -r snd_hda_intel 
echo "blacllist snd_hda_intel">>/etc/modprobe.d/blackkist-nouveau.conf
echo "snd_hda_intel">>/etc/module
tail /var/log/syslog
tail -f /var/log/syslog
tail -n 1000 /var/log/apache2/error.log
tail  -f  /var/log/syslog |grep --color ERROR 
tail -f --sleep-interval=1 /var/log/syslog
tail 10s /var/log/syslog
