# Contenedores

## Qué es un contenedor?

**Entorno aislado** dentro de un SO con kernel Linux en el que ejecutamos procesos.

Podemos ejecuatr contenedores en Windows? NO. ROTUNDO NO ! Ni en MacOS tampoco.

Lo que hacemos es un truco que consiste en correr un kernel de linux dentro del windows o del macOS
en el que se ejecutan los contenedores.
- En MacOS se levanta una máquina virtual con linux corriendo.
- En windows antiguamente también era así (hyperV)
- En windows hoy en día se usa el wls2

Teniendo en cuenta que el Kernel de SO más usado en el mundo es Linux (Android),
y que la mayor parte de servidores en las empresas
corren un sistema operativo GNU/linux ... no parece una gran limitación.

#### Sistema operativo "Linux"

Eso está muy mal llamado. Linux no es un SO, es un kernel de SO.

En las empresas usamos sistemas operativos GNU/Linux, donde:
- Linux es un kernel de SO, cojonudo, supuestamente cumple con los estándares de UNIX® (POSIX + SUS)
- GNU pone encima un huevón de programas para poder manejar ese kernel:
  - ps
  - mkdir
  - ls
  - bash
- Por encima, otras empresas ponen más programas, dando lugar a lo que llamamos las distros de GNU/Linux:
  - RHEL
    - yum
  - Debian
    - Ubuntu. Extras:
      - apt
  - Suse

GNU = GNU is not Unix

### Para ver los procesos que tengo corriendo en una máquina linux...

ps

### Contenedor: Entorno aislado.... en cuanto a qué?

- Tiene su propia configuración de red -> Su(s) propia(s) IP(s)
- Un sistema de archivos propio
- Unas variables de entorno propias
- Puedo tener limitación de acceso a los recursos físicos del host (componentes del hierro)

### Creación de contenedores

Los contenedores los creamos desde IMAGENES DE CONTENEDOR.

## Qué es Imagen de contenedor?

Una forma de empaquetar y distribuir aplicaciones, entre tantas otras... 
pero que tiene unas característcias muy concretas.

Es un triste fichero comprimido (tar) que lleva dentro el qué?
- Un software(1) que querré previsiblemente ejecutar. (p.ej. NGINX)
- Ese software se encontrará YA INSTALADO DE ANTEMANO y PRECONFIGURADO -> Listo para su ejecución
- Habitualmente, ese programa lo encuentro instalado en una estructura de carpetas POSIX.
- Otros programas (dependencias: requisitos/librerias) que sean requeridos para poder ejecutar los primeros (1)
- Otros programas que no siendo requeridos, me puede venir bien tenerlos (p.ej. ls, bash)

Adicionalmente, en la imagen de contenedor encontramos cierta información complementaria, como:
- Puertos que los programas que están ahí instalados van a usar en sus comunicaciones
- Los directorios que los programas que están ahí instalados va a usar para:
    - guardar información
    - leer ficheros iniciales (configuración...)
- Las variables de entorno que usan esos programas que vienen ahí instalados, con valores por defecto (algunas).
- El proceso principal que debe ejecutarse al arrancar el contenedor
- Metadatos ( autor de esa imagen, .... )

Si descomprimiese el TAR (imagen de contenedor), me encontraría:

    /bin/       Comandos ejecutables
    /etc/       Configuraciones
    /opt/       Programas
    /tmp/
    /var/       Datos de los programas
    /root/
    /home/
    /usr/       Más programas

Es posible que el programa estuviese instalado en qué carpeta? 
- /usr/
- /opt/

Es posible que la configuración / preconfigruación de ese programa estuviera en la carpeta?
- /etc/

Los datos de ese programa se irán generando en?
- /var/

#### Las imágenes de contenedor las conseguimos de:

De un registro de repositorios de imágenes de contenedor. Entre los más famosos:
- Docker hub
- Quay.io -> Redhat

Hoy en día TODO EL SOFTWARE de caracter EMPRESARIAL se distribuye mediante IMAGENES DE CONTENEDOR.
Se ha convertido en un estandar de facto.

