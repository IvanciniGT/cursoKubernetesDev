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