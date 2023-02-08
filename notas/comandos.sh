  
  140  git remote add origin https://github.com/IvanciniGT/cursoJava9.git 
  141  git config --global credential.helper store
  142  git push -u origin master
  143  df -h
  144  df -h
  145  lsblk
  146  sudo growpart /dev/nvme0n1 1
  147  lsblk
  148  df -h
  149  sudo resize2fs /dev/nvme0n1p1
  150  df -h
  151  cd curso/
  152  git add .&& git commit -m 'Install' && git push
  153  cd Profesor
  154  git pull
  155  cd curso
  156  git remote get-url origin
  157  clear
  158  sudo apt update
  159  sudo apt -y upgrade
  160  sudo apt -y install curl apt-transport-https
  161  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
  162  # echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  163  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
  164  free
  165  cat /etc/fstab
  166  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  167  sudo swapoff -a
  168  free
  169  sudo modprobe overlay
  170  sudo modprobe br_netfilter
  171  sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
  172  net.bridge.bridge-nf-call-ip6tables = 1
  173  net.bridge.bridge-nf-call-iptables = 1
  174  net.ipv4.ip_forward = 1
  175  EOF
  176  sudo sysctl --system
  177  export OS=xUbuntu_18.04
  178  export CRIO_VERSION=1.23
  179  echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
  180  echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
  181  curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
  182  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
  183  sudo apt update
  184  sudo apt install cri-o cri-o-runc -y
  185  systemctl status crio
  186  sudo modprobe overlay
  187  sudo modprobe br_netfilter
  188  sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
  189  net.bridge.bridge-nf-call-ip6tables = 1
  190  net.bridge.bridge-nf-call-iptables = 1
  191  net.ipv4.ip_forward = 1
  192  EOF
  193  sudo sysctl --system
  194  export OS=xUbuntu_18.04
  195  export CRIO_VERSION=1.23
  196  echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
  197  echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
  198  curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
  199  curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -
  200  sudo apt update
  201  sudo apt install cri-o cri-o-runc -y
  202  apt-cache policy cri-o
  203  sudo systemctl daemon-reload
  204  systemctl status crio
  205  sudo systemctl enable crio --now
  206  systemctl status crio
  207  clear
  208  systemctl status crio
  209  sudo apt update
  210  sudo apt -y install vim git curl wget kubelet kubeadm kubectl
  211  kubectl version --client && kubeadm version
  212  sudo kubeadm init  --pod-network-cidr=10.10.0.0/16 --cri-socket=unix:///var/run/crio/crio.sock
  213  systemctl status kubelet
  214  mkdir -p $HOME/.kube
  215  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  216  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  217  kubectl cluster-info
  218  clear
  219  kubectl get nodes
  220  kubectl taint nodes --all node-role.kubernetes.io/control-plane-
  221  curl https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml -O
  222  kubectl apply -f calico.yaml
  223  kubectl get nodes -o wide
  224  kubectl get pods -n kube-system
  225  kubectl get service
  226  kubectl get services
  227  kubectl get svc
  228  clear
  229  kubectl get ns
  230  kubectl get pods
  231  kubectl get pods -n kube-system
  232  kubectl get pods --all-namespaces
  233  clear
  234  kubectl get pods -n kube-system
  235  kubectl get pods -n kube-system -o wide
  236  kubectl get deployments -n kube-system -o wide
  237  kubectl get deployments -n kube-system
  238  clear
  239  cat /etc/netplan/50-cloud-init.yaml 
  240  kubectl apply -f 0-namespace.yaml 
  241  kubectl get ns
  242  clear
  243  clear
  244  docker images
  245  docker inspect nginx
  246  ls /etc/containers/
  247  cat /etc/containers/registries.conf
  248  clear
  249  docker image pull docker.io/nginx:latest
  250  docker image pull docker.io/httpd:latest
  251  docker images
  252  docker rmi $(docker images .q)
  253  docker rmi $(docker images -q)
  254  docker rmi $(docker images -q) -f
  255  clear
  256  docker images
  257  docker image pull docker.io/httpd:latest
  258  #docker image pull nginx:latest
  259  cat /etc/containers/registries.conf
  260  clear
  261  docker images
  262  docker inspect httpd
  263  clear
  264  docker pull elasticsearch
  265  cd curso/despliegues/
  266  kubectl apply -f 1-pod.yaml -n ivan
  267  kubectl get pods -n ivan
  268  kubectl get pods -n ivan -o wide
  269  curl 10.10.234.129
  270  ps -eaf 
  271  ps -eaf | grep nginx
  272  kill -9 9656
  273  sudo kill -9 9656
  274  kubectl get pods -n ivan -o wide
  275  kubectl delete pod pod-ivan -n ivan
  276  kubectl get pods -n ivan -o wide
  277  kubectl apply -f 2-deployment.yaml -n ivan
  278  kubectl apply -f 2-deployment.yaml -n ivan
  279  kubectl get deployments -n ivan
  280  kubectl get pods .n ivan
  281  kubectl get pods -n ivan
  282  git add .&& git commit -m 'Install' && git push
  283  kubectl apply -f 2-deployment.yaml -n ivan
  284  kubectl get pods -n ivan
  285  kubectl delete pod deployment-ivan-7c956d94d4-j2pm6 -n ivan
  286  kubectl get pods -n ivan
  287  kubectl delete pod deployment-ivan-7c956d94d4-4blvw -n ivan
  288  kubectl get pods -n ivan
  289  kubectl scale deployment deployment-ivan -n ivan --replicas 20
  290  kubectl get pods -n ivan
  291  kubectl get pods -n ivan
  292  kubectl scale deployment deployment-ivan -n ivan --replicas 2
  293  kubectl get pods -n ivan
  294  kubectl get pods -n ivan
  295  kubectl get pods -n ivan
  296  kubectl get pods -n ivan
  297  kubectl get pods -n ivan
  298  kubectl get pods -n ivan
  299  kubectl get pods -n ivan
  300  kubectl get pods -n ivan
  301  kubectl get pods -n ivan -o wide
  302  curl 10.10.234.136 
  303  clear
  304  kubectl apply -f 3-service.yaml -n ivan
  305  kubectl get services -n ivan
  306  curl 10.98.201.135
  307  clear
  308  kubectl get services -n ivan
  309  kubectl describe service servicio-ivan -n ivan
  310  kubectl get pods -n ivan -o wide
  311  kubectl scale deployment deployment-ivan -n ivan --replicas 20
  312  kubectl get pods -n ivan -o wide
  313  kubectl get pods -n ivan
  314  kubectl get pods -n ivan
  315  kubectl get pods -n ivan
  316  kubectl get pods -n ivan
  317  kubectl describe service servicio-ivan -n ivan
  318  kubectl get  service servicio-ivan -n ivan -o jaml
  319  kubectl get  service servicio-ivan -n ivan -o json
  320  kubectl describe service servicio-ivan -n ivan
  321  kubectl scale deployment deployment-ivan -n ivan --replicas 2
  322  kubectl describe service servicio-ivan -n ivan
  323  kubectl get  service servicio-ivan -
  324  kubectl get pods -n ivan
  325  kubectl exec deployment-ivan-7c956d94d4-xrngd -c contenedor1 -n ivan -- bash
  326  kubectl exec -it deployment-ivan-7c956d94d4-xrngd -c contenedor1 -n ivan -- bash
  327  kubectl exec -it deployment-ivan-7c956d94d4-xrngd  -n ivan -- bash
  328  kubectl get pods -n ivan
  329  kubectl exec -it deployment-ivan-7c956d94d4-zmfpb  -n ivan -- bash
  330  kubectl get pods -n ivan -o wide
  331  curl 10.10.234.136
  332  curl 10.10.234.134
  333  kubectl get svc -n ivan
  334  curl 10.98.201.135
  335  curl 10.98.201.135
  336  curl 10.98.201.135
  337  curl 10.98.201.135
  338  curl 10.98.201.135
  339  curl 10.98.201.135
  340  curl 10.98.201.135
  341  curl 10.98.201.135
  342  curl 10.98.201.135
  343  curl 10.98.201.135
  344  curl 10.98.201.135
  345  curl 10.98.201.135
  346  curl 10.98.201.135
  347  curl 10.98.201.135
  348  curl 10.98.201.135
  349  curl 10.98.201.135
  350  curl 10.98.201.135
  351  curl 10.98.201.135
  352  curl 10.98.201.135
  353  curl 10.98.201.135
  354  curl 10.98.201.135
  355  curl 10.98.201.135
  356  curl 10.98.201.135
  357  curl 10.98.201.135
  358  curl 10.98.201.135
  359  curl 10.98.201.135
  360  kubectl scale deployment deployment-ivan -n ivan --replicas 3
  361  curl 10.98.201.135
  362  curl 10.98.201.135
  363  curl 10.98.201.135
  364  curl 10.98.201.135
  365  curl 10.98.201.135
  366  curl 10.98.201.135
  367  curl 10.98.201.135
  368  curl 10.98.201.135
  369  curl 10.98.201.135
  370  curl 10.98.201.135
  371  curl 10.98.201.135
  372  curl 10.98.201.135
  373  curl 10.98.201.135
  374  curl 10.98.201.135
  375  curl 10.98.201.135
  376  curl 10.98.201.135
  377  curl 10.98.201.135
  378  curl 10.98.201.135
  379  curl servicio-ivan
  380  clear
  381  kubectl apply -f 3-service.yaml -n ivan
  382  kubectl get svc -n ivan
  383  curl locahost:30080
  384  curl localhost:30080
  385  curl localhost:30080
  386  curl localhost:30080
  387  curl ifconfig.me
  388  kubectl get pods -n ivan
  389  kubectl delete pod deployment-ivan-7c956d94d4-kd9gx -n ivan
  390  git add .&& git commit -m 'Install' && git push
  391  history >> comandos.sh
