---
title: "Práctica 2: Limpieza y validación de los datos"
author:
- Fiol Bibiloni, Andreu
- Navarro Yepes, José Andrés
date: "11 de junio de 2019"
output: pdf_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = T)
library(missForest)
library(knitr)
library(DescTools)
```

# 1. Descripción del *datatset*

El dataset escogido es llamado *Titanic*, obtenido de la página web de Kaggle (https://www.kaggle.com/c/titanic). Es un dataset recomendado por el enunciado de esta práctica, y sirve para la competición *Titanic: Machine Learning from Disaster*, organizada por la propia página y enmarcada en la categoría *Getting Started Prediction Competition*.
Para su descarga hemos utilizado la API de Kaggle, que funciona con Python 3.

```{r}
# Downloading the files of the competition. We need the Kaggle API (works with Python 3)
system("kaggle competitions download -c titanic")
# Loading the training file
trainData <- read.csv("train.csv")
# Loading the test file
testData <- read.csv("test.csv")
```

Es un dataset muy utilizado porque marca una de las tragedias internacionales más conocidas de la historia (en parte gracias a James Cameron) y porque para no deja de ser un dataset útil para practicar aprendizaje automático mediante algún lenguaje de programación como Python o R. La pregunta más importante a la que intentamos responder es a predecir cuántos pasajeros y qué tipo de pasajero sobreviviría a esta catástrofe. Derivada de ésta podremos contestar a otras preguntas más curiosas como la clase y el sexo de los supervivientes 

Es un dataset que está ya dividido en dos partes: una de entrenamiento y otra de prueba. Veamos las características del grupo de entrenamiento.

```{r}
str(trainData)
summary(trainData)
```

Veamos ahora las características del grupo de prueba:

```{r}
str(testData)
summary(testData)
```

Como podemos comprobar, el conjunto de prueba carece de la variable objetivo *Survived*. Por lo tanto, nuestro objetivo será predecir correctamente si los pasajeros del grupo de prueba sobrevivieron o no, a partir de sus datos.

En este proyecto se han utilizado ambos subconjuntos. Por una parte, con el training set, como su nombre indica, se pretende entrenar los datos para en la competición crear un modelo de Machine Learning. Por otra parte, el test set es más bien para comprobar cómo se desempeñan los datos con ‘unseen data’.
Acerca de ls variables mencionaremos que la columna Survived representa si el pasajero sobrevivió (1) o no (0); la columna de edad representa los años dl pasajero, passenger class (pclass) representa la clase en la que viajaban (primera clase = 1,  segunda =  2 y tercera = 3); SibSp es el número de hermanos/cónyuges a bordo del Titanic; Parch es número de padres/niños a bordo (si un niño tiene 0 significa que viajaban sin padres pero con niñera); ticket representa el número de ticket; fare es la tarifa del pasajero (precio del pasaje); cabin es el número de cabina de cada pasajero; embarked es el puerto de embarque, pudiendo ser tres tipos de puertos C = Cherbourg, Q = Queenstown y S = Southampton y el passengerid es el identificador único atribuido a cada pasajero en forma de número entero, siendo la clave primaria de la tabla. 

En cuanto a SibSp y Parch es conveniente clarificar los roles que se han tenido en cuenta en los datos:

●	Hermano: hermano, hermana, hermanastro o hermanastra del pasajero a bordo del Titanic
●	Cónyuge: esposo o esposa del pasajero a bordo del Titanic (amantes y novios se han ignorado o se desconoce)
●	Padre: Madre o padre del pasajero a bordo del Titanic
●	Niño: hijo, hija, hijastro o hijastra del pasajero a bordo del Titanic

# 2. Integración y selección de los datos de interés

En primer lugar uniremos los dos subconjuntos para disponer de un dataset completo.

```{r}
# Unión de los subconjuntos de datos
data <- merge(trainData, testData, all = T)
str(data)
summary(data)
```

Pasamos ahora a seleccionar los datos que nos interesan de cada pasajero. Entre ellos se encuentran el sexo, la edad, la clase, el número de familiares, el precio del pasaje, el lugar de embrque y si sobrevivió o no. No nos interesarán sus nombres, número de ticket, número de pasajero ni número de cabina.

```{r}
# Selección de las variables que nos interesan
data <- data[, c(-1, -3, -8, -10)]
# Comprobación
str(data)
summary(data)
```

# 3. *Data cleaning*

Pasamos ahora a la limpieza de los datos.

## 3.1. Elementos vacíos

Por supuesto, nos encontramos con un buen número de datos vacíos en la columna *Survived* debido a que hemos añadido el suconjunto de prueba sin ese dato. Deberemos hacer frente a ello y a otros posibles datos vacíos. para ello utilizaremos el método missForest, por ser así recomendado por Calvo, Subirats y Pérez (2019).

```{r}
# Comprueba las variables con valores perdidos 
data[data==""] <- NA
names(which(sapply(data, anyNA)))
# Imputación
mydata <- missForest(data, variablewise = T)
# Comprueba que ya no hay valores perdidos
which(is.na(mydata))
```


```{r}
# Nuevo data frame sobre el que trabajaremos
datai <- mydata$ximp
attach(datai)
```


## 3.2. *Outliers*

Una vez tratados los datos vacíos observamos los posibles outliers.

Veamos el boxplot para la edad:
```{r}
boxplot(Age)
```

Observamos que, aunque se aprecian diversos outliers, son siempre edades que se encuentran dentro de lo razonable, por lo que consideramos que estos datos no precisan de más tratamiento.

Pasemos a los daos de hermanos y pareja:

```{r}
boxplot(SibSp)
```

De nuevo, aunque tenemos ciertos valores extremos, niguno se sale de lo que es razonablemente admisible, por lo que dejaremos los valores.

Veamos también el boxplot para el número de padres e hijos:

```{r}
boxplot(Parch)
```

Una vez más nos encontramos con valores asumibles.

POr último observaremos el boxplot para el precio del billete:

```{r}
boxplot(Fare)
```

A pesar del gran número de valores extremos, se trata de una caraterística de los precios en presencia de bienes de lujo como lo fue este viaje inaugural del Titanic.

Concluimos, pues, que en nuestro dataset no hemos hallado la necesidad de actuar sobre los valores extremos.

# 4. *Data analysis*

Disponemos finalmente de un conjunto de datos *limpio* sobre el que realizar análisis de datos. Seguidamente podemos observar las características más importantes de este conjunto:

```{r}
# Análisis descriptivo
summary(datai)
str(datai)
```

## 4.1. Planifación de los análisis

Procederemos a realizar tres análsis que responden a tres preguntas que este dataset podría resolver.
  1: ¿Existe discriminación de precios por razón del sexo en el Titanic? Utilizaremos un contraste de hipótesis.
  2: ¿Qué modelo rige el precio de los pasajes? Utilizaremos una regresión lineal múltiple.
  3: ¿Podremos predecir qué pasajeros sobrevivieron a partir de estos datos? Para ello utilizaremos una regresión logística.

## 4.2. Normalidad

Antes de proceder a las pruebas estadísticas debemos conocer si nuestras variables numéricas cumplen la condición de normalidad.

Empecemos con la edad:
```{r}
# Histograma
hist(Age)
# Test de Shapiro
shapiro.test(Age)
# Gráfica Q-Q
qqnorm(Age)
# Box-Cox
Agebx <- BoxCox(Age, lambda = BoxCoxLambda(Age))
hist(Agebx)
shapiro.test(Agebx)
qqnorm(Agebx)
```

Sigamos con los hermanos y cónyuges:

```{r}
hist(SibSp)
shapiro.test(SibSp)
qqnorm(SibSp)
SibSpbx <- BoxCox(SibSp, lambda = BoxCoxLambda(SibSp))
hist(SibSpbx)
shapiro.test(SibSpbx)
qqnorm(SibSpbx)
```

Hijos y padres:

```{r}
hist(Parch)
shapiro.test(Parch)
qqnorm(Parch)
Parchbx <- BoxCox(Parch, lambda = BoxCoxLambda(Parch))
hist(Parchbx)
shapiro.test(Parchbx)
qqnorm(Parchbx)
```

Por último, la tarifa:

```{r}
hist(Fare)
shapiro.test(Fare)
qqnorm(Fare)
Farebx <- BoxCox(Fare, lambda = BoxCoxLambda(Fare))
hist(Farebx)
shapiro.test(Farebx)
qqnorm(Farebx)
```

Hemos podido comprobar aquí que debemos rechazar la hipótesis de normalidad en todas estas variables, con o sin transformación de Box-Cox, por lo pequeño de sus valores *p*.

## 4.3. Pruebas estadísticas

Tal y como comentábamos en la sección 4.1, procederemos ahora a realizar las tres pruebas estadísticas que hemos considerado más interesantes.

### 4.3.1. Discriminación de precios por edad y/o sexo

En esta prueba queremos dilucidar si el viaje del Titanic tenía precios diferentes en razón de la edad o del sexo, dentro de una misma clase de pasaje. Para ello recurriremos al contraste de hipótesis.
Como hemos encontrado que *Fare* no es una variable normal, recurriremos al contraste de Wilcoxon.

```{r}
# Contraste en general
wilcox.test(Fare~Sex)
# Contraste dentro de la primera clase
wilcox.test(Fare~Sex, subset = Pclass==1)
# Contraste dentro de la segunda clase
wilcox.test(Fare~Sex, subset = Pclass==2)
# Contraste dentro de la segunda clase
wilcox.test(Fare~Sex, subset = Pclass==3)
# Gráficas
boxplot(Fare~Sex)
boxplot(Fare~Sex, subset = Pclass==1)
boxplot(Fare~Sex, subset = Pclass==2)
boxplot(Fare~Sex, subset = Pclass==3)
```

Gráficamente nos encontramos con que las mujeres pagaban más por un billete en el Titanic. Analíticamente, hemos podido comprobar que sí había discriminación de precios, hallándonos en las pruebas de Wilcoxon con valores *p* muy pequeños, que nos hacen rechazar la hipótesis de igualdad.

### 4.3.2. Modelo de regresión lineal para el precio

Elaboraremos un modelo de regresión lineal que explique el precio de un billete del Titanic a partir de los datos que conocemos. En concreto,lo haremos depender del sexo (acabamos de ver que sí ahbía discriminación), del lugar de embarque y, por supuesto, de la clase.

```{r}
# Reordenamos las variables categóricas
SexR <- relevel(Sex, ref = 'male')
EmbarkedR <- relevel(Embarked, ref = 'S')
# Modelo de regresión lineal
modelo <- lm(Fare ~ Pclass+SexR+EmbarkedR)
summary(modelo)
```

Este modelo lineal sólo nos permite explicar el 34% de las variaciones entre un precio y otro, pero sólo necesitamos saber si la persona es mujer, si va a embarcar en Cherburgo (paga más), y la clase de su pasaje.

### 4.3.3. Modelo de regresión logística de la supervivencia al desastre

Para la construcción de este modelo debemos prescindir del conjunto de datos de prueba original.

```{r}
# Datos que usaremos
dataglm <- datai[1:891,]
dataglm$Survived <- as.logical(dataglm$Survived)
# Modelo de regresión logística
model1 <- glm(Survived ~ Pclass+Sex+Age+SibSp+Parch+Fare+Embarked, family = 'binomial', data = dataglm)
summary(model1)
# Modelo de regresión logística mejorado
model2 <- glm(Survived ~ Pclass+Sex+Age+SibSp, family = 'binomial', data = dataglm)
summary(model2)
```

Tras realizar el modelo hemos decidido mejorarlo quitando las variables que no afectan a la superviviencia a la vista del elevado valor *p* de su contraste individual, como el lugar de embarque, el número de padres e hijos o lo que se ha pagado por el billete. Finalmente, tenemos que ser hombre reduce sensiblemente las probabilidades de sobrevivir a una catástrofe así; ser de clases inferiores también afecta negativamente a la supervivencia; ser muy mayor tampoco ayuda; y, curiosamente, viajar con el cónyuge y/o los hermanos reduce las probabilidades de supervivencia. Los datos parecen sugerir que en situaciones así es mejor no tener a nadie de quién preocuparse.

Predigamos ahora los resultados para la competición de Kaggle:

```{r}
# predicción
datatest <- datai[892:1309,]
predicciones <- predict(model2, datatest, type = 'response')
```


# 5. Representación visual de los resultados

Podemos encontrar la representación visual de los resultados en sus respectivos apartados.

# 6. Conclusiones

Nos centraremos aquí en la competición de Kaggle, comparando la predicción obtenida en el apartado 4.3.3. con la obtenida en la imputación con missForest.

Enviaremos a Kaggle tanto estas dos predicciones como una tercera basada en la media de las probabilidades calculadas por ambos métodos:

```{r}
# Histogramas
hist(datatest$Survived)
hist(predicciones)
media <- (datatest$Survived+predicciones)/2
hist(media)
# Predicción dicotómica
forestSub <- datatest$Survived>0.5
logitSub <- predicciones>0.5
mediaSub <- media>0.5
# Creación de los ficheros
submission <- read.csv('gender_submission.csv', header = T)
forestSubm <- submission
logitSubm <- submission
mediaSubm <- submission
forestSubm$Survived <- as.integer(forestSub)
logitSubm$Survived <- as.integer(logitSub)
mediaSubm$Survived <- as.integer(mediaSub)
write.csv(forestSubm, file = 'forest.csv', quote = F, row.names= F)
write.csv(logitSubm, file = 'logit.csv', quote = F, row.names= F)
write.csv(mediaSubm, file = 'media.csv', quote = F, row.names= F)
write.csv(datai, file = 'datai.csv', quote = F, row.names= F)
```

```{r}
system('kaggle competitions submit -c titanic -f forest.csv -m "Using missForest"')
system('kaggle competitions submit -c titanic -f logit.csv -m "Using a LOGIT model"')
system('kaggle competitions submit -c titanic -f media.csv -m "Using the mean of them"')
```

Una vez en Kaggle, el fichero correspondiente al modelo LOGIT obtuvo una puntuación del 75%, mientras la predicción basada en missForest y la media de ambas alacanzaron una puntuación del 76%.


# 7. Código

Podemos encontrar el código R utilizado en este documento a lo largo de todo él. Hemos utilizado *R Markdown* para ello.

# 8. Referencias

Calvo, M., Subirats, L., & Pérez, D. (2019). Introducción a la limpieza y análisis de los datos. Barcelona: UOC.

Kaggle. Titanic: Machine Learning from Disaster. (https://www.kaggle.com/c/titanic) [Consulta: 1 de junio de 2019]

```{r}
kable(data.frame(Contribuciones = c('Investigación previa', 'Redacción de las respuestas', 'Desarrollo código'), Firma = c('AFB, JANY', 'AFB, JANY', 'AFB, JANY')))
```