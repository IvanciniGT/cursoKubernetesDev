# En el mundo de las máquians virtuales, el borrar una máquina virtual era una operación habitual?

NO se borraban

nginx version 1.21.1 -> nginx 1.21.2 ? Entrar en la máquina virtual y actualizar el software

# En el mundo de la contenedorización, el borrar un contenedor es una operación habitual?

SI, muy habitual. En qué escenarios?

- Cuando escalamos la aplicación en un entorno de producción: CLUSTER: 3 -> 10 -> 5 -> 15 -> 4
- Cuando a Kubernetes le venga bien:
  - Quizás kubernetes detecta que tiene una máquina física muy cargada de trabajo y otra más libre
    y decide "llevarse" un contenedor de una máquina a otra.
    "llevarse"= Borra el contenedor de una máquina y lo crea en otra.
- Cuando queremos actualizar el software

# Para que sirven los volumenes al trabajar con contenedores

- PERSISTENCIA DE DATOS: Para no perder los datos cuando un contenedor es eliminado
- COMPARTIR ARCHIVOS ENTRE CONTENEDORES: Los contenedores tienen su propio sistema de archivos aislado
                                         Les monto a los 2 el mismo volumen 
- PARA INYECTAR ARCHIVOS Y CARPETAS dentro de un contenedor:
  - Sobreescribir una configuración por defecto
  - Inyectar unos ficheros de mi app.
---

# Kubernetes WORKLOAD


Nos ayuda con la Alta disponibilidad y con la escalabilidad

En Kubernetes NO operamos con el concepto de CONTENEDOR.

En Kubernetes OPERAMOS con el concepto de POD.

# Qué es un POD?

Un POD en kubernetes es un conjunto de contenedores (puede ser un conjunto con 1 solo contenedor) que ...

- comparten configuración de red... y por ende IP... y entre ellos se hablan usando la palabra "localhost"


    POD A < Es el que tiene la dirección IP, que comparten todos sus contenedores
        contenedor1: nginx
                        |
                        V localhost:3306
                        |
        contenedor2: mariadb: 3306

- Los contenedores de un pod escalan juntos.

- Se despliegan en el mismo HOST, en la misma máquina física. 
    
  Como consecuencia de esto:
    - Pueden compartir volumenes de almacenamiento local NO PERSISTENTES ***


        contenedor: nginx (servidor web) -> log. ES IMPORTANTE ESE LOG?         SIEMPRE 
            log:
                - Sirven para identificar problemas
                - Recopilación de datos (análisis, business Intelligence)
                    - Un cuadro de mando del estado de mi servidor web:
                        - Cuantos acceso tengo ahora mismo  
                        - De que paises
                        - Que navegadores usan
                        - A qué hora accede la gente con más frecuencia
                        - A qué páginas
            El log, donde se debe almacenar? en el host? en el contenedor? 
            NO NUNCA, ya que:
                - Si se cae el host, lo pierdo
                - Si crece hasta el infinito me peta la máquina
            Donde se guarda esa información... de este web server y de otros 50 que tengo en el cluster:
            En una herramienta adecuada para ello: ELASTICSEARCH < KIBANA !


    nginx1  
        V
        access.log <<< ****
        ^
    filebeat        >>>>

    nginx2
        V
        access.log 
        ^
    filebeat        >>>>

    nginx3 - Contenedor A
        V
        access.log 
        ^
    filebeat - Contenedor B        >>>>         > KAFKA   <  Logstash    >>> ELASTIC SEARCH <<< Kibana
    ...
    nginx 50
        V
        access.log 
        ^
    filebeat        >>>>

    Los ficheros access.log no quiero que tengan persistencia
    Los datos de esos ficheros SI QUIERO QUE TENGAN PERSISTENCIA, en ELASTICSEARCH
        Cada vez que una linea se escriba en ese fichero, la voy a mandar a un KAFKA
        KAFKA??? Sistema de mensajería: Comunicación asíncrona!
            El receptor no tiene por quñe estar presente... ni responder al momento
        Y quien hace eso? Fluentd | Filebeat
        
    *** access.log     Que va a ir en un volumen, para que ambos (nginx-W, filebeat-R) puedan acceder
                        Me interesa que ese volumen esté en el mismo mismo o en un almacenamiento en RED?
                            LOCAL ya que...
                                1. Si lo monto en RED, la RED la peto... con 50 webserver mandando toda esa información
                                2. Cuanto tarda entonces el guardarse el dato y en leerse ese dato?
                        En la práctica eso lo hacemos mediante un TIPO de volumen muy especial que tiene KUBERNETES:
                            VOLUMEN EN MEMORIA RAM ---> /var/logs/nginx
                            Y lo que hacemos es configurar el nginx para que tenga 2 archivos rotados de 50kbs : No gasto más de 100kbs
                            Y el filebeat detrás como un perrito leyendo


