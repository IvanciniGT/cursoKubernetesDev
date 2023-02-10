# Quiero instala wordpress

# A nivel arquiotectura que lleva eso:
- Wordpress > Apache + php
- BBDD: MariaDB

## Que cositas necesito configurar en Kubernetes?

√ Namespace 
√- PVC mariadb
√- PVC wordpress
√ Secret datos MariaDB
- Deployment Mariadb #StatefulSet
    - Ultima decente
- Deployment WP
    - Ultima decente que no lleve en el nombre ffp (no lleva apache)
√ Servicio Mariadb CLUSTERIP
√ Servicio Wordpress NodePort # Servicio CLUSTERIP + Ingress
√ PV mariadb
√ PV wordpress
- # HPA wordpress
