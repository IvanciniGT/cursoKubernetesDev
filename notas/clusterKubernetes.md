
# Un carrefour/alcampo                                                          # Entorno de producción / Kubernetes

    GERENTE !                                                                   KUBERNETES
        Si un carnicero se pone malo:                                           Si un pod se pone malo
            Llama a otro = HA                                                       CREAR OTRO 
            Otra persona con un determinado PERFIL                              IMAGEN DE CONTENEDOR / Plantilla POD
        
        Mediante un cluster Activo/Pasivo                                       Un cluster Activo/Pasivo

    CARTELES                                                                    DNS
        carnicería AQUI!                                                    
        pescadería ALLA!    

    SECCION Carnicería                                                          Servicio
        
        Numerito / Pantallita arriba que dice a quien le toca!                  Balanceo de carga

        Neveras en la trastienda                                                HDD 16Tbs y 5400rpm
            Carnes                                                                  Datos
        Neveras/Expositores                                                     SSD 1 Gb y Que va como un tiro !
            Carnes                                                                  Datos

        Puerto de trabajo 1:                                                    Máquina
            Recursos:
                Tabla                                                               Memoria RAM
                Cuchillos                                                           CPU
                Bascula                                                             GPU
            Carnicero 1                                                         Proceso > Contenedor > Pod

        Puerto de trabajo 2                                                     Máquina
            Carnicero 2                                                         Proceso > Contenedor > Pod
        Puerto de trabajo 3                                                     Máquina

    SECCION Cajas                                                               Servicio

        Cola única.... PANTALLITA: Caja 14                                      Balanceo de carga

        Puestos de trabajo1:  Una caja                                          Máquina
            Recursos
                Cinta transportadora
                Caja registradora...
                Billetes                                                            Datos
            Cajer@                                                              Proceso > Contenedor > Pod

    PUERTA de entrada al público... Por donde ENTRO al supermercado?            Proxy reverso - IngressController
        Reglar de redirección                                                       Reglas de configuración - Ingress
        SEGURIDAD !
    PUERTA para mercancias                                                      Proxy reverso - IngressController
        SEGURIDAD !
    PUERTA para empleados                                                       Proxy reverso - IngressController
    
    
---

    MenchuPC------------------------------------------------------------------->servidor1
    MenchuPC-------->proxy----------------------------------------------------->servidor1
        Navegador de Internet                                                       pagina1
            pagina1 del servidor 1

    Proxy: 
        - Proteger la identidad del solicitante
        - Realizando él la operación en su lugar
            Servidor1, no tiene ni puñetera idea de que fué menchu quien pidio los datos.
        
        Adicionalmente, esto me permite:
            - Realizar comprobaciones de seguridad en el contenido devuelto
            - Que menchu no joda en horas de trabajo y esté metida en el tiktok...
            
                                                                                Reglas de configuración
            
                                                                                soporte.miempresa.es -> IPS1
                                                                                miempresa.es/soporte -> IPS1
                                                                                servicios.miempresa.es -> IPS2
                                                                                
    MenchuPC -------Proxy------------------------------------------------------> Proxy reverso ------> servidor1
                                                                                               ------> servidor2
                                                                                               ------> servidor3

                                                                                IP1                     IPS1
                                                                                                        IPS2
                                                                                                        IPS3
        DNS:                                                                                                        
        ENTRADA: soporte.miempresa.es = IP1
        
        URL
            http://servidor:puerto/endpoint
            http://servidor1/pagina1.html
        
        
    Proxy reverso:
        - Para proteger la identidad de los servidores / destinos
        
Proxies reversos:
- apache httpd server (servidor web de apache) que puedo configurar como proxy reverso
- nginx (es un proxy reverso) que puedo configurar como servidor web.
- haproxy
- envoy

Cual se usa en Kubernetes, VAMOS A NECESITAR 1 o varios !
El que me dé la real GANA ! Y el día de mañana? también el que me dé la real gana... que será el mismo o no !

Cómo se llama en Kubernetes a los proxies reversos? INGRESS CONTROLLER