#### Tipos de software

- Sistema operativo *

- Aplicación      Programa que está pensado para correr en PRIMER PLANO, interactuando con una persona
                    **WORD**, **EXCEL**, **CHROME**

---------------------------------------------------------------v Todo eso es CONTENEDORIZABLE 

- Demonio         Programa que corre en SEGUNDO PLANO de forma indefinida en el tiempo
  - Servicio    Cuando ese programa está pensado para comunicarse con OTROS PROGRAMAS, por ejemplo:
                    - atendiendo sus peticiones a través de un puerto de comunicación en red.
                        **FTP**, **servidor web**

- Libreria        Programa que contiene fuciones que otros programas pueden usar durante su ejecución

- Driver          Programa que controla un dispositivo físico

- Script          Es un software que ejecutar una serie de tareas / comandos. Y cuando acaba, listo !

- Comando         Es un software que ejecuta una tarea muy concreta y acaba.

## Contenedores vs Máquinas virtuales:

Los contenedores NO PUEDEN EJECUTAR un KERNEL de SO. 
Las Máquinas Virtuales SI.

Por eso en general NO QUEREMOS USAR MAQUINAS VIRTUALES EN MUCHOS ESCENARIOS, donde se me complica
MUCHO la cosa, por tener las MV su propio KERNEL DE SO.

## Gestión de contenedores e Imágenes de contenedor

Los contenedores y las imágenes de contenedor las creamos y gestionamos con GESTORES DE CONTENEDORES.

El más famoso:
- docker        Es el más famoso... ha sido durante mucho tiempo el más usado... pero...
                Recientemente ha cambiado su politica de licencias.
                Y hoy en día para empresas de más de 250 empleados ES DE PAGO
                Antes era gratuito para todo el mundo.
                Hoy en día lo sigue siendo para:
                - empresas pequeñas
                - estudiantes
                - proyectos opensource
- podman        Hoy en día viene de serie con los Redhat y derivados
                Es opensource y gratuito
- crio          \
- containerd    / Son los soportados por KUBERNETES

### Al instalar docker

Por defecto crea una red virtual en el host, equivalente a la red de loopback,
(donde de nuestro tiene asignado la IP: 127.0.0.1 = DNS = localhost)

Esa red, por defecto funciona en el tramo: 172.17.0.0/16
El host por defecto toma la IP 172.17.0.1 en esa red

Puedo crear redes adicionales con Docker, con docker network ....

En esa red se van pinchando los contenedores, que reciben IPs secuenciales

Eso implica que para TODOS LOS PROCESOS QUE HAYA DENTRO DE UN CONTENEDOR, 
los puertos que abran esos procesos se van a abrir sobre qué IP? 
La que tenga el contenedor asignada en ESA RED.

# REDES EN CONTENEDORES

Un contenedor al iniciarse arranca un proceso UNICO, el que haya sido configurado en la IMAGEN DE CONTENEDOR

Ese proceso a su vez, puede arrancar más procesos.

Puedo solicitar al SO que ejecute más procesos dentro del contenedor? SI

En el caso de usar como gestor de contenedor docker, el comando para ello es: 
docker exec CONTENEDOR COMANDO

### Cuando ejecuto un comando en una terminal... Dónde se busca ese comando?

Si no se suministra una ruta absoluta acerca de DONDE ESTA EL COMANDO, 
se busca el comando en los directorios definidos en la variable PATH


# SISTEMA DE ARCHIVOS DE UN CONTENEDOR

Cada contenedor tiene su propio sistema de archivos... que reside donde?

Dentro del Sistema de Archivos del host.

Lo que ocurre dentro de un contenedor es que el SO ENGAÑA a los procesos que ahí corren.

Cuando éstos preguntan por el directorio raiz  /, el SO no les lleva al raiz / del host (1),
sino que los lleva al raiz del sistema de archivos del contenedor (2)

Eso es algo que se hace en los sistemas operativos UNIX desde hace 40 o 50 años....

