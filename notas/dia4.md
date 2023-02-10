# Logs de un contenedor

Es la salida estandar del proceso principal que se ejecuta al arrancar un contenedor

# Acceso a aplicaciones por protocolo http y https

HTTP es un protocolo que nos permite acceder a Servidores WEB

Request -> Response

No queremos trabajar con HTTP, en su lugar habitualmente trabajamos con HTTPs

Que aporta HTTPs frente a HTTP? s ~> TLS de seguridad
                                    Transport Layer Secured

En qué consiste la securización. Básicamente nos permite frustrar 2 tipos de ataques:

- Man in the Middle: Alguien que mira los datos que se mandan entre cliente y servidor a través de la red
    Para frustrar este ataque ENCRIPTAR LOS MENSAJES: 
        Existen distintos algoritmos de encripción:
        - Basados en clave Simetrica: Con la misma clave se encripta y desencripta. MAS EFICIENTE, MENOS SEGURO
        - Basados en claves Asiméticas: Con la clave que se encripta no se puede desencriptar - CLAVE PRIVADA
                                        Hace falta otra clave                                 - CLAVE PUBLICA
    HTTPS usa AMBOS TIPOS. El grueso de la comunicación se hace mediante cifrado SIMETRICO.
    Pero el servidor y cliente generar para la comunicación una clave SIMETRICA con duración(cuducidad limitada en el tiempo)
    que comparten mediante un algoritmo de ENCRIPCION ASIMETRICO

- Suplantación de Identidad: Monto un servidor PIRATA y le cambio al tio su DNS de forma que cuando quiera acceder 
  a la página banco.es... y le pregunte a su servidor DNS quién es banco.es en lugar de darle la IP buena del banco
  le dan la IP de mi servidor pirata. Y cuando meta ahñi la clave ... le saco to la pasta

  Cuando me contecto con un servidor quiero garantias de que es quien dice ser.
  Eso lo consigo pidiendole al servidor un CERTIFICADO (DNI)

  Ese certificado incluye:
    El nombre del servidor: banco.es
    La firma de una ENTIDAD CERTIFICADORA en la que YO DEBO CONFIAR

CHROME tiene un huevito de pascua:      thisisunsafe

---

# CONFIGURACIONES DE KUBERNETES

## Node        

Hosts donde corre kubernetes y donde podemos desplegar los pods

## Namespace

Agrupación de recursos dentro de un cluster de Kubernetes, donde los nombres de los recursos deben ser UNICOS.

## Pod

Conjunto de contenedores que:
- Corren en el mismo host
- Escalan juntos
- Comparten IP
- Pueden compartir volumenes

## Plantillas de pods

### Deployments

Plantilla de pod + numero de replicas

### StatefulSets

Plantilla de pod + Plantilla de Peticion de Volumen Persistente (PVC) + numero de replicas

### Daemonsets

Plantilla de pods (Kubernetes monta una replica / pod en cada nodo del cluster)

## Comunicaciones

### Services

#### ClusterIP

IP de balanceo + entrada en el DNS interno de Kubernetes

#### NodePort

ClusterIP + exposición de puertos en el host

#### Load Balancer

NodePort + Gestión AUTOMATIZADA del BALANCEADOR EXTERNO

### Ingress

Reglas de configuración para un PROXY REVERSO (Ingress Controller)

## ConfigMap

## Secret

## PersistentVolume

## PersistentVolumeClaim

## Jobs

Un conjunto de contenedores que se ejecutan SECUENCIALMENTE hasta que acaban... Y DEBEN ACABAR. Si no acaban? 
KUBERNETES SE VUELVE LOCO DE NUEVO !

## CronJobs

Plantilla de JOB + un CRON

CRON?  Una programación de cúando la tarea debe ejecuatarse:
- Los Jueves por la mañana a las 9am
- Todas las noches
- El último día del mes

---

# Tipos de software

