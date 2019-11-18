Algoritmo rápido de Reducción de Trayectorias de Plegamiento
------------------------------------------------------------

	El algoritmo inicia particionando la trayectoría en segmentos o bins de N estructuras contiguas en el tiempo. Sobre cada bin se realiza primero un agrupamiento local rápido y después un agrupamiento global detallado. El agrupamiento rápido aprovecha el ordenamiento temporal de las estructuras implícito en la trayectoría y forma grupos tomando inicialmente la primera estructura del bin (estado inicial) como característica del primer grupo. La siguiente estructura del bin en orden de tiempo se compara con la representativa usando la métrica TM-score (0~1, donde 0 son diferentes y 1 son iguales) y si el valor es mayor que un umbral predeterminado, la estructura se considera redundante y se elimina, de lo contrario se la toma como característica de un nuevo grupo. Este mismo proceso se sigue con las siguientes estructuras pero teniendo en cuenta que las comparaciones se realizan solo con las estructuras características de cada grupo y no con todas las estructuras que conforman el grupo, lo cual reduce el número de comparaciones en gran medida frente a un algoritmo convencional de agrupamiento. Además, para evitar más comparaciones, estas se realizan de atrás hacia adelante, es decir, las estructuras se comparan con la característica del último grupo formado y si no cumple el umbral entonces se compara con el anterior a este y así sucesivamente. Esto se realiza así ya que se supone que a medida que avanza la simulación de plegamiento, las nuevas estructuras de la trayectoria van a ser más parecidas localmente (valores altos de TM-score) a las últimas que ocurrieron. 

	En la segunda fase, el algoritmo toma las estructuras características de cada segmento o bin y realiza con ellas un nuevo agrupamiento utilizando la métrica TM-score que tiene en cuenta propiedades globales del plegamiento y que no es tan sensible a variaciones locales como sucede con el RMSD. Este nuevo agrupamiento forma M grupos de los cuales se toman sus K estructuras centrales o medoides como representativas y que finalmente serán las que después del proceso de reducción representan a todo el segmento o bin y así al final a toda la trayectoria.

	El algoritmo es fácilmente paralelizable ya que una vez particionada la trayectoría el proceso de reducción es el mismo para cada segmento o bin, lo que permite que el procesamiento se reparta sobre cada bin, es decir, tanto la reducción local como la reducción global se ejecutan al mismo tiempo sobre cada bin y por lo tanto si existen N bins, cada uno de ellos se podría asignar a un proceso, hilo, o procesador.

Detalles de Implementación

	El algoritmo está implementado como a través de tres scripts: 

	• pr00_main.py: Script principal en lenguaje Python que toma los parámetros iniciales y llama a los otros scripts envíandole los parámetros necesarios.

	• pr01_createBins.py: Script en lenguaje Python que realiza la partición

	• pr02_localReduction.R : Script en lenguaje R que realiza la reducción local.

	• pr03_globalReduction.R: Script en lenguaje R que realiza la redución global..

	• tmscorelg.so: librería dinámica en fortran que implementa la métrica TM-score
	