Qué comando permite engañar a un proceso, haciendole creer que el raiz / es otro directorio? chroot 
    
    chmod       Change mode - Cambiar modos de acceso a un fichero
    chown       Change Owner - Cambiar propietario
    chroot      Change root - Cambiar el root del filesystem para un proceso

Ahí se hace un truco rastrero:

FS HOST
/                                                                               (1)
    bin/
        ls
        mkdir
        bash
        env
    etc/
    var/
        lib/
            docker/
                    container/
                                minginx2/                                        (3)
                                        var/                            
                                            logs/
                                                 nginx.log   <<< Los archivos de log del nginx
                                        var/
                                            nginx/
                                                web/ ~> Una carpeta que tengo en otro servidor
                                                     ~> Una carpeta del host
                                                            /home/ubuntu/web
                                minginx/                                        (3)
                                        var/                            
                                            logs/
                                                 nginx.log   <<< Los archivos de log del nginx
                                        var/
                                            nginx/
                                                web/ ~> Una carpeta que tengo en otro servidor
                                                     ~> Una carpeta del host
                                                            /home/ubuntu/web
                                        etc/    
                                            nginx/nginx.conf <<< Inyectar de otro sitio
                                instalacionWeblogicYAppHomeBancking
                                    /usr/oracle/weblogic
                                    /home/caixabank/homebanking.war
                                appHomeBanking1
                    image/
                            ...
                                / nginx ** EL TAR DESCOMPRIMIDO                 (2)
                                        bin/
                                            ls
                                            mkdir
                                            bash
                                            env
                                        etc/    
                                            nginx/nginx.conf          <<< Configuración del nginx
                                        var/                            
                                            logs/
                                                       
                                            nginx/
                                                    web     <<< Web por defecto que muestra el nginx
                                        opt/
                                            nginx/          <<< Instalación del nginx (binarios)
                                        home/
                                        root/
                                        boot/
                                        proc/
                                        run/
                                        usr/
                                        tmp/
                                /oraclelinux
                                        bin/
                                            ls
                                            mkdir
                                            bash
                                        etc/    
                                        var/                            
                                        opt/
                                        home/
                                        root/
                                        boot/
                                        proc/
                                        run/
                                        usr/
                                        tmp/
                                /appHomeBanking
                                        bin/
                                            ls
                                            mkdir
                                            bash
                                        etc/    
                                        var/                            
                                        opt/
                                        home/
                                            caixabank/homebanking.war
                                        root/
                                        boot/
                                        proc/
                                        run/
                                        usr/
                                            oracle/weblogic
                                        tmp/
    opt/
    home/
        ubuntu/
                web/
    root/
    boot/
    proc/
    run/
    usr/
        bin/docker  <<< Ahi tengo instalado docker
    tmp/
    .....
    

En verdad esto es mas complejo. Eso es solo la primera parte de cómo funciona el FS de un contenedor.

En la realidad, la carpeta de la IMAGEN DEL CONTENEDOR (2), no tiene privilegios de ESCRITURA:
NADIE PUEDE ESCRIBIR EN ESA CARPETA. ES UNA CARPETA INVARIANTE. 

El sistema de archivos de un contenedor es el resultado de la superposición de multiples capas:


CAPA DEL CONTEENDOR (3). Es la que recibe los cambios en el FS del contenedor.
    Si se trata de escribir un archivo o midificar un archivo, aquí es donde se hace.
    Recoje todos los cambios que se hagan sobre el FS del contenedor.
CAPA BASE (2): Capa de la imagen. ES INALTERABLE

Al igual que en el sistema de archivos del host, en el sistema de archivos del contenedor podemos
establecer PUNTOS DE MONTAJE: VOLUMENES

Los VOLUMENES EN UN CONTENEDOR no son sino puntos de montaje de otras ubicaciones 
que hacemos accesible en el FS del contenedor, opacando las correspondientes rutas que existieran a nivel
de la capa de la imagen.


