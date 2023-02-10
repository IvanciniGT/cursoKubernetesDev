# Que es un pv (PersistentVolume en kubernetes)

Es una referencia a un espacio de almacenamiento

La implicación de esto es que Kubernetes NO VA A CREAR el espacio de almacenamiento, ese debe estar creado, externamente.

Yo, DESARROLLADOR lanzaré una PVC (Petición de volumen) pvc-1

Un ADMINISTRADOR deberá:
1º Crear un espacio de almacenamiento en algún sitio:
- Cloud
- Cabina
- NFS
- ...
2º Dar de alta una raferencia a ese espacio de almacenamiento en Kubernetes => Lanzar una PV


Antiguamente, había 2 opciones:

OPCION 2:

El administrador creaba 80 volumenes con caracteristicas variadas en un gestor de almacenamiento. (CLOUD, CABINA...)
El admisnitardor daba de alta todos esos volumenes en Kubernetes: PV

El desarrollador poedía un volumen con las características que le interesase ...
esperando que hubiera sido creado algun volumen que le satisfaciera sus peticiones

Kubernetes hacia match si encontraba una PVC y un PV compatibles.

OPCION 1:

El desarrollador escribe una PVC, diciendo:
    quiero un espacio de almacenamiento (VOLUMEN) con las caracteristicas C
El admisnitardor estaba con el ojo en la pantalla del kubernetes... y si veía que algun desarrollador
había lanzado una PVC, miraba las características del volumen solicitado.
Después iba a su gestor de volumenes de preferencia (cloud, NFS, Cabina....) y creaba un volumen
Luego volvía a Kubernetes y registraba en Kubernetes ese volumen, con sus características (emitia una PV)
Por último Kubernetes vinculaba la PV y la PVC por ambos hablar de un volumen con las mismas características.

    
    Desarrollador lanza la PVC1, pidiendo
        20Gbs rapiditos
    Admisnirador, ve la PVC que se ha lanzado y se va a AMAZON
        Pulsa en crear volumen de 20 Gbs rapidito
        Amazon le da un ID de volumen
    Administrador de nuevo, crea un PV en Kubernetes PV1
        Donde detalla que hay un volumen en amazon disponible con 20Gbs rapidito, cuyo id es el que le haya devuelto Amazon
    
    
Van dentro de un Namespace                          No van dentro de un Namespace. Son globales    
PVC1                                                PV1 <<<-- id que devuelve AMAZON al crear el volumen -->>> VOLUMEN AMAZON
20 Gbs rapiditos                                    20 Gbs rapiditos
    ^                                                ^
    ---- Kubernetes los vincula, ---------------------
        por tener caracteristica compatibles
        
Entre medias, otro desarrollador pide una PVC2, con 20Gbs y rapidito, 
A lo mejor kubernetes le enchufa a la PVC2 la PV1... y jode al desarrolladore de la PVC1... que se espera!

Una vez que un volumen ha sido asignado a una PVC, ese volumen pasa a estar ASIGNADO (BOUND) y ya no se entregará (vinculará) con NINGUNA OTRA PVC, 
NUNCA MAS EN LA VIDA !
Aunque la PVC se elimine. el PV quedaría RELEASED... pero no se podrá vincular de nuevo.

HOY EN DIA:

El adminsitrador instala un programa (PROVISIONADOR DE VOLUMENES) dentro de Kubernetes.
Y configura dicho provisionador para que cuando se lance una PVC con unas determinadas características, el programa:
1- Cree en el gestor de volumenes AUTOMATICAMENTE (cloud, cabina, nfs) un volumen
2- Registre el volumen en Kubernetes a través de una PV

El desarrollador pide una PVC, con unas caracteristicas.
Si hay un PROVISIONADOR montado para satisfacer a esas caracteristica, el PROVISIONADOR se pone en marcha (el programa)

De nuevo Kubernetes los vincula.

# Pregunta 2. Para que sirven las PVC?

