library(RCurl)
library(XML)
library(stringr)
library(rjson)
library(dplyr)
library(data.table)
### 读取百度地图经纬度数据
library(rjson)
#循环解析过程
#location1 <- location[1]
ak <- "Lp6H2WLQTh6ChqBiUZEgrG57AGiOVPfm"
setwd("C:/Users/Administrator/Desktop/jingweidu")
filename_list <- list.files()
num_list <- length(filename_list)
for(j in 1:num_list){
        j <- 6
        
filename <- filename_list[j]
shop_data <- fread(filename)
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
      
        tryCatch({
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
                        fromJSON(substr(json, regexpr('\\(', json) + 1, nchar(json) - 1))
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





library(parallel)

setwd("C:/Users/Administrator/Documents/jingweidu")
filename_list <- list.files()
#i <- 9
filename <- filename_list[i]
shop_data <- read.table(filename_list[i], header = T)
shop_adr <- paste0(shop_data$adr_street, shop_data$adr_num)

ak <- "Lp6H2WLQTh6ChqBiUZEgrG57AGiOVPfm"
setwd("C:/Users/Administrator/Documents/jingweidu")
filename_list <- list.files()
k <- 11
filename <- filename_list[k]
shop_data <- read.table(filename_list[k], header = T)
shop_adr <- paste0(shop_data$adr_street, shop_data$adr_num)

system.time({
        i <- 1:length(shop_adr)
        cl <- makeCluster(4)
        data_part2 <- parLapply(cl, i, get_lng_lat)
        data_total <- do.call("rbind", lng_lat)
        num <- length(data_part2)
        data_part <-
                as.data.frame(matrix(
                        as.character(data_part2),
                        nrow = num,
                        byrow = T
                ))
        stopCluster(cl)
        write.table(data_part, paste0("lng_lat_", filename))
        
})


#整理结果

write.csv(result1, "lng_lat8.csv")
#address1 <- as.vector(address1$comname)
#address <- vector()
#for(i in 1:7189){
#       address2 <- address1[i]
##       address3 <- paste0("成都", address2)
#      address <- c(address,address3)
#}