- Sistema Operativo
- Aplicaciones
---------------------------v Contenedorizables          Ejecutables en containers de PODS de Kubernetes
- Demonios                                                          √
    - Servicios                                                     √
-----------------------------
- Librerias     NO ES EJECUTABLE
- Drivers       NO ES EJECUTABLE
-----------------------------
- Comandos                                                          x
- Scripts                                                           x


¿Cuales de ahí puedo ejecutar como contenedores dentro de un POD de Kubernetes? TODOS? NO, Solo demonios y servicios

Para Kubernetes los contenedores de un POD deben estar funcionando ETERNAMENTE, sin interrupción, 24x7

Y si un contenedor deja de funcionar que hace Kubernetes? VOLVERSE LOCO !

Script que haga un backup (copia de seguridad) de una BBDD. -> Contenedor de un POD

Dicho esto... es posible ejecutar conteendores que dentro ejecuten Scripts o Comandos dentro de Kubernetes?
SI, mediante 2 opciones:
- JOBs
- Dentro de un POD... pero no en el bloque containers, sino en el bloque initContainers.

Puedo definir un POD que solo tenga initContainers y no tenga containers? SI
Pero no lo haré nunca... No es para lo que están creados. 
Si solo quiero ejecutar tareas, lo que crearé será un JOB

Cúantos JOBS vamos a crear en un cluster de Kubernetes? NINGUNO !
Puedo ? SI, igual que puedo crear PODs...
Pero cuántos PODs creamos en un cluster de Kubernetes? NINGUNO !
Lo que creamos son plantillas de PODs, para que KUBERNETES cree PODs según necesite.

Y lo mismo con los JOBs. Lo que vamos a crear son PLANTILLAS de JOBS

Y Kubernetes me da un tipo de Objeto para ello: CronJob

---

# Ejemplo: 

Imaginad que quiero desplegar un APACHE con un WP
Y va a tener su BBDD

El código del WP lo tengo en un repo de git, lo tengo que compilar

Y quiero hacer backups de la BBDD los viernes
Del apache quiero extraer los logs y mandarlos a un ElasticSearch

Que objetos montamos en Kubernetes?

Deployment 
    Replicas: 2
    Plantilla de Pod
        InitContainer: # Estos 2 contenedores se ejecutan SECUENCIALMENTE
            Contenedor con GIT para extraer el código de mi WP y dejarlo en un Volumen XXXXXX
            Contenedor que compile el código extraido del repo de GIT 
                Lo lee del volumen XXXXXXX y lo deja en un volumen YYYYYYY
        Contenedor: # Estos 2 contenedores CORREN EN PARALELO, SIMULTANEAMENTE
            Apache + WP + código <<<< YYYYYYY
                v
                access.log
                ^
            FileBeat

Statefulset
    Replicas: 1
    Plantilla de Pod
        Contenedor:
            MySQL

CronJob
    Plantilla de JOBS
        Cron: Los viernes
        Contenedor:
            Hiciera el backup
---

# Limitaciones de acceso a los recursos del host:

Limitación de uso de memoria RAM y de la CPU

A cada contenedor le vamos a suministrar 4 datos:

    resources:
        requests:           # Cuánto debe garantizar Kubarnetes al contenedor
            cpu:
            memory:
        limits:             # Hasta cuánto le permite usar, si hay hueco
            cpu:            Esto será para casos muy puntuales.... AYUDARME con el tema del RATIO CPU/RAM hasta que consiga afinarlo.
            memory:         NO EXISTE. ESTO NO SE USA. PROHIBIDO !!!!!! El mismo valor que arriba. NO VALE NINGUNA OTRA CONFIGURACION
                            A no ser que sea el PUTA MAQUINA DEL KUBERNETES Y DE LA APP y tenga muy muy muy muy muy claro lo que estoy haciendo
                            Y voy a encontrar 5 persoans en el mundo que lo tengan tan claro. 
            
    CONFIGURACION ESTANDAR
    resources:
        requests:
            cpu: Pongo un valor que me permita atender X peticiones por minuto / x usuarios
            memory: Pongo un valor que me permita atender a esas X peticiones por segundo/usuarios.
                    Que no me satura con los cores que he definido arriba
        limits:
            cpu: INFINITO !!!!!
            memory: Lo mismo que aariba, ni un solo bit más.

    Para atender a Y peticiones por minuto, siendo Y mi pico!
        Escalaré hasta un máximo de Y/X pods... teniendo en cuenta además la Alta Disponibilidad, que afectará severamente a este ratio.
            * n en función de a cuántos pods cidos te la juegues.
        
            
