library(RCurl)
library(XML)
library(stringr)
library(rjson)
library(dplyr)
library(data.table)
### 读取百度地图经纬度数据

#循环解析过程
ak <- "百度AK"
setwd("D:/Users/JACKY/Desktop/jingweidu")
filename_list <- list.files()
num_list <- length(filename_list)

#数据清洗
for (j in 1:num_list) {
        
        filename <- filename_list[j]
        shop_data <- read.table(filename)
        View(shop_data)
        shop_name <- names(read.table(filename_list[6]))
        #shop_data1 <- shop_data[,is.na(shop_data[1,])==F][,-1]
        shop_data2 <- shop_data[, -c(1, 3, 5, 7, 9,11, 13, 15, 17, 19, 21,23)]
        shop_data2 <- shop_data[, -c(1, 3, 5, 7, 9, 13, 15, 17, 19, 21,22)]
        
        names(shop_data2) <- shop_name
        View(shop_data2)
        write.csv(shop_data, paste0(filename))
}

#获取经纬度
for (j in 1:num_list) {
        
        filename <- filename_list[j]
        shop_data <- read.table(filename)
        names(shop_data)
        shop_adr <- paste0(shop_data$adr_street, shop_data$adr_num)
        num <- length(shop_adr)
        
        lng_lat <- data.table()
        for (i in 1:num) {
                location <- shop_adr[i]
                
                shop_name <-
                        shop_data[which(shop_adr == location), 1] %>% as.character()
                shop_adr_net <-
                        shop_data[which(shop_adr == location), 2] %>% as.character()
                lng = NA
                lat = NA
                #报错处理，防止循环中断
                tryCatch({
                        #构造请求连接
                        url <-
                                paste(
                                        "http://api.map.baidu.com/geocoder/v2/?ak=",
                                        ak,
                                        "&callback=renderOption&output=json&address=",
                                        location,
                                        sep = ""
                                )
                        #利用URLencode()转换为可解析的URL地址
                        url_string <- URLencode(url)
                        #通过readLines读取URL地址，并解析JSON格式的结果
                        json <- readLines(url_string, warn = F)
                        geo <-
                                fromJSON(substr(
                                        json,
                                        regexpr('\\(', json) + 1,
                                        nchar(json) - 1
                                ))
                        #在解析结果中提取经纬度
                        lng <- geo$result$location$lng
                        lat <- geo$result$location$lat
                }, error = function(e) {
                        cat("ERROR :", conditionMessage(e), "\n")
                })
                
                #存储到已经建好的字段中
                lng_lat1 <-
                        data.table(
                                shop_name,
                                shop_adr_net = shop_adr_net,
                                longitude = lng,
                                latitude = lat
                        )
                lng_lat <- rbind(lng_lat, lng_lat1)
                
        }
        write.csv(lng_lat, paste0("lng_lat_", filename))
}

#合并数据
setwd("D:/Users/JACKY/Desktop/jingweidu1")
filename_list <- list.files()
num_list <- length(filename_list)
shop_data <- data.table()

for (j in 1:num_list) {
        #j<-2
        filename <- filename_list[j]
        shop_data1 <- read.csv(filename)
        shop_data <- rbind(shop_data,shop_data1)
}
#去重
shop_data2 <- shop_data[!duplicated(shop_data$shop_addr_net),]
write.csv(shop_data, paste0("all_shop_data.csv"))

#数据整合
shop_data1 <- read.csv(filename_list[1])
shop_data2 <- read.csv(filename_list[2])
shop_data <- full_join(shop_data2,shop_data1,by="shop_adr_net")
shop_data3 <- shop_data[!duplicated(shop_data$shop_adr_net),]
write.csv(shop_data3, paste0("all_data.csv"))




