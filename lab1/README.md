---
title: "lab1"
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
```
### Описание полей датасета: timestamp,src,dst,port,bytes 
### IP адреса внутренней сети начинаются с 12-14
### Все остальные IP адреса относятся к внешним узлам

## Задание 1: Надите утечку данных из Вашей сети
### Важнейшие документы с результатми нашей исследовательской деятельности в области создания вакцин скачиваются в виде больших заархивированных дампов. Один из хостов в нашей сети используется для пересылки этой информации – он пересылает гораздо больше информации на внешние ресурсы в Интернете, чем остальные компьютеры нашей сети. Определите его IP-адрес.

```{r}
file <- arrow::read_csv_arrow("traffic_security.csv",schema=schema(timestamp=int64(),src=utf8(),dst=utf8(),port=int32(),bytes=int32()))
```

```{r}

filter(file,str_detect(src,"^((12|13|14)\\.)"),
         str_detect(dst,"^((12|13|14)\\.)",negate=TRUE)) %>% 
  select(src,bytes) %>%
  group_by(src)%>% 
  summarise(bytes=sum(bytes))%>%
  slice_max(bytes)%>%
  select(src)
```