Todos esos ingress controlleres (proxies reversos) se configruan igual? NO
Para eso sirven los INGRESS: Reglas de configuración
Que Kubernetes traduce automaticamente al Proxy reverso de turno


---
                                                                        app1.produccion.es = 172.30.2.1
                                                                                DNS DE MI EMPRESA
    BALANCEADOR DE CARGA                                                          |                 app1.produccion.es
        |                                                                         |                    MenchuPC
        172.30.2.1                                                                |                       |
        |         :80 -> [172.30.1.1:30100, 172.30.1.2:30100, 172.30.1.3:30100]   |                  172.30.0.178
        |                                172.30.0.0 /16                           |                       |
-------------------------------------- RED DE LA EMPRESA --------------------------------------------------------------------------
    |                                                                                           
    |   (Cluster de Kubernetes)
    |
    |== 172.30.1.1 -- Maquina 1
    ||                  Linux
    ||                      NetFilter
    ||                          10.20.0.1:3000   -> [10.10.0.3:3306] round robin
    ||                          10.20.0.2:8080   -> [10.10.0.1:80, 10.10.0.2:80] round robin
    ||                          10.20.0.3:80     -> [10.10.0.4:80, 10.10.0.5:80] round robin
    ||                          172.30.1.1:30100 -> 10.20.0.3:80
    ||------------------ Pod 1 Apache ---- 10.10.0.1 
    ||                      configuración:
    ||                          BBDD=basedatos.produccion.es:3300 Funciona? SI, Resuelta esa comunicación? NO (1)
    ||
    ||------------------ Pod 1 INGRESS CONTROLLER (nginx) ---- 10.10.0.4
    ||                                  REGLA INGRESS       app1.produccion.es  ->  apaches.produccion.es
    ||
    |== 172.30.1.2 -- Maquina 2
    ||                  Linux
    ||                      NetFilter
    ||                          10.20.0.1:3000   -> [10.10.0.3:3306] round robin
    ||                          10.20.0.2:8080   -> [10.10.0.1:80, 10.10.0.2:80] round robin
    ||                          10.20.0.3:80     -> [10.10.0.4:80, 10.10.0.5:80] round robin
    ||                          172.30.1.2:30100 -> 10.20.0.3:80
    ||------------------ Pod 2 Apache ---- 10.10.0.2 
    ||                      configuración:
    ||                          BBDD=basedatos.produccion.es:3300 Funciona? SI, Resuelta esa comunicación? NO
    ||
    ||------------------ Pod 1 INGRESS CONTROLLER (nginx) ---- 10.10.0.5
    ||                                  REGLA INGRESS       app1.produccion.es  ->  apaches.produccion.es
    |== 172.30.1.3 -- Maquina 3
    ||                  Linux
    ||                      NetFilter
    ||                          10.20.0.1:3000   -> [10.10.0.3:3306] round robin
    ||                          10.20.0.2:8080   -> [10.10.0.1:80, 10.10.0.2:80] round robin
    ||                          10.20.0.3:80     -> [10.10.0.4:80, 10.10.0.5:80] round robin
    ||                          172.30.1.3:30100 -> 10.20.0.3:80
    ||------------------ Pod 1 MySQL  ---- 10.10.0.3:3306
    ||                       mysqld                  
    ||
    ||--- Servidor DNS
            basedatos.produccion.es -> IP FIJA -> 10.20.0.1     CLUSTER IP
            apaches.produccion.es   -> IP FIJA -> 10.20.0.2     CLUSTER IP
            ingress.micluster.es    -> IP FIJA -> 10.20.0.3     LOAD BALANCER > NODE PORT > CLUSTER IP
            
Automáticamente Kubernetes:
- Si uno de los pods cae, Kubernetes se encarga de ACTUALIZAR INMEDIATAMENTE TODAS LAS REGLAS DE NETFILTER DE TODOS LOS SERVICIOS QUE USARAN LA IP que se cayo
  para quitarla
