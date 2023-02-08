# SERVICES

## CLUSTER IP

IP DE BALANCEO DE CARGA + Entrada en DNS de Kubernetes

## NODE PORT

Cluster IP + Exposición de puertos (>30000) a nivel de cada HOST

## LOAD BALANCER

Node Port + Gestión del balanceador de carga externo

---

Tenemos 3 tipos de servicios.

Vamos a tener un cluster para nuestro entornos de producción.
Cuántas cosas / programas vamos a tener en ese entorno de producción? MONTONONES

Muchos servicios. 

Al final, cada programa que monte y sea accesible por un puerto, SIEMPRE LLEVA UN SERVICIO (BALANCEO) delante.
Eso es lo que nos da: La ESCALABILIDAD y la ALTA DISPONIBILIDAD

## Estimación:

Qué cantidad de servicios vamos a tener de cada tipo?

- Cluster IP        IPs internas al cluster. Son programas que no necesite ser accedidos desde fuera del cluster:
                        BBDD, Mensajería, Indexadores (ES), Microservicios 
- Node port         Publicar los servicios que deban ser accedidos desde el exterior - Me como yo la gestión del balanceador externo
                NINGUNO ! (casos muy raros + entornos de pruebas)
- Load balancer     Al ser NodePort, también me sirve para publicar servicios que deban ser accedidos desde el exterior, 
                        pero en estos NO ME COMO YO la configuración del balanceador externo               
                            Servidores web, Servidores de aplicaciones, APIs

                    Podría haber sido... pero no        En la realidad
                    
ClusterIP           +50%                                Todos menos 1
NodePort            0                                   0
LoadBalancer        -50%                                1 < - INGRESS CONTROLLER



        Usuarios ------- > INTERNET / INTRANET ----PROXY REVERSO---> SERVIDOR APPS 
        
                                                    INGRESS CONTROLLER
                                                    
                                                    
# Os dije que hay muchas distros de Kubernetes

En el curso vamos a montar un K8S (Cluster REAL de kubernetes)

En mi laptop NUNCA MONTARIA LO QUE VAMOS A MONTAR AHORA. Montaríamos MINIKUBE