Con qué comando habitualmente creamos puntos de montaje en un sistema de archivos? mount
Qué es un punto de montaje? 

FS host:

/
    etc/
    bin/
    home/
        miusuario/
                  datos/    PUNTO DE MONTAJE -> Servidor en red NFS
    ....

# IMAGENES BASE DE CONTENEDOR.

No hacen nada. Solo tienen carpetas y comandos, y las uso como BASE para montar MIS PROPIAS IMAGENES DE CONTENEDOR

Yo estoy en ITNOW y quiero montar la app de Home Banking.
La desarrollo en JAVA.
Y esa app la compilo y empaqueto -> war (web archive de java)
Pero esa app tiene que ejecutarse dentro de un tipo de programa muy especial: Servidor de apps JAVA: Weblogic

Y ahora quiero distribuir todo esto como Imagen de contenedor:
Paso 1: Tomo la imagen de OracleLinux
Paso 2: Sobre esa imagen monto Weblogic
Psso 3: En ese Weblogic configuro el war de la app de home banking
Paso 4: Exporto la nueva imagen... y a tomar cocolocos!
                        ||
                        vv
                    Contenedores
                    
## La imagen UBUNTU, que contiene?

Una estructura de carpetas posix, 4 comandos de GNU, y APTITUDE (apt)

bin/
    ls
    mkdir
    chmod
    chown
    cat
    cp
    mv
    touch
    bash
    sh
    env
    wget
    apt
etc/    
var/                            
opt/
home/
root/
boot/
proc/
run/
usr/
tmp/

## La imagen ALPINE, que contiene?

bin/
    ls
    mkdir
    chmod
    chown
    cat
    cp
    mv
    touch
    sh
    env
    wget
etc/    
var/                            
opt/
home/
root/
boot/
proc/
run/
usr/
tmp/

## La imagen FEDORA, que contiene?

bin/
    ls
    mkdir
    chmod
    chown
    cat
    cp
    mv
    touch
    sh
    bash
    env
    wget
    yum
    dnf
etc/    
var/                            
opt/
home/
root/
boot/
proc/
run/
usr/
tmp/







---

# Kubernetes

## Qué es Kubernetes?

Es un orquestador de gestores de contenedores
                     |----------------------|-----> docker, podman, crio, containerd

## Para qué lo usamos?

Es la herramienta que hoy en día opera los entornos de producción de las empresas!
- Administra cargas de trabajo y servicios
             |---------------|   |-------|
               Escalabilidad      HA: Balanceador de carga

             pod                 service
             pod template           - clusterip
             deployment             - nodeport
             statefulset            - loadbalancer
             daemonset           ingress
             
             job
             cronjob


- Gestiona, implementa y escala aplicaciones contenedorizadas

## Aceca de kubernetes

Es una herramienta cuyo desarrollo es comenzado por Google.
- Opensource

Kubernetes hoy en día es una colección de estandares. 
Y hay un huevo de implementaciones de Kubernetes diferentes:
La más común se llama K8S.

Distribuciones:

- K8S
- K3S
- Minikube
- OKD / Openshift -> Redhat
- Tamzu           -> VMWare

# Entornos de producción de las empresas:

- Entornos de desarrollo
- Entornos de pruebas
- Entornos de producción

## Entornos de producción. Características

### Alta disponibilidad: High Availability (HA)

#### A nivel del servicio que ofrecemos

"Tratar de" garantizar que el servicio está disponible una determinada cantidad de tiempo (pre-acordada)
Servicio caido = Incluye actualizaciones, insatlaciones, mantenimientos, backups....

    90% del tiempo que debería. Servicio que debe funcionar de L-V de 9h-21h

    90% = RUINA GIGANTE = 1 de cada 10 dias el servicio out!

    90% = 36 dias   al año con el servicio caido                                |   €
    99% = 3,6 dias  al año con el servicio caido        PELUQUERIA DE BARRIO    |   €€
    99,9% = 8 horas al año con el servicio caido        Tienda online           |   €€€€€€
    99,99% = 20 minutos al año con el servicio caido    Hospital                |   €€€€€€€€€€€€€€€€
                                                                                v   

    Cómo intento garantizar esos tiempos? REDUNDANCIA: CLUSTER (en inglés GRUPO) !
        Voy a poner las cosas replicadas.
        