Cluster de Kubernetes:

                                                request                 < limit
                                                                        < lo que hay libre
                        TOTAL DISPONIBLE        LO QUE PIDEN LOS PODS   LO QUE USAN         LIBRE EN USO            LO QUE NO TIENE COMPROMETIDO
                        CPU         RAM         CPU         RAM         CPU         RAM     CPU         RAM         CPU         RAM
                        
    Maquina 1           8 cores     32 Gbs                                                  0 cores     1  Gbs      1 cores     4 Gbs
        POD-Apache-WP-1                         5 cores     16 Gbs      5 cores     6 Gbs
        POD-MySQL-1                             2 cores     12 Gbs      3 cores    12 Gbs   
    Maquina 2           8 cores     32 Gbs                                                  6 cores     24 Gbs      3 cores     16 Gbs
        POD-Apache-WP-1                         5 cores     16 Gbs      2 core      8 Gbs

    Pues, o le limito al MySQL la RAM o mientras haya memoria, va a pedir más si la nacesita.
    Y nota: Cuanta RAM quieren las BBDD
            Cual es el objetivo y deso de una BBDD? Tener la BBDD entera en RAM
                                                    Cada query que se haya hecho guardarla en RAM
                                                    Cada resultado de cada query guardarla en RAM
    Es más... todo esto tendría que estar limitado a otro nivel:
        En el fichero de configuración de la BBDD
        El request y el limit de Kuberneets son mecanismos de protección... Para que un proceso no se vuelva loco.
        Pero no son mecanismos para controlar la RAM.

POD-Apache-WP-1
POD-Apache-WP-2
    1º Kubernetes llama al Scheduller 
        Ese programa decide en que máquina se monta el pod
POD-MySQL-1

En la plantilla he dicho que los :
- POD-Apache-WP:
    Piden 5 cores y 16 Gbs
- POD-MySQL
    Piden 2 cores y 12 Gbs

¿ Cuanto pido de garantizado ? 

CPU... Puede una app funcionar con 0.01 core? SIN PROBLEMA.... pero irá muy lenta!
Existe un mínimo en lo que una app necesita para ejecutarse con respecto a CPU? NO.. lo que pasa es que con poca CPU irá muy  lenta.. a rabiar de lenta 

RAM... Puede una app funcionar con 1byte de RAM? NI DE COÑA !
Aquí si existe un límite MINIMO:
- Qué entre el código de la app en la RAM
Ahora una app para hacer cosas, una vez que haya arrancado necesita RAM.
Y esa RAM en función de qué va? Del uso.
Necesito la misma RAM si la app está siendo usada por 10 usuarios o por 100? NO 

¿Cuál es el valor mínimo de RAM y CPU? Eso no existe como concepto.
Existe lo que YO LE QUIERA PONER ... y en base a eso, la app podrá atender a más o menos usuarios y más rápido o más lento.

Apache 5 cores 16 gbs de RAM atenderá más usuarios que si le pongo:
       1 core y 4 gbs de RAM
       
De esas 2 cosas, cuál es la que manda!
Los cores. LA RAM va en función de los CORES.
A más cores, puedo atender a más gente y eso implica que necesitaré MAS RAM 

Me vale de algo configurar mucha RAM si no tengo suficientes cores? NO, no la voy a usar!