- Para solicitar un volemun persistente... Y es que no puede meterlo el desarrollador directamente?
  PODRIA HACERLO PERO NO TIENE LOS DATOS, NO LO HARÁ EN LA PRACTICA
- Para poder REUTILIZAR UN VOLUMEN <<<< IMPORTANTISIMO !!!!!!

Una vez un volumen PV ha sido vinculado a una PVC NUNCA MAS se vinculará con otra PVC.

    POD1    
        Requiere un volumen ---------> PVC1 <-----------------------> PV -------> VOLUMEN EN EL GESTOR DE ALMACENAMIENTO
                                       7Gbs                          10Gbs          200Tbs

    Quiero actualizar el software del POD1

    POD2
        Requiere un volumen ---------> PVC1 <-----------------------> PV -------> VOLUMEN EN EL GESTOR DE ALMACENAMIENTO
                                        ^
    POD3                                |
        Requiere un volumen -------------
        
    Si borro los pods y la PVC1
                                                                      PV -------> VOLUMEN EN EL GESTOR DE ALMACENAMIENTO 
                                                                      ** Y este PV es el que queda marcado como RELEASED y ya no se reasignará a otra PVC
                                                                      
Si necesitamos en un momento ampliar un espacio de almacenamiento.
Varios comentarios a este respecto:
1- El espacio de almacenamnto que pongas en la PVC A kubernetes se la trae al peiro.
Kubernetes NO VALIDA espacios de almacenamiento. No es su responsabilidad.
Solo usa ese dato para hacer match entre PVC y PV 

Dicho eso:
2-  Si el gestor de volumenes me permite ampliar el volumen... lo amplio y punto pelota
    Pero puede pasar que el gestor de volumenes no lo permita. En este caso: FOLLON !
    Me toca hacer PVC nueva, PV nuevo, VOLUMEN nuevo.
    Y a manita copiar los datos del volumen antiguo al nuevo!



# Variables de entorno

QUIEN RELLENA EL FICHERO CON LA PLANTILLA DEL POD? Desarrollador

Y ese sabe el usuario y la password de la BBDD de producción? NI DE COÑA !
Y ese sabe el usuario y la password de la BBDD de desarrollo? SI
Y ese sabe el usuario y la password de la BBDD de pre-produccion? PUEDE 

Cuantos usuarios y contraseñas vamos a meter aqui? LA HUEVA !

Quien conoce los datos de la BBDD? DESARROLLO? NO...
Administración de producción.

Y los admisnitardores deben tocar este fichero: LA PLANTILLA DE POD? NI
Le corto las manos YO DESARROLLADOR 

Esos datos no van a estar AQUI metidos... Estarán aqui REFERENCIADOS !


---

Llegados a este punto, YA ESTAIS EN DISPOSICION DE MONTAR NUESTRO WP !

Vosotros solitos ! con vuestras manitas(manazas) !

Ahora mismo no tenemos disponible un ingresscontroller en nuestro cluster.

Por lo tanto  la única forma de exponer el servicio de WP es mediante un Servicio node port
---

# Afinidades

## Afinidad a nivel de nodo

    nodeName: ip-172-31-0-253   Que ya no tengo HA 

    nodeSelector:
        etiqueta: valor         Etiqueta que tienen que tener los NODOS en los que este pod se despliegue
                                Esto sirve para? 
                                    Nodos con ciertas características especiales:
                                        Arquitectura de Hardware
        kubernetes.io/arch: amd64
                                        Gráfica GPU : Machine learning, Data mining, Deep learning

    affinity:
        nodeAffinity:
            nodeAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                nodeSelectorTerms:
                - matchExpressions:
                  - key: topology.kubernetes.io/zone
                    operator: In # NotIn # Exists DoesNotExists Gt Lt
                    values:
                    - antarctica-east1
                    - antarctica-west1
              preferredDuringSchedulingIgnoredDuringExecution:
              - weight: 1
                preference:
                  matchExpressions:
                  - key: another-node-label-key
                    operator: In
                    values:
                    - another-node-label-value
              - weight: 2
                preference:
                  matchExpressions:
                  - key: another-node-label-key
                    operator: In
                    values:
                    - another-node-label-value
    