Resumiendo:

Un pod es un conjunto de contenedores que:
- Escalan juntos
- Comparten configuración de red
- Se despliegan en el mismo host -> Podrán compartir volumenes de almacenamiento NO PERSISTENTE

Imaginad que quiero instalar un Wordpress:
- Servidor web: (httpd | nginx) + php + wordpress
- Base de datos: (MySQL | MariaDB)

1ª Meto esos programas en el mismo contenedor o en varios contenedores?
Varios, por qué? 
- Escalabilidad: 5 servidores web y solo 2 bbdd
- Los necesito en el mismo host? No necesariamente
- Cuando actualice, quiero actualizar TODO? No necesariamente 

Por lo tanto: 2 contenedores: 
Conteendor A: NGINX
Contenedor B: MySQL

En el mismo POD o en 2 PODS?

    OPCION 1                        OPCION 2
    POD_A                           POD_A       +       POD_B
    - nginx                         - nginx             - mysql
    - mysql
 
2 PODS: 
- Quiero que escalen juntos? NO -> Y si los pongo en el mismo pod, escalarían juntos.
- Quiero que instalen en el mismo host? NO -> Y si los pongo en el mismo pod, deben instalarse en el mismo host
- Necesito que compartan volumenes NO PERSISTENTES? NO

Quiero tener un filebeat leyendo los datos del nginx.
Quiero el nginx y el filebeat en el mismo contenedor? 
NO, ya que... el mantenimiento será más complejo
Si quiero actualizar solo el filebeat? necesito actualizar el nginx? NO

En el mismo POD o en 2 PODS?
En el mismo POD ya que:
- nginx y filebeat DEBEN ESCALAR SIMULTANEAMENTE
- nginx y filebeat DEBEN ESTAR EN EL MISMO HOST para poder compartir volumenes NO PERSISTENTES (archivo access.log)


    POD_A       +       POD_B
    - C1: nginx          - C3:mysql
    - C2: filebeat

    El C2, en términos de Kubernetes se llama CONTENEDOR SIDECAR


Cuando configuremos un POD en Kubernetes, que información habremos de suministrar:
- Qué contenedores van
- Qué volumenes comparten
- Y ya !

De cada contenedor:
- La imagen desde la que se crea ese contenedor
- Los puertos que usa ese contenedor
- El volumen al que accede y la RUTA de su FS local en la que se monta
- Variables de entorno que quiero darles valores propios
- ...

---

Nosotros lo que vamos a es a DAR INSTRUCCIONES A KUBERNETES acerca de cómo operar el entorno de producción
Ya no operamos el entorno de producción.
Yo ya no instalo nada.
Le pido a Kubernetes que despliegue cosas.... para un entorno de producción: HA + ESCALABILIDAD

Cuantos PODs voy a crear en un cluster de Kubernetes? NINGUNO !
Yo NO CREO PODS... será Kubernetes el que lo haga!

Cuantos PODs le voy a pedir a Kubernetes que monte en el cluster? NINGUNO !
El tema es que nosotros NO TRABAJAMOS CON PODs.
Un POD es un **conjunto de contendores**: Contenedor A y contenedor B

