---
title: "lab3"
output: html_document
date: "2023-03-21"
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## 1.Скачивание пакетов и краткое описание

```{r}
library(arrow)
library(dplyr)
library(stringr)
library(lubridate)
library(ggplot2)
"Описание полей датасета: timestamp,src,dst,port,bytes "
" IP адреса внутренней сети начинаются с 12-14"
"Все остальные IP адреса относятся к внешним узлам"

```
## Задание 3: Найдите утечку данных 3
### Еще один нарушитель собирает содержимое электронной почты и отправляет в Интернет используя порт, который обычно используется для другого типа трафика. Атакующий пересылает большое количество информации используя этот порт, которое нехарактерно для других хостов, использующих этот номер порта. Определите IP этой системы. Известно, что ее IP адрес отличается от нарушителей из предыдущих задач.

### Нужно найти только те порты, на которые отправлено меньше всего данных
```{r,warning=FALSE, message=FALSE, error=FALSE}
file %>%
  select(src, dst, bytes,port) %>%
  mutate(outside_traffic = (str_detect(src,"^((12|13|14)\\.)") & !str_detect(dst,"^((12|13|14)\\.)"))) %>%
  filter(outside_traffic == TRUE) %>%
  group_by(port) %>%
  summarise(total_data=sum(bytes)) %>%
  filter(total_data < 5*10^9) %>%
  select(port) %>%
  collect() -> ports

ports <- unlist(ports)
ports <- as.vector(ports,'numeric')
```


### Выбираем данные с нужными номерами портов
```{r,warning=FALSE, message=FALSE, error=FALSE}
file %>%
  select(src, dst, bytes,port) %>%
  mutate(outside_traffic = (str_detect(src,"^((12|13|14)\\.)") & !str_detect(dst,"^((12|13|14)\\.)"))) %>%
  filter(outside_traffic == TRUE) %>%
  filter(port %in% ports) %>%
  group_by(src,port) %>%
  summarise(total_bytes=sum(bytes)) %>%
  arrange(desc(port)) %>%
  collect() -> df

```


### Порты с маскимальным кол-вом данных
```{r,warning=FALSE, message=FALSE, error=FALSE}
df %>%
  group_by(src, port) %>%
  summarise(total_data=sum(total_bytes)) %>%
  arrange(desc(total_data)) %>%
  head(10) %>%
  collect()
```


### Количество хостов к портам
```{r,warning=FALSE, message=FALSE, error=FALSE}
df %>%
  group_by(port) %>%
  summarise(hosts=n()) %>%
  arrange(hosts) %>%
  head(10) %>%
  collect()
```
### Из предыдущих шагов следует вывод, что ip-адрес злоумышленника 12.55.77.96, а порт 31, т.к. из таблицы в 5 пункте видно, что 31 порт использовал только 1 хост и в тоже время из таблицы в 4 пункте видно, что больше всего данных было передано именно по этому порту 
```{r,warning=FALSE, message=FALSE, error=FALSE}
df %>%
  filter(port == 31) %>%
  group_by(src) %>%
  summarise(total_data=sum(total_bytes)) %>%
  collect()
```

### Ответ: 12.55.77.96