##### Tipos de Cluster:

- Activo/pasivo: Hay uno dando servicio y el otro está a la espera
    Si el activo falla, el pasivo entra en marcha.
    Qué me hace falta aquí delante de esos ordenadores/servidores/computadoras

    clientes/usuarios   ------>  BALANCEO DE CARGA   ---/--> Maquina Activa IP1 VIPA
                                                     ------> Maquina pasiva IP2
    
    Ese balanceo de carga se puede conseguir de muchas formas:
    - El uso de un balanceador de carga:
        - Apache httpd
        - Nginx
        - haproxy
        - Casi cualquier proxy reverso
    - El uso de VIPAs = IP Virtual 
    
- Activo/activo: Tengo varios computadores TODOS OFRECIENDO EL SERVICIO A LA VEZ
    clientes/usuarios   ------>  BALANCEO DE CARGA   -----> Maquina Activa IP1
                                                     -----> Maquina Activa IP2
                                                     -----> Maquina Activa IP3

#### A nivel de los datos

"Tratar de" garantizar LA NO PERDIDA DE INFORMACION / acceso a la información

De nuevo tiramos de REDUNDANCIA:

- Intentamos tener los datos almacenados en distintas ubicaciones (servidores incluso en zonas geográficas distintas)

Estandar en producción. En cuántos sitios se guarda un dato al menos? En 3 <~ RAID 5

### Escalabilidad

Que la infraestructura se adapte a las necesidades de cada momento.
Y hoy día esas necesidades son muy cambiantes. No es como hace 20 años: INTERNET

Es normal una app que en un momento dado tenga 0 peticiones y a la hora 1000000
y al ahora 0 peticiones y así día tras día? Web telepizza

A qué dimensiono mi infra? Al pico o al valle? Antiguamente nos dimensioábamos al PICO
Hoy en día: A TODO ! Me adapto.

Y si no tengo casi usuarios, quiero muy poca infra
Y si tengo muchos usuarios, quiero mucha infra
Y si no tengo usuarios, no quiero infra

Quien me ofrece eso? CLOUDS (ofrecen infraestructura como servicio)
Donde hago pago por uso !

No es solo cuestión de infra.... sino también de programas en funcionamiento en esa infra!


Quién se encargaba hace 15 años de operar estos entornos? SYSADMINS con un busca metido en el culo !
- De reiniciarlos si se caíantiguamente
- De instalar uno nuevo
- De añadirlo a un cluster
- De meterlo en un balanceador de carga
- De sacar el viejo
- De reinistalar una máquina 

A día de hoy, quién opera estos entornos, quién hace estas cosas? KUBERNETES

No quiero sysadmins haciendo eso. Por qué?
- Caros     comparado con quien? KUBERNETES
- Lentos    comparado con quien? KUBERNETES
- Errores   comparado con quien? KUBERNETES que no comete. Es un programa si lo he configurado bien, errores 0.


## Entorno de producción basado en Kubernetes

Cluster de Kubernetes:
    
    - Máquina 1
        Gestor de contenedores: Tipo docker
        CRIO o containerd
    - Máquina 2
        CRIO o containerd
    - Máquina 3
        CRIO o containerd
    - ...
        CRIO o containerd
    - Máquina n
        CRIO o containerd
    
    - MaquinaMaestra1
        CRIO o containerd
            Kubernetes
    - MaquinaMaestra2
        CRIO o containerd
            Kubernetes
    - MaquinaMaestra3
        CRIO o containerd
            Kubernetes

Nuestra misión, indicarle a Kubernetes cómo queremos que opere el entorno de producción.