Con las cpus y RAM que haya puesto seré capaz de atender a más o menos usuarios 
----> El número de usuarios REAL al que soy capaz de atender con una determina RAM Y CPU lo saco de MONITORIZACION

Para la CPU X que haya puesto. Si pongo menos memoria de la que necesitaré, que pasa? APP EXPLOTA OutOfMemoryException !
                               Si pongo más memoria de la que necesitaré, qué pasa?   HAGO EL CAPULLO , estoy tirando RAM que no uso

Como dije ayer, lo que queremos es una buena relación entre estos dos valores, para que lo de arriba no pase.

Y que hacemos si queiro en un momento dado atender a más usuarios de los que puedo con esa cantidad de CPU y RAM? ESCALAR:
Otra copia del programa a funcionar:

POD APACHE          4 cores     16 gbs de RAM ----> 10k usuarios

Si me llegan 20000 usuarios, otra copia:
POD APACHE2         4 cores     16 gbs de RAM ----> 10k usuarios

Si me llegan 3000 usuarios, otra copia:
POD APACHE3         4 cores     16 gbs de RAM ----> 10k usuarios

Cuando escalo? 
Cuando la CPU o la RAM están en un valor LIMITE que defina: 

    Apache 1        4 cores         2 cores en uso (50% de los pedidos) tengo 2 cores aún disponibles por si llega más curro
    Apache 2        4 cores         2 cores en uso (50% de los pedidos) tengo 2 cores aún disponibles por si llega más curro

    ¿Estoy bien o necesito escalar en base a los cores? YO ESTOY ACOJONAO !!!!! Los pelos como escarpias !!! NO DUERMO

    Qué pasa si Apache 2 se cae? Apache 1 tiene capacidad para asumir la carga de trabajo de Apache 2? NO, se queda apretao de cojones
                                 Apache 1 se va a tomar por culo
        Y me quedo sin dar servicio
        Y si... el kubernetes me levantarrá de nuevo los pods.... pero entre tanto, a todos los usuarios que habían hecho su petición, NO LES HE ATENDIDO
        Me puedo plantear eso? Dependerá de la criticidad del servicio.

        En homebanking (WEBLOGIC si se caen 3 maquinas que la 4ª sea capaz de asumir toda la carga sin perdida de servicio)
        CPU 25% YA ESTOY ESCALANDO 
            Tiro recursos... SI... PERO MAS IMPORTANTE ES EL SERVICIO QUE LOS RECURSOS !

# En los requests de esas peticiones

No se pone ningún MINIMO... Lo que se pone es unos datos que yo he estimado (a posterir refinado mediante MONITORIZACION) 
que sean acapaces de atender a un determinado número de usuarios, de mi interés. 2000

Y luego configuramos un ESCALADO para poder llegar a atender a un total de usuarios 10000, que son mis máximos potenciales usuarios.

LIMITE DEL ESCALADO Y/X +1 (por seguridad)      Como mucho a 6

cpu:        2                       cores
memory:     4 GiB                   gibibyte
              MiB                   mebibyte
              KiB                   kibibyte

1   GiB =   1024 MiB    = 1024 x 1024 KiB = 1024 x 1024 x 1024 bytes
1   Gb  =   1000 Mb     = 1000 x 1000 Kb  = 1000 x 1000 x 1000 bytes

Lo que antiguamente llamábamos Gb hoy en día se llama GiB
Se ha redefinido lo que es un Gb, Mb, Kb... No hace poco ... hace 24 años.

Los cores los podemos especificar en numeritos: 1 core 2 cores
O en milicores




-----
Kafka
    5 nodos
elasticsearch
    5 nodos < cualquier puede recibir la peticion

Mariadb-galera x3
Mysql-galera
Oracle rac

Por delante he de montar un balanceo de carga. En kubernete slo montar mediante un servicio