- Y con las mismas, SI HAY NUEVOS PODS que puedan prestar un servicio, MODIFICA LAS REGLAS DE TODAS LAS MAQUINAS para incluir la nueva IP
- Kubernetes tiene un PROGRAMA instalado en cada SERVIDOR dedicado EXCLUSIVAMENTE a este trabajo
  Ese programa se ejecuta dentro de su propio contenedor / POD.. que por cierto... 
  el que haya configurado ese programa HABRA DEFINIDO UNA PLANTILLA DE POD... de la cual queremos una replica en cada NODO: DAEMONSET
  El programa se llama KUBE-PROXY

Red virtual del cluster de Kubernetes:
    Para los PODS:      10.10.0.0/16
    Para los SERVICIOS: 10.20.0.0/16

Quiero montar el WP... Quiero 1 sola instancia de la BBDD
                            Tipos de Contenedores? 1
                                Tipos de Pods? 1
                                    Plantilla de Pod    \   Deployment o Statefulset? DA IGUAL !
                                    1 replica           /       La diferencia es que las replicas usen cada una su 
                                                                volumen o uno en comun
                       Quiero 2 instancias del servidor web APACHE + PHP + WP
                            Tipos de Contenedores? 1
                                Tipos de Pod? 1
                                    Plantilla de Pod    \   Deployment
                                    2 replicas          /

(1) Por qué no está resuelto?
    1º Conozco a priori la IP del POD? NO. Haste que no hubiera creado el pod, no podría saber su IP
       Osea que tendría que hacer un despliegue por partes. Quiero eso? NO
    2º Esa siempre va a ser la IP del pod de la base de datos? NO. Por qué?
       Si el POD se CAE, se reinicia, se le va a asignar una IP nueva
       Si quiero cambiar de versión: BORRAR EL POD y crear uno nuevo... que mantendrá IP? NO
       Y si Kubernetes decide que la maquina 3 está muy petada... y mueve el POD de la BBDD a la máquina 5?
        Eso implica: Borra el pod de la máquina 3 y crea uno nuevo en la máquina 5... con IP nueva.
    NO PUEDO TRABAJAR CON UNA IP, al menos con esa IP
    
    Forma de resolverlo? 
    - Una IP QUE NO CAMBIA. Sería una buena forma? SI, es la UNICA FORMA !
    - Nombre FQDN en un DNS... y que IP registro en el DNS? 
        - Si registro en el DNS la IP del pod, qué problemas puedo tener?
            1º Si el pod cambia de IP, necesitaré:
                1 - Actualizar la entrada en el DNS
                2 - Rezar pero mucho a la virgencita / San Pancracio para que los apaches hagan un flush de su cache de DNS 
                    porque sino? van a seguir buscando al Antiguo       UPS !
        
        SI O SI NECESITO UNA IP FIJA!
        ES COMODO TRABAJAR CON IPs? No... adicionalmente querré un FQDN en un DNS
    
SERVICE
    Necesito una IP DE BALANCEO + entrada en un DNS de Kubernetes
    basedatos.produccion.es -> IP FIJA -> 10.20.0.1
    Qué es esa IP? 10.20.0.1... a donde lleva? A UN BALANCEO DE CARGA entre los PODs de BBDD


NETFILTER?

Es un componente del KERNEL DE LINUX
El componente por el que pasan TODOS LOS PAQUETES DE RED que fluyan a través del HOST

IPTABLES > dar reglas a netfilter 



----

Plantilla 
    Todos los pods que generes desde esta plantilla, ponles unas etiquetas: LABELS

Servicio
    Ceea una IP FIJA de balanceo (y la das de alta en el DNS de kubernetes con el nombre XXXX)
    Y balanceas entre todos los pods que tengasn las etiquetas: LABELS
    
    
Virtual Services -> ISTIO

- Aplicacion montada para el calculo de hipotecas a personas desde su casa V1
- Lo monto y de doy a ENTER con toda tranquilidad... Y después digo...
- Quiero que un 1% del trafico se redirija a la versión 2 y el 99% siga en la 1
    . Que va bien? Pasa a un 10%
        Sigue bien -> 20%
            Sigue   -> 100%
    Que no... al 0%

La app v2, tiene que estr diseñada de forma que permita esto!



## SERVICIOS DE KUBERNETES:

Hay 3 tipos de servicio en Kubernetes:

### CLUSTER IP