- Quiero tener tal app instalada                                                                
    De esa aplicación quiero tener entre 3 y 20 replicas en función de la carga de trabajo
    % CPU > 40% ESCALA !
    Cada replica con 8 Gbs de RAM y acceso a 2 CPUs
    y que las instales de tal forma

    DEPLOYMENT, STATEFULSET, DAEMONSET, HPA, PVC, PV 

- Quiero que montes un balanceador de carga y lo gestiones automáticamente
    
    SERVICE

- Quiero que montes un proxy reverso y lo gestiones, para permitir el acceso a las apps

    INGRESS CONTROLLER / INGRESS

- Quiero que te encarges de que mis app tengan acceso seguro por https... 
  y que gestiones la generación/regeneración de los correspondientes CERTIFICADOS

Balanceador de carga
Proxy reverso

----

Aquí hay un problema añadido a todo esto: 
- Metodologías ágiles
- Devops

## Metodologías ágiles

Es una alternativa (la que se ha impuesto totalmente) a la metodologías clásicas de desarrollo en cascada.
Pretende evitar la gran falacia de las metodologías tradicionales:
    > El día 1 del proyecto voy a ser capaz de conseguir unos requisitos PERFECTOS e INVARIANTES:   MENTIRA !
                                                                                                    IMPOSIBLE

Que se basan en hacer una entrega incremental del producto.
Empiezo un proyecto y a los 15 dias hay entrega en producción
                            -------             -------------
    Una versión 100% funcional. Quizas solo con un 15% de la funcionaliad, pero 100% funcional
    
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad
Y a las 3 semanas otra entrega +5% de la funcionaldiad

Esto nos ha resuelto el problema de los requisitos cambiantes. 
Los requisitos siguen cambiando, pero ahora me entero antes de los cambios!

Pero lo que no me cuentan muchas veces es que ha traido OTROS PROBLEMAS nuevos que no había antes:
- Cuantas veces instalaba yo en prod antes (con las metodologías tradicionales)? 1 al final
- Y como fallaba todo porque no se habia probao na', la repetia 3 veces

Y ahora, cuantas instalaciones hago en prod para un proyecto? Cada 2 / 3 semanas
Como ?????? 
Cúanta pasta ?? €€€€€ 
- Cuantos técnicos necesito? 

Otros problemas con la metodologías ágiles.
- Cuántas veces probaba un sistema antes? Al final ( o nunca... que se joda el cliente y pruebe)
- Y ahora... Cada 2 / 3 semanas que subo a producción

Como ?????? 
Cúanta pasta ?? €€€€€ 
- Cuantos tester necesito? 

SOLUCION ! Por qué pasta no me van a dar más.... DEVOPS

## DEV--->OPS:

Cultura de la AUTOMATIZACION !

- Integración continua:     Tener automaticamente y siempre en el entorno de INTEGRACION lo último que ha hecho 
                            los desarrolaldores sometido a pruebas automatizadas
- Entrega continua:         Poner automaticamente en manos del cliente final la última version probada del producto
- Despliegue continuo:      Instalar en automatico la ultima versión de un sistema en producción

Todo se desencadena desde una UNICA ACCION: Desarrollador haga un COMMIT de su código en GIT (SCM)

Se la han liado al desarrollador. A ese es al que hoy en día le han metido el busca en el culo !

El problema es que todas las cosas que antes montaban los de sistemas en PROD


### Entregable de un desarrollo

Antes: Programa + documentación + Procedimiento de Instalación / Operación 

Hoy en día: Unas imágenes de contenedor + (plantilla de) Fichero de despliegue en Kubernetes
                    ||                                              ||
            El programa ya instalado                Describir el procedimiento de operación para Kubernetes

LINEA 705 = De eso va este curso !

En este curso, vamos a trabajar:
> Unas imágenes de contenedor + Fichero de despliegue en Kubernetes (Configuración concreta)

A este curso le sigue el curso: PROGRAMACION EN HELM:
> Plantillas de Fichero de despliegue en Kubernetes = CHART DE HELM (te permite genearr configuraciones concretas... todas las que quieras)