3 formas de configurar bbdd:
- 1 replica - Standalone    - perfecto HA en kuberntes activo/pasivo 
- Replicacion - 1 maestra y n copias - HA activ pasivo + escalibidad en lectura
- Cluster activo activo


Apache 
nginx

No operan en cluster de la misma forma que las BBDD...
Cada replica es independeinte de las anteriores

NGINX1          <        Balanceador
NGINX2          <

KAFKA1          <       Balanceador
 v^
KAFKA2          <

ORACLE_RAC1
 v^
ORACLE_RAC2


---

# VOLUMENES EN KUBERNETES

## CONCEPTO DE VOLUMEN

Qué es un volumen... A qué me refiero con un VOLUMEN

VOLUMEN: Un espacio de almacenamiento de información

QUE PUEDE SER UN VOLUMEN.... 
dónde puedo tener un espacio de almacenamiento?
- Un HDD que tengo enchufado al HOST
- Un almacenamiento en RED
    Una computadora que tiene sus propios HDD y me permite usarlos o usar una parte de ellos a travbés de la red
    y un protocolo para usarlo:
    - samba
    - nfs
    - iscsi
- Una LUN en una cabina de almacenamiento
- Un trozo de la RAM que decida usar para guardar archivos comosi fuera un HDD
- De un cloud

Esos volumenes, el SO Linux nos permite MONTARLOS como una carpeta en el Sistema de Archivos del entorno

## VOLUMENES EN CONTENEDORES

Lo mismo que lo de arriba.
Es un punto de montaje en una carpeta/archivo del sistema de archivos del contenedor que realmente está guardando
los datos fuera del sistema de archivos del contenedor

Para que sirven?
- Compartir datos entre procesos (que estén correiendo en distintos contenedores)


    Contenedor 1                    Contenedor 2
        /datos ------> CLOUD <------ /logs

- Inyectar ficheros / carpetas a los procesos que corren en un contenedor


    Cabina                                  Contenedor
    fichero configuración de un nginx ----> /etc/nginx/nginx.conf
    
- Persistencia de datos tras la eliminación de un contenedor.
  Motivos por los que borro un contenedor:
    - Actualizar el software: Borro un conteendor y creo uno nuevo desde una imagen que tenga el software actualizado
    - Escalabilidad
    - Llevarlo de un host a otro: Borrar uno y crear otro nuevo


    NFS                      Contenedor 1
    carpeta con datos  <---- /datos
         ^
         |           Contenedor2
         ----------- /datos
         
## Volumenes en Kubernetes

En Kubernetes, los volumenes NO SE ASIGNAN A UN CONTENEDOR, se asignan a un POD.

Los volumenes definidos en un POD, pueden ser usados por los contenedores del POD.
Eso sí, cada contenedor decidirá en que carpeta montar el volumen, que pueden ser distintas

### PERSISTENCIA DE DATOS

A que los datos queden guardados a salvo por los siglos de los siglos AMEN !
- BBDD
- MENSAJERIA
- LOG

Si yo soy Apache... El servidor web... para MI los log son datos persistentes? ME LA SUDAN los logs
Por ejemplo, SI A MI me interesa PERSISTIR esos datos de logs -> ElasticSearch

Y para el ES los log son datos persistentes? SI... ya que YO le voy a pedir cuentas de ellos a futuro 

# TIPOS DE VOLUMENES EN KUBERNETES

En Kubernetes hablamos de 2 tipos de VOLUMENES:
 
## VOLUMENES NO PERSISTENTES    Los datos se guardan ME DA IGUAL, me interesará en algún sitio que vaya rapidito
                                                                  pero hasta ahí
                                    Qué irá más rapido... un almacenamiento en RED?  En la vida !
                                                                A parte que SATURO LA RED
                                                                Las redes de 10Gbs cuestan mucha pasta como pa gastarlas /saturarlas con gilipolleces
                                                                Y... que si necesito velocidad.... NVME 3Gbit/seg
                                                                Y si necesito Supervelocidad: RAM !
                                                          un almacenamiento local? 
                                        RED 10 Gb
                                            1 Gbit/seg // Compartido entre todo perro pichichi
                                        
                                        SSD -> 0.65Gbs/seg PA MI, sin compartir PA MIIIII 