IP FIJA DE BALANCEO (a nivel de cluster) + ENTRADA EN DNS DE KUBERNETES 

> SI QUIERO QUE DESDE FUERA del cluster SE PUEDA ACCEDER AL SERVICIO, que + necesito ?
 
Una redirección de puertos a nivel de cada HOST, que vincule un puerto del host
    (en kubernetes es OBLIGATORIO que esté por encima del 30000)
A una IP de un servicio en su correspondiente puerto

### NODE PORT

Es un servicio de tipo CLUSTER IP + Redireccion de puertos a nivel de cada host (NAT)
                            
### LOAD BALANCER

Es un servicio NODE PORT con gestión automatica de un BALANCEADO externo al cluster.

Para poder usar servicios de tipo NODEPORT... necesito UN BALANCEADOR EXTERNO compatible con KUBERNETES

Cuando contrato un cluster de Kubernetes a algún cloud: AWS, AZURE, IBM CLOUD, los CLOUDS me "regalan" un BALANCEADO COMPATIBLE CON KUB.
out of the box !                                                                                 vv
                                                                                            previo paso por caja

Si estoy montando un cluster de Kubernetes en mis instalaciones (on premisses) tengo que montar el UNICO balanceador compatible con Kubernetes:
METALLB



## Esquema de comunicaciones

              ROUTE
          El despliegador         Admisnitardor del cluster                                                    El que despliega la aplicación
           |------------|  |----------------------------------------------------------------------------|    |---------------------------------------------------------------|
Menchu --> app1.prod.es ---> BALANCEADOR EXTERNO ----> MAQUINA n DEL CLUSTER    ----> BALANCEAO INTERNO  ---> POD IngressController ---> BALANCEO SERVICIO  ---> POD Servicio
            DNS Externo         Una maquina             Redirección                     Regla net filter        Regla INGRESS               DNS Interno
                                del cluster             Servicio IngressController
                                                        DNS Interno
                                                        
                                                        
A cada pod le asignamos una cantidad de recursos del host:

HOST: Maquina 7 del cluster:        128 Gbs RAM         32 Cores
    Nginx-IngressController         16 Gbs               4 cores            Será capaz de atender x peticiones/minuto
    MySQL                           32 Gbs               4 cores
    Apache WP                       12 Gbs               2 Cores
    Nginx-IngressController         16 Gbs               4 cores            Será capaz de atender x peticiones/minuto
    
Si tengo Y peticiones por minuto donde Y > x... el pod del Nginx no da abasto.... y necesito UN CLUSTER ACTIVO / ACTTIVO  (ESCALABILIDAD)


DE cara a determinar la configuración OPTIMA de una aplicación, necesito DATOS REALES de como funciona esa aplciación:
Y ESOS DATOS SOLO SOLO salen de un sitio: MONITORIZACION
             =========

Compo primera aproximación lo que me interesa es que el ratio entre RAM y COREs esté balanceado

nginx                              16Gbs                4 cores                 2 cores REQUIRE 16Gbs de RAM
                                                                                    + Escalar por que me quedo sin RAM
                                                                                    Hay 2 cores que no uso.
nginx                              16Gbs                4 cores
nginx                              16Gbs                4 cores
nginx                              16Gbs                4 cores
nginx                              16Gbs                4 cores
nginx                              16Gbs                4 cores
                                                                    12 cores del cluster SIN USO, pero bloqueados... JODIDO VOY 

En cualquier caso, como eso es complejo (MONITORIZACION INTENSIVA)
Kubernetes hace de las suyas para optimizar el uso de recursos y evitar destrozos de recursos al cluster

Cuando configuro un POD le asociamos:
    - El mínimo de CPU que quiero que se me garantice para el POD   - Reales \                          MAS CONSERVADOR
    - El mínimo de RAM que quiero que se me garantice para el POD   - Reales / Bien balanceados entre si
    - El maximo de CPU que querría, si hay hueco que me dejases     - Hasta el infinito y más allá 
    - El maximo de RAM que querría, si hay hueco que me dejases     - El mismo dato que arriba (LEY. NUNCA PONGO OTRA COSA. IMPRESCINDIBLE)
    
    