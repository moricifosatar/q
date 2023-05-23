---
title: "lab2"
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


```{r,warning=FALSE, message=FALSE, error=FALSE}
file <- arrow::read_csv_arrow("traffic_security.csv",schema = schema(timestamp=int64(),src=utf8(),dst=utf8(),port=uint32(),bytes=uint32()))
```

```{r,warning=FALSE, message=FALSE, error=FALSE}
file1 <- arrow::read_csv_arrow("traffic_security.csv",schema = schema(timestamp=int64(),src=utf8(),dst=utf8(),port=uint32(),bytes=uint32()))
```


## Задание 2: Надите утечку данных 2

### Другой атакующий установил автоматическую задачу в системном планировщике cron для экспорта содержимого внутренней wiki системы. Эта система генерирует большое количество траффика в нерабочие часы, больше чем остальные хосты. Определите IP этой системы. Известно, что ее IP адрес отличается от нарушителя из предыдущей задачи.

###  Нерабочим временем будем считать интервал с 0:00 по 15:00, так как там наименьшая активность по сравнению с интервалом с 16:00 по 24:00, что видно ниже:


```{r}
file$timestamp_seconds <- file$timestamp / 1000
file$timestamp <- as.POSIXct(file$timestamp_seconds, origin = "1970-01-01", tz = "Europe/Moscow")
file$hour <-  format(file$timestamp, format = "%H")
file$minutes <- format(file$timestamp, format = "%M")
```

```{r}
ahours <- file %>% group_by(hour) %>% summarise(N = n())
select(arrange(ahours,desc(N)),N,hour)
```

### Определим нужный нам IP-адрес :

```{r}
file1 %>%
  select(timestamp, src, dst, bytes) %>%
   filter(src != "13.37.84.125") %>%
  mutate(outside_traffic = (str_detect(src,"^((12|13|14)\\.)") & !str_detect(dst,"^((12|13|14)\\.)")), hour = hour(as_datetime(timestamp/1000))) %>%
  filter(outside_traffic == TRUE, hour >= 0 & hour <= 15) %>%
  group_by(src) %>%
  summarise(total_bytes = sum(bytes),) %>%
  arrange(desc(total_bytes)) %>%
  head(1) %>%
  collect()
"Ответ: 12.55.77.96"
```