- Compartir datos entre procesos (que estén correiendo en distintos contenedores) del mismo pod
    Me importa realmente donde se estén guardando los datos? ME DA IGUAL !!!
         a en qué carpeta del HDD?
         a en qué posición de la memoria RAM? 


    emptyDir:   Una carpeta vacia en el HDD del host, o en su memoria RAM que si el POD se muere, 
                se va detrás del pod

- Inyectar ficheros / carpetas a los procesos que corren en un contenedor


    configMap:  Si quiero que los archivos los guarde Kubernetes en su base de datos interna ETCD
    secret:     Si quiero que los archivos los guarde Kubernetes en su base de datos interna ETCD, encriptados
    hostPath:   Si quiero inyectar un fichero del host al contenedor. Esto es habitual? RARO DE COJONES
                    Monitorización: /proc 
                                    /sockets del host...
                


## VOLUMENES PERSISTENTES:      Los datos se guardan EN LUGAR SEGURO Y SIEMPRE ACCESIBLE
                                    - Almacenamiento en RED: nfs, icsci
                                    - cabina de almacenamiento
                                    - Cloud

- Persistencia de datos tras la eliminación de un contenedor.


    awsElasticBlockStore
    azureDisk
    azureFile
    cephfs
    cinder
    fc (canal de fibra)
    gcePersistentDisk
    gitRepo (deprecado)
    glusterfs
    iscsi
    nfs
    vsphereVolume

Nos estamos dando cuenta que:

En los volumenes no persistentes, no hay problema:
- emptyDir
- configMap
- secret

Si quiero usar volumenes persistentes, la configuración del volumen depende del TIPO DE VOLUMEN que vaya a montar.

PREGUNTA !

Quien rellena el fichero donde se define la plantilla del POD, y por ende los volumenes?

EL EQUIPO DE DESARROLLO, con potencial ayuda de algunos compis que sepan del tema y de escribir estos ficheros.

Y AL EQUIPO DE DESARROLLO, le importa un huevo, DONDE REALMENTE se esté guardando el dato? NO LE IMPORTA
                                                                                            Y NO DEBE SABERLO

DE QUIEN ES REPONSABILIDAD ELEGIR LA UBICACION DE LOS DATOS?

Del administrador del cluster de Kubernetes y la gente de almacenamiento.


A mi, COMO DESARROLLO, COMO DUEÑO DEL PRODUCTO QUE ESTOY INSTALANDO, qué me interesa?
Tener un sitio donde poder guardar datos.... cualquier sitio? NO. Uno que cumple con mis necesidades:
QUE VOY A PEDIR:
    50 Gbs de almacenamiento
    encriptados? SI / NO
    velocidad del almacenamiento: RAPIDITO, NORMALITO o LENTITO
    NIVEL DE REDUNDANCIA: x3, x4

10 Gbs rapiditos 
40 Gbs lentos para backups

Hace 20 años, cuando íbamos a pasar un sistema a producción, que hacíamos? SOY DESARROLLO
Qué me preguntaban los de sistemas?
- Dame cpu
- Dame memoria
- Dime cuanto espacio necesitas

# Quien vincula el pv y el pvc? KUBERNETES

Kubernetes busca una pv que sea capaz de atender una PVC... y las asigna

Cojonudo, asigno el PV volumen-1878374562834 a la PVC peticion-de-volumen-ivan




Voy al mediamark YO (desarrollo) y esta el pollo del mediamark (admisnitracion) y le digo

Quiero un volumen de 4,76 Tbs
El del mediamark se parte el culo... y me dice... Tengo uno de 6 Tbs... 
Y yo... pues me lo llevo.... Es el que hay.