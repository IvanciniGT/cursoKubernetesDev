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

## NAMESPACE EN KUBERNETES

Es literalmente un espacio de nombres UNICOS dentro del cluster.

Es una agrupación lógica de objetos/configuraciones dentro del cluster.
Dentro de cada grupo no puede haber 2 objetos que tengan el mismo nombre.

Usos:
- Agrupar lógicamente recursos/objetos/configuraciones que estén relacionadas entre si
    
    Despliegue Wordpress
        Deployment   Apache
        Statefulset  BBDD
        Secrets      Contraseñas de la BBDD
        Secrets      Contraseñas del WP
        Configmaps   Configuraciones del WP
        Services     BBDD
        Services     Apache
        Ingress      Apache

- Diferenciar entre entornos
    
    Para una app1:
        app1-produccion
        app1-preproduccion

- Limitar el acceso a recursos/objetos/configuraciones

    Los administradores del cluster crearan para un proyecto 1 o varios ns
    
    Y crearán un usuario para ese proyecto.
    
    Configurarán que ese usuario solo pueda gestionar los recursos / objetos de ese o esos ns
        pero no los de otros ns, que vayan asociados a otros proyectos

- Limitar el uso de recursos físicos

    Los administradores del cluster pueden limitar el uso TOTAL de RAM, CPU, Almacenamiento 
    asociado a un namespace


---
# Para crear documentos YAML de configruaciones de Kubernetes, hemos de conocer NO SOLO YAML, 
sino también el ESQUEMA DE KUBERNETES !

---
# Imágenes de contenedores:

Las encontramos en registros de repositorios de imagenes de contenedor.
El más famoso:
- El de mi empresa 
- docker hub
- quay.io       EL de REDHAT

Cómo identificamos una imagen de contenedor:
    REGISTRY/REPOSITORIO:TAG
    https://registry/nginx:TAG
    
En muchos casos, obviamos la parte del REGISTRY, y toramos de la que haya configurada por defecto en el gestor de contenedores

    docker.io/nginx:latest
    miempresa.com/mirepo:mitag

Siguiente cosita: TAGS:

# Que es un TAG? 

Una etiquete que le ponemos a una IMAGEN DE CONTENEDOR.
La imagen de contenedor tiene su propio ID, que se construye desde una HUELLA del contenedor de la imagen

Por qué usamos TAGS en lugar de IDS?
- Mas legibles
- Una imagen puede tener varios TAGS

Si no ponemos un tag, que ocurre? El gestor de contenedor NO DESCARGA POR DEFECTO la ULTIMA.
                                  Descarga la que tenga el TAG "LATEST"
Más vale que los desarrolladores que hayan subido imagenes le hayan puesto a alguna el tag LATEST
por que si no... me va a decir que esa imagen NO EXISTE

Usar el tag latest es una MUY MALA PRACTICA, COMODO SI, pero MUY MALA PRACTICA.

El problema es que no tengo ni puñetera idea de que versión estoy instanlando. 
LO CUAL EN UN ENTORNO DE PRODUCCION ES INADMISIBLE DESDE CUALQUIER PUNTO DE VISTA

Versiones de software: 3.4.5

                        Cuando se incrementa?
    3   ~>  MAYOR       Rediseño de componentes del software, lo cual puede implicar NO RETROCOMPATIBILIDAD
    4   ~>  MINOR       Al añadir una funcionalidad
    5   ~>  MICRO       Al arreglar un bug

nginx:latest

El desarrollador habrá subido una imagen de contenedor nueva

                                            TAGS
sha256:2934759283712abce3746464ff29347845   1.21.5  
sha256:2934759283712abce3746464ff29347845   1.21.6    
sha256:2934759283712abce3746464ff29347845   1.21.7      1.21    1   latest

Y a esa imagen le pone unos tags

Cuál uso:
    nginx:latest? NI DE COÑA... por qué? El día de mañana ese tag puede estar asociado a la versión 2.1.0
                                         Y todo deja de funciona / o no / npi
    nginx:1.21.5? TAMPOCO...    por qué? Es muy restrictiva
    nginx:1?      TAMPOCO...    por qué? Me puede meter el día de mañabna la versión 1.25
                                         Incluyendo nuevas funcionalidades con potencialmente NUEVOS BUGS
                                         Necesito esas funcionalidades? NO, ya me lo habrían dicho los DESARROLLADORES
    ngins:1.21?   POR SUPUESTO  por qué? Porque tiene las funcionalidades que necesito
                                         Y de esa quiero el mayo MICRO posible, arreglando todos los bugs que se hayan detectado
                                         
Adicionalmente en el TAG Se suele incluir otras informaciones:
- La imagen base utilizada:
    - Ubuntu
    - Debian
    - Oracle oraclelinux
    - Fedora
    - Alpine                    Es una imagen MUY LIGERA pero que no espere ahi encontrar NI UN PUÑETERO COMANDO EXTRA
                                No tengo ni la bash
- Configuraciones adicionales
    - Otros programas que puedan venir instalados