Yo quiero trabajar con PODs ni con CONTENEDORES. Qué pasa si el Contenedor A muere? o si el POD muere? Me quedo sin servicio.
Y eso es INACEPTABLE en PRODUCCION. No es mi portatil.

Con que vamos a trabajar? PLANTILLAS DE PODS

Le vamos a dar a KUBERNETES:
- Una plantilla de POD
- Cuántas copias de esa plantilla: PODS quiero que tenga siempre operativos
- Entre cuantás y cuantás copias de la PLANTILLA quiero que tenga operativas en base a ... la carga de trabajo

> Aquí te explico cómo desplegar un nginx...        PLANTILLA DE POD
> Ahora quiero que tengas siempre 5 de esos en funcionamiento
> Quiero que tengas entre 4 y 10 de esos

---

# Cómo se configuran estas cosas en Kubernetes:

Kubernetes tiene 3 configuraciones diferentes para hacer lo que os acabo de contar:

- DEPLOYMENT
  
  [ 1 Plantilla de POD + # de replicas de esa plantilla ] 

    que quiero que kubernetes me garantice SIEMPRE VAN A ESTAR EN FUNCIONAMIENTO

- STATEFULSET

  [ 1 Plantilla de POD + 1 Plantilla PVC + # de replicas de esa plantilla ] 
  
    que quiero que kubernetes me garantice SIEMPRE VAN A ESTAR EN FUNCIONAMIENTO

- DAEMONSET
 
  [ 1 plantilla de POD ] que quiero que Kubernetes monte una copia/replica en cada nodo del cluster y que me garantice que siempre estén en funcionamiento


Las configuraciones de kubernetes HABITUALMENTE las suministramos mediante FICHEROS... aunque no es la única forma.
En esos ficheros podré definir multitud de cosas.

---

INFRAESTRUCTURA es un gasto ! Por si misma NO APORTA NINGUN VALOR
    Yo, encargado de la infra SOY UN COSTE
SOFTWARE es un gasto        ! Por si mismo NO APORTA NINGUN VALOR
    Yo, desarrollador de un software, SOY UN COSTE
LO UNICO QUE APORTA VALOR: LOS DATOS !

---

*** NO NUNCA. En un entorno de producción NUNCA voy a guardar datos persistentes en LOCAL 
Si el LOCAL (máquina) se va a tomar por culo... mis datos se van con ella !

Los volumenes PERSISTENTES se almacenan EXTERNAMENTE AL CLUSTER, no en las máquinas del cluster.

---

Quiero montar mi Wordpress... para producción.... cúantas copias voy a quere de cada una de esas cosas. 
Me sirve con 1? 
    - HA:
        Tradicionalmente la hemos resuelto con Cluster:
            - Activo / Pasivo
                - 1 servicio en funcionamiento
                - Otro servicio en StandBy por si el primero se cae.... Por qué necesito éste?
                    No lo puedo montar, si el primero se cae... y así no consumo recursos de más?
                        Antiguamente no podía, ya que TARDABA MUCHO TIEMPO EN MONTARLA 
                        Kubernetes es capaz de hacer una copia/replica de una plantilla de POD en Menos de lo que digo TRIGO !
            - Activo / Activo
    - ESCALABILIDAD: Puede ser que con 1 copia no dé abasto para atender tantas peticiones como estoy recibiendo... y que necesite más



- Servidor WEB + el programa Wordpress x 5
- Servidor BBDD                        x 3

Maquina 1
    WEB1: IP1   POD 1 < Plantilla Web
                            VOLUMEN Ficheros WP
Maquina 2
    WEB2: IP2   POD 2 < Plantilla Web
Maquina 3
    WEB3: IP3   POD 3 < Plantilla Web
    BBDD1 IP_BBDD_1
      volumen 1       < Plantilla de Petición de volumen
Maquina 4
    WEB4: IP4   POD 4 < Plantilla Web
Maquina 5 
    BBDD2 IP_BBDD_2
      volumen 2       < Plantilla de Petición de volumen
    WEB5: IP5   POD 5 < Plantilla Web
Maquina 6 
    BBDD3 IP_BBDD_3   < Plantilla BBDD
      volumen 3       < Plantilla de Petición de volumen

Todas esas IPs y las de balanceo de qué red son?
- Ayer cuando trabajamo con Docker, vimos que docker crea una RED VIRTUAL dentro del HOST en la que pincha los contenedores
  Y les asigna IPs en esa red
- Luego os contaré que Kubernetes funciona parecido, pero a lo bestia... Monta una RED VIRTUAL con soperte FISICO sobre otra RED real
    VLAN

Cabina de almacenamiento, NFS:
    VOLUMEN Ficheros WP: informePDF

Plantilla Web
    Poder acceder al VOLUMEN Ficheros WP

Si quiero tener 5 copias del servidor web, a cual de ellas acceden los usuarios? IP_BALANCEO
A qué dirección IP acceden los usuarios?
    Necesitamos un balanceo de carga: IP_BALANCEO
    
Imaginad que un usuario accede a la WEB y se le manda a un servidor WEB WEB4
Y sube un fichero a la WEB: informe.pdf

Imagina que otro usuario accede a la WEB y se le manda a un servidor WEB WEB1
Y quiere consultar el informe.pdf.... podrá? Para que pueda que tiene que haber ocurrido? 
    Que el informe se haya guardado en un volumen compartido
    
El Wordpress (WEB1) quiere guardar el título de ese fichero en la BBDD, para poder hacer búsquedas en el futuro.
Cúantas BBDD tengo? 3
Qué IP le doy al WEB1 para que acceda a la BBDD?
De nuevo necesito OTRA IP DE BALANCEO, esta vez para la BBDD.IP_BALANCEO_BBDD
Cuando un WP intente acceder al a BBDD, atacará a la IP_BALANCEO_BBDD y se le mandará contra una BBDD concreta 1, 2, 3

WEB1 -> IP_BALANCEO_BBDD -> BBDD1
    guardame el titulo del documento. En qué instancias de la BBDD : BBDD1, BBDD2, BBDD3 debe guardarse ese título?
        EN 2 instancias! ** COMO!?!?!?!?!


Kubernetes quiero 5 copias del Servidor WEB... bastaría con algo como esto?
    Afinidades/Antiafinidades de pods
        - Antiafinidades del pod consigo mismo: requerida, PREFERIDA
        Me podría interesar decirle: No me montes los webservers en la misma máquina. Ahora está mejor? NO , ni de coña! de hecho PEOR !
        Me podría interesar decirle: Intenta no montarme los webservers en la misma máquina. Ahora está mejor? GUAY !!!!


----
Introducción al mundo de los contenedores con Docker
    Kubernetes 4 developers
        Kubernetes 4 sysadmins
            Openshift
                Como operar un cluster de Kubernetes con las cositas por encima que pponer Openshift
            ISTIO: Seguridad, Control y monitorización de servicios en un cluster de producción
        Desarrollo de charts de HELM : plantillas de despliegue en kubernetes
---

MAQUINA 1                   DATOS
    mariaDB1-cluster1       2   3
    HDD

MAQUINA 2
    mariaDB2-cluster1
    HDD                     1   2

MAQUINA 3
    mariaDB3-cluster1
    HDD                     1   3

    Tengo HA? Si... a que se me caiga 1 maquina... si se caen 2, ESTOY JODIDO !
    Tengo mejora en rendimiento (escalabilidad)?

    Cuando tenía una UNICA BBDD, cuantos datos podía grabar en 2 instantes de tiempo? 2 datos
    Al tener 3 máquinas, en 2 instantes de tiempo, puedo ahora grabar 3 datos.
    Al meter 3 maquinas, mejora el rendimiento en un 50%... vaya chascazo !

    1 maquina me permite grabar   100 peticiones/segundo
    3 maquinas me permitirían:    300 peticiones/segundo
        por la HA eso se queda en 150 peticiones/segundo

---

MAQUINA 1                   DATOS
    mariaDB1-cluster1       1   2   4
    HDD

MAQUINA 2
    mariaDB2-cluster1       1   3   4
    HDD                     

MAQUINA 3
    mariaDB3-cluster1       1   3   5
    HDD                     

MAQUINA 4
    mariaDB4-cluster1       2   3   5
    HDD                     

MAQUINA 5
    mariaDB5-cluster1       2   4   5
    HDD                     


    Tengo HA? Si... a que se me caigan 2 maquina... si se caen 3, ESTOY JODIDO !
    Tengo mejora en rendimiento (escalabilidad)?

    Cuando tenía una UNICA BBDD, cuantos datos podía grabar en 3 instantes de tiempo? 3 datos
    Al tener 5 máquinas, en 3 instantes de tiempo, puedo ahora grabar 5 datos.
    Al meter 5 maquinas, mejora el rendimiento en un 66%... vaya chascazo !

    1 maquina me permite grabar   100 peticiones/segundo
    5 maquinas me permitirían:    500 peticiones/segundo
        por la HA eso se queda en 166 peticiones/segundo                        En la práctica esto es más bajo!

---

Todos los sistemas de almacenamiento de información en cluster trabajan como os acabo de contar:
- BBDD: Mariadb, mysql, postgresql, oracle database
- Indexadores: ELASTICSEARCH
- Sistemas de mensajería: KAFKA

Esas herramientas, al operar en cluster, tienen un potencial peligro: BRAIN SPLIT 

     1 3                 2 4
     V V                 v V
    BBDD1       /       BBDD2   
    1 2 3               1 2 4
    
Y cada una de las BBDD se ponen a trabajar como si fueran independientes. ROTURA DE CEREBRO. 
Ya no tengo 1 base de datos... tengo 2 bases de datos independientes.

Esos datos ya no hay quien los una.
Me toca tirar una BBDD, PERDIENDO SUS DATOS, y recplicar la otra. LO CUAL ES INADMISIBLE

Para evitar ese problema, este tipo de sistemas nombran un MAESTRO, que coordina todo el trabajo
El MAESTRO ES ELEGIDO POR VOTACION ENTRE EL RESTO DE NODOS, Solo si tiene mayoría absoluta PODRA ejercer como tal

    1               2                   3 Error
    v               v                   v ^
    BBDD1           BBDD2     /        BBDD3
    1 2             1 2
---


Para qué montamos un cluster de BBDD??
- Alta disponibilidad
    Eso significa que me serviría con que el dato estuviera guardado en 1 sola instancia? NO, ya que si esa se cae, me quedo sin dato
- Escalabilidad
    Qué pasa si guardo el dato en todas las instancias? Gano rendimiento? NO.... Puedo atender más peticiones? NO

Cada instancia de la BBDD va a tener su propio disco o van a tirar todas las 
instancias de los mismos ficheros, que tendré en un almacenamiento compartido?

CADA INSTANCIA DE BBDD TIENE SUS PROPIOS FICHEROS 
ESTO NO ES UN WP

En WP tengo un UNICO VOLUMEN DE DATOS: Cada instancia crea sus propios ficheros y los borra, y los modifica, pero
a la vez voya tener 2 instancias ESCRIBIENDO en el mismo fichero? NO

LAS BBDD, NINGUNA, funcionad e esa manera. Puedo tener 3 instancias (procesos) leyendo y escribiendo en el MISMO FICHERO DE BBDD? 
Me la lian al segundo. NO 

Es más, si tuviera SOLO UN VOLUMEN DE ALMACENAMIENTO, gano en ESCALABILIDAD

Donde está el cuello de botella en una BBDD?? En IO a disco
Si solo tengo un DISCO y todo el mundo leyendo de ese, mejora el rendimiento? EMPEORA !

---
# KUBERNETES: Comunicaciones (servicios)

# SERVICE

IP de balanceo de carga + Entrada en el DNS de Kubernetes

# INGRESS

Configuración de proxy reverso