## Afinidad a nivel de pod

## Antiafinidad a nivel de pod

Esta es la más usada de todas las reglas de afinidad..
Casi siempre queiro antiafinidad conmigo mismo
    

    YO soy un pod con la etiqueta: app=wp

    affinity:

        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: NotIn
                values:
                - wp
            topologyKey: zone
            
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - wp
            topologyKey: zone
                        # kubernetes.io/hostname
                         maquinas-potentes



zona geografica 1
                            AFINITY         ANTIAFFINITY
    Maquina 1                   √               x
        NADA
    Maquina 2                   √               x
        app: wp                
    Maquina 3                   √               x
        app: bbdd               
    Maquina 4                   √               x
        app: wp
        app: bbdd

zona geografica 2
                            AFINITY         ANTIAFFINITY
    Maquina 1                   x               x
        NADA
    Maquina 2                   x               x
        app: wp                

zona geografica 3
                            AFINITY         ANTIAFFINITY
    Maquina 1                   √               √
        NADA
    Maquina 2                   √               √
        app: bbdd                


Imaginate que quieres desplegar WP en tu cluster

Tu tienes un cluster en 3 zonas geograficas

Quiero desplegar el WP allá donde no haya ya un WP 
    Antiafinidad contigo mismo pero a nivel no de máquina, sino de zona
    Donde "zona" es un label que TU HAS PUESTO CON ESE NOMBRE PORQUE TE HA DADO LA GANA 
    a todas las maquinas de la misma zona geografica

    Antiafinidad con pods wp a nivel de zona (topologia zona)

Replicas: 3

Madrid
    Maquina 1
    Maquina 2
        WP1 
    Maquina 3
    Maquina 4
Cataluña
    Maquina 1
    Maquina 2
    Maquina 3
        WP2
    Maquina 4
Andalucia
    Maquina 1
        WP3
    Maquina 2
    Maquina 3
    Maquina 4


# Pruebas

Cuando un pod no está operativo que hace Kubernetes? 
              -----------------

Qué significa que un pod no está operativo?

Cuándo se considera que un pod no está operativo?
- Cuando el proceso principal no se está ejecutando. 
  ES CIERTO... pero solo es el muy principio de este tema en KUBERNETES !

Evidentemente si lanzo un poc con nginx.... y el proceso de nginx se cae, el pod hay que reiniciarlo.
No está operativo.

Pero... El hecho de que el proceso esté corriendo es GARANTIA SUFICIENTE de que todo esté bien?
De que el nginx esté "operativo"? NO
Puede estar el proceso pillao.

En ese caso Kubernetes lo reiniciaría? El problema es que Kubernetes no entiende el significado de la palabra "pillao"
Al menos a priori.

En kubernetes un pod que ya esté asignado tiene 3 estados:
- INICIALIZANDO
- CORRIENDO
- LISTO

Y para cada uno de los estados, EN KUBERNETES HEMOS OGLIGATORIAMENTE de definir las pruebas que demuestren que está en ese estado.

MYSQL
Inicializando:  Si el proceso está operativo: Lo dejo que siga su curso
Corriendo:      Conectarme a la BBDD y ver si está montada ... pero con usuario administrador
Listo:          Conectarme con un usuario normal y hacer queries

Un backup en frio
- Necesito bloquear el acceso a todos los usuarios salvo al administrador.

El pod está LISTO para prestar servicio? NO
Pero está corriendo? SI y lo debo respetar? SI

Si un pod no está inicializado: KUBERNETES LO MATA y lo lanza de nuevo
Si un pod no está corriendo:    KUBERNETES LO MATA y lo lanza de nuevo
Si un pod no está listo:        KUBERNETES LO SACA DEL BALANCEADOR DE CARGA y espera
                                a qué esté LISTO para meterlo en el balanceador de carga (SERVICIO)





