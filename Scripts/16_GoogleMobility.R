library(tidyverse)
library(rtweet)
library(zoo)

get_reply_id <- function(rel_increase) {
  my_timeline <- get_timeline(rtweet:::home_user()) ## Pull my own tweets
  reply_id <- my_timeline$status_id[1] ## Status ID for reply
  return(reply_id)
}


##### Google mobility #####


#### authenticate Twitter account ####

source("C:\\Rdir\\Rscripts\\03A_TwitterAuthentication.r")

Yesterday <- Sys.Date()-1

#### read the latest Google mobility report from the web ####

#download.file("C:\\Rdir\\Rscripts\\Global_Mobility_Report.csv",temp)


temp <- tempfile()
download.file("https://www.gstatic.com/covid19/mobility/Region_Mobility_Report_CSVs.zip",temp)
google_mob_raw2020 <- read.csv(unz(temp, "2020_NL_Region_Mobility_Report.csv"),sep=",")
google_mob_raw2021 <- read.csv(unz(temp, "2021_NL_Region_Mobility_Report.csv"),sep=",")


google_mob_raw <- rbind(google_mob_raw2020, google_mob_raw2021)

#### convert date column to date ####

google_mob_raw$date <- as.Date(google_mob_raw$date)


#### last day check ####
lastGoogleRaw <- tail(google_mob_raw,n=1)
Last_date_in_Google_file <- lastGoogleRaw$date
(Last_date_in_Google_file)

#### filter to whole country only ####

Google_mob_NL <- google_mob_raw[which(google_mob_raw$sub_region_1 == ""),]
Google_mob_NL_short <- Google_mob_NL[ -c(1,2,3,4,5,6,7,8)]
colnames(Google_mob_NL_short) <- c("Datum","retail_recreatie","supermarkt_apotheek","parken","openbaar_vervoer", "werk", "thuis")


##### 7day MA #####


Google_mob_NL_short$MA_retail_recreatie     <- round(rollmeanr(Google_mob_NL_short$retail_recreatie,  7, fill = NA),digits = 1)
Google_mob_NL_short$MA_supermarkt_apotheek  <- round(rollmeanr(Google_mob_NL_short$supermarkt_apotheek,    7, fill = NA),digits = 1)
Google_mob_NL_short$MA_parken               <- round(rollmeanr(Google_mob_NL_short$parken, 7, fill = NA),digits = 1)
Google_mob_NL_short$MA_openbaar_vervoer     <- round(rollmeanr(Google_mob_NL_short$openbaar_vervoer,  7, fill = NA),digits = 1)
Google_mob_NL_short$MA_werk                 <- round(rollmeanr(Google_mob_NL_short$werk,    7, fill = NA),digits = 1)
Google_mob_NL_short$MA_thuis                <- round(rollmeanr(Google_mob_NL_short$thuis, 7, fill = NA),digits = 1)


Google_mob_NL_short$MA_retail_recreatie     <- lead(Google_mob_NL_short$MA_retail_recreatie,3)
Google_mob_NL_short$MA_supermarkt_apotheek  <- lead(Google_mob_NL_short$MA_supermarkt_apotheek,3)
Google_mob_NL_short$MA_parken               <- lead(Google_mob_NL_short$MA_parken,3)
Google_mob_NL_short$MA_openbaar_vervoer     <- lead(Google_mob_NL_short$MA_openbaar_vervoer,3)
Google_mob_NL_short$MA_werk                 <- lead(Google_mob_NL_short$MA_werk,3)
Google_mob_NL_short$MA_thuis                <- lead(Google_mob_NL_short$MA_thuis,3)

Google_mob_NL_short <- Google_mob_NL_short[-1:-6,]


#persco.df=data.frame(date=as.Date(c("2020-09-18", "2020-09-28", "2020-10-13", "2020-11-03", "2020-10-25", "2020-11-17", "2020-11-27", "2020-12-05")), 
 #                    event=c("kroeg uurtje eerder dicht", "We gaan voor R=0,9","Semi-lockdown", "verzwaring semi-lockdown", "Einde herfstvakantie", "Einde verzwaring", "Black Friday", "Sinterklaas"))

#persco.df=data.frame(date=as.Date(c("2020-03-09", "2020-03-12", "2020-03-16", "2020-03-24", "2020-09-18", "2020-09-28", "2020-10-13", "2020-11-03", "2020-10-25", "2020-11-17", "2020-11-27", "2020-12-05", "2020-12-15")), 
#                     event=c("Geen handeschudden", "aanvullende maatregelen",  "scholen/horeca dicht", "inteligente lockdown", "kroeg uurtje eerder dicht", "We gaan voor R=0,9","Semi-lockdown", "verzwaring semi-lockdown", "Einde herfstvakantie", "Einde verzwaring", "Black Friday", "Sinterklaas", "lockdown"))


persco.df=data.frame(date=as.Date(c("2020-03-09", "2020-03-12", "2020-03-16", "2020-03-24", "2020-09-18",
                                    "2020-09-28", "2020-10-13", "2020-11-03", "2020-10-25", "2020-11-17",
                                    "2020-12-15", "2021-01-01", "2021-01-25", "2021-02-08", "2021-03-03",
                                    "2021-04-04")), 
                     event=c("Geen handeschudden", "aanvullende maatregelen",  "scholen/horeca dicht",
                             "inteligente lockdown", "kroeg uurtje eerder dicht", "We gaan voor R=0,9",
                             "Semi-lockdown", "verzwaring semi-lockdown", "Einde herfstvakantie", "Einde verzwaring", 
                             "lockdown","" ,"avondklok", "basisscholen open", "kappers open", "Eerste Paasdag"))

#persco.df=data.frame(date=as.Date(c("2021-02-25")), 
#                     event=c("Meer risico PersCo"))



#last.date.old.wide.mob  <- last.date.old.wide.2

#last.date.old.wide.mob$Rt_avg10 <- (last.date.old.wide.mob$Rt_avg *100)-100

#### met de R ####
last.date.old.wide.3 <- last.date.old.wide.2
last.date.old.wide.3$Rt_avg  <- (last.date.old.wide.3$Rt_avg*50)-50
last.date.old.wide.3$Rt_low  <- (last.date.old.wide.3$Rt_low*50)-50
last.date.old.wide.3$Rt_up   <- (last.date.old.wide.3$Rt_up*50)-50

####   Plot the Google Mobility data 7d MA ####

ggplot(Google_mob_NL_short)+  
  
  geom_segment(aes(x = as.Date("2020-12-15"), y = -49.3, xend = as.Date("2021-01-15"), yend = -49.3),linetype = "dashed", color = "#54b251")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -22.1, xend = as.Date("2021-01-15"), yend = -22.1),linetype = "dashed", color = "#fe8003")+
 # geom_segment(aes(x = as.Date("2020-12-15"), y = -12, xend = as.Date(Yesterday), yend = -12),linetype = "dashed", color = "#10be45")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -65.3, xend = as.Date("2021-01-15"), yend = -65.3),linetype = "dashed", color = "#3c81b9")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -48.6, xend = as.Date("2021-01-15"), yend = -48.6),linetype = "dashed", color = "#e5292b")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = 17.4, xend = as.Date("2021-01-15"), yend = 17.4),linetype = "dashed", color = "#9951a4")+
  
  geom_line(aes(x=Datum, y = MA_retail_recreatie,    color = "Retail & recreatie"), lwd=2) +
  geom_line(aes(x=Datum, y = MA_supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=2) +
  geom_line(aes(x=Datum, y = MA_werk,                color = "Werk"), lwd=2) +
  geom_line(aes(x=Datum, y = MA_thuis,               color = "Thuis"), lwd=2)+
  geom_line(aes(x=Datum, y = MA_openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=2) +

#  geom_line(aes(x=Datum, y = retail_recreatie,    color = "Retail & recreatie"), lwd=1) +
#  geom_line(aes(x=Datum, y = supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=1) +
#  geom_line(aes(x=Datum, y = werk,                color = "Werk"), lwd=1) +
#  geom_line(aes(x=Datum, y = thuis,               color = "Thuis"), lwd=1)+
#  geom_line(aes(x=Datum, y = openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=1) +
  
  
  #### add R  ###
 # geom_line(data=last.date.old.wide.3, aes(x=Date,y = Rt_low), lwd=0.6) +
 # geom_line(data=last.date.old.wide.3, aes(x=Date,y = Rt_up), lwd=0.6) +
#geom_ribbon(data=last.date.old.wide.3, aes(x=Date,ymin=Rt_low,ymax=Rt_up), fill="darkred", alpha = 0.2) +
#  geom_line(data=last.date.old.wide.3, aes(x=Date,y = Rt_avg, color = "Effectieve R"), color = "black",lwd=2) +
  
# geom_line(data = last.date.old.wide.mob, aes(x = Date, y = Rt_avg10, color = "Effectieve R"), color = "black",lwd=2) +
  
  
theme_classic()+
  xlab("")+ 
  ylab("")+

#  scale_colour_brewer(palette = "Set1")+
  
  
  #fe8003
  
  #54b251
  #9951a4
  
  
  scale_color_manual(values = c("#3c81b9", "#54b251", "#fe8003", "#9951a4", "#e5292b"))+
  
  
  labs(title = "Google Mobility - Nederland",
      subtitle = paste("7-daags zwevend gemiddele | Actueel tot:", Last_date_in_Google_file), #, "\n - semi-lockdown op 14 oktober\n - einde herfstvakantie op 25 oktober \n- verzwaring semi-lockdown"),
      caption = paste("Source: Google LLC 'Google COVID-19 Community Mobility Reports',   https://www.google.com/covid19/mobility/,  Accessed:",Sys.Date(), "    | Plot: @YorickB | ",Sys.Date()))+
  
  theme(legend.position = c(0.3,0.15),
        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
        legend.title = element_blank(),
        legend.margin = margin(3, 3, 3, 3),
        legend.text = element_text(colour="black", size=20, face="bold"))+
  
  theme( plot.background = element_rect(fill = "#F5F5F5"), #background color/size (border color and size)
         panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
         #legend.position = "none",   # no legend
         plot.title = element_text(hjust = 0.5,size = 30,face = "bold"),
         plot.subtitle =  element_text(hjust=0.5 ,size = 15,color = "black", face = "italic"),
         
         axis.text = element_text(size=14,color = "black",face = "bold"),
         axis.text.y = element_text(face="bold", color="black", size=12),  #, angle=45),
         axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
         axis.ticks.length = unit(0.5, "cm"),
         axis.line = element_line(colour = "#F5F5F5"),
         
         panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"),
         ### facet label custom
         strip.text.x = element_text(size = 13, color = "black"),
         strip.background = element_rect(color="black", fill="gray", size=1.5, linetype="solid"))+
  
  geom_hline(yintercept=0) +
  geom_vline(xintercept = as.Date("2020-09-18"), linetype = "dotted") + 
  geom_vline(xintercept = as.Date("2020-09-28"), linetype = "dotted") + 
#  geom_vline(xintercept = as.Date("2020-11-04"), linetype = "dotted") +
 
  geom_vline(data=persco.df, mapping=aes(xintercept=date), color="black", linetype = "dotted") +
  geom_text(data=persco.df, mapping=aes(x=date, y=-98, label=event), size=4, angle=90, vjust=-0.4, hjust=0)
  
  # geom_vline(xintercept = as.Date("2020-10-10"), linetype = "dashed") +
  # geom_vline(xintercept = as.Date("2020-10-17"), linetype = "dashed") +
   #geom_vline(xintercept = as.Date("2020-10-25"), linetype = "dashed") 


ggsave("data/36_Google_data_NL.png",width=16, height = 9)






ggplot(Google_mob_NL_short)+  
  geom_segment(aes(x = as.Date("2020-12-15"), y = -49.3, xend = as.Date("2021-01-15"), yend = -49.3),linetype = "dashed", color = "#54b251")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -22.1, xend = as.Date("2021-01-15"), yend = -22.1),linetype = "dashed", color = "#fe8003")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -65.3, xend = as.Date("2021-01-15"), yend = -65.3),linetype = "dashed", color = "#3c81b9")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = -48.6, xend = as.Date("2021-01-15"), yend = -48.6),linetype = "dashed", color = "#e5292b")+
  geom_segment(aes(x = as.Date("2020-12-15"), y = 17.4, xend = as.Date("2021-01-15"), yend = 17.4),linetype = "dashed", color = "#9951a4")+
  
  geom_line(aes(x=Datum, y = MA_retail_recreatie,    color = "Retail & recreatie"), lwd=2, alpha=0.25) +
  geom_line(aes(x=Datum, y = MA_supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=2, alpha=0.25) +
  geom_line(aes(x=Datum, y = MA_werk,                color = "Werk"), lwd=2, alpha=0.75) +
  geom_line(aes(x=Datum, y = MA_thuis,               color = "Thuis"), lwd=2, alpha=0.75)+
  geom_line(aes(x=Datum, y = MA_openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=2, alpha=0.75) +
  
  geom_point(aes(x=Datum, y = retail_recreatie,    color = "Retail & recreatie"), lwd=1.5, alpha=0.25) +
  geom_point(aes(x=Datum, y = supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=1.5, alpha=0.25) +
  geom_point(aes(x=Datum, y = werk,                color = "Werk"), lwd=1.5) +
  geom_point(aes(x=Datum, y = thuis,               color = "Thuis"), lwd=1.5)+
  geom_point(aes(x=Datum, y = openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=1.5) +
  
  #  geom_line(aes(x=Datum, y = retail_recreatie,    color = "Retail & recreatie"), lwd=1, alpha=0.25) +
  #  geom_line(aes(x=Datum, y = supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=1, alpha=0.25) +
  #  geom_line(aes(x=Datum, y = werk,                color = "Werk"), lwd=1, alpha=0.25) +
  #  geom_line(aes(x=Datum, y = thuis,               color = "Thuis"), lwd=1, alpha=0.25)+
  #  geom_line(aes(x=Datum, y = openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=1, alpha=0.25) +
  
  
  theme_classic()+
  xlab("")+ 
  ylab("")+
  scale_color_manual(values = c("#3c81b9", "#54b251", "#fe8003", "#9951a4", "#e5292b"))+
  labs(title = "Google Mobility - Nederland",
       subtitle = paste("7-daags zwevend gemiddele | Actueel tot:", Last_date_in_Google_file), #, "\n - semi-lockdown op 14 oktober\n - einde herfstvakantie op 25 oktober \n- verzwaring semi-lockdown"),
       caption = paste("Source: Google LLC 'Google COVID-19 Community Mobility Reports',   https://www.google.com/covid19/mobility/,  Accessed:",Sys.Date(), "    | Plot: @YorickB | ",Sys.Date()))+
  theme(legend.position = c(0.30,0.15),
        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
        legend.title = element_blank(),
        legend.margin = margin(3, 3, 3, 3),
        legend.text = element_text(colour="black", size=20, face="bold"))+
  
  theme( plot.background = element_rect(fill = "#F5F5F5"),
         panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
         plot.title = element_text(hjust = 0.5,size = 30,face = "bold"),
         plot.subtitle =  element_text(hjust=0.5 ,size = 15,color = "black", face = "italic"),
         axis.text = element_text(size=14,color = "black",face = "bold"),
         axis.text.y = element_text(face="bold", color="black", size=12),
         axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
         axis.ticks.length = unit(0.5, "cm"),
         axis.line = element_line(colour = "#F5F5F5"),
         panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"),
         strip.text.x = element_text(size = 13, color = "black"),
         strip.background = element_rect(color="black", fill="gray", size=1.5, linetype="solid"))+
  geom_hline(yintercept=0) +
  geom_vline(xintercept = as.Date("2020-09-18"), linetype = "dotted") + 
  geom_vline(xintercept = as.Date("2020-09-28"), linetype = "dotted") + 
  geom_vline(data=persco.df, mapping=aes(xintercept=date), color="black", linetype = "dotted") +
  geom_text(data=persco.df, mapping=aes(x=date, y=-98, label=event), size=4, angle=90, vjust=-0.4, hjust=0)+
  ggsave("data/36_Google_data_NL_dots.png",width=16, height = 9)


#### Google NL tweet ####


lastGoogle_NL <- tail(Google_mob_NL_short,n=10)


perc_G_NL_OV   <- as.integer(lastGoogle_NL$MA_openbaar_vervoer [7])
perc_G_NL_Werk <- as.integer(lastGoogle_NL$MA_werk[7])
perc_G_NL_Winkel  <- as.integer(lastGoogle_NL$MA_retail_recreatie[7])
perc_G_NL_super <- as.integer(lastGoogle_NL$MA_supermarkt_apotheek[7])
perc_G_NL_thuis  <- as.integer(lastGoogle_NL$MA_thuis[7])

perc_G_NL_OV_week   <- perc_G_NL_OV   - as.integer(lastGoogle_NL$MA_openbaar_vervoer[1])
perc_G_NL_Werk_week <- perc_G_NL_Werk - as.integer(lastGoogle_NL$MA_werk[1])
perc_G_NL_Winkel_week  <- perc_G_NL_Winkel  - as.integer(lastGoogle_NL$MA_retail_recreatie[1])
perc_G_NL_super_week <- perc_G_NL_super - as.integer(lastGoogle_NL$MA_supermarkt_apotheek[1])
perc_G_NL_thuis_week  <- perc_G_NL_thuis  - as.integer(lastGoogle_NL$MA_thuis[1])



emoji_OV   <- intToUtf8(0x1F682)
emoji_werk <- intToUtf8(0x1F3E2)
emoji_winkel  <- intToUtf8(0x1F3EC)
emoji_super    <- intToUtf8(0x1F3EA)
emoji_home    <- intToUtf8(0x1F3E0)


deP <- intToUtf8(0x0025)


tweet.GoogleM.NL.tweet <- "Google mobility data:

Laatste datapunt: 
%s

Verandering mobiliteit tov 3/1-6/2, 2020.(%s):
(verandering t.o.v. een week geleden)

%s    %s%s  (%s%s) - Thuis
%s   %s%s  (%s%s) - Supermarkt
%s   %s%s  (%s%s) - Retail & recreatie
%s   %s%s  (%s%s) - Werk
%s   %s%s  (%s%s) - OV"

tweet.GoogleM.NL.tweet <- sprintf(tweet.GoogleM.NL.tweet, 
                                  Last_date_in_Google_file, deP,
                              emoji_home,  perc_G_NL_thuis,  deP,  perc_G_NL_thuis_week,  deP,
                              emoji_super, perc_G_NL_super, deP,  perc_G_NL_super_week, deP,
                              emoji_winkel,   perc_G_NL_Winkel,   deP,  perc_G_NL_Winkel_week,   deP,
                              emoji_werk, perc_G_NL_Werk, deP,  perc_G_NL_Werk_week, deP,
                              emoji_OV,   perc_G_NL_OV,   deP, perc_G_NL_OV_week,   deP
                              )

Encoding(tweet.GoogleM.NL.tweet) <- "UTF-8"


 post_tweet(tweet.GoogleM.NL.tweet,  media = c("data/36_Google_data_NL.png"))
## post_tweet(tweet.GoogleM.NL.tweet,  media = c("data/36_Google_data_NL.png"), in_reply_to_status_id = get_reply_id())


 
#### Goolge mobility provinces #####
 
 
#Google_mob_prov <- google_mob_raw[which(google_mob_raw$sub_region_1 != "" & google_mob_raw$sub_region_2 ==""),]

#Google_mob_prov_short <- Google_mob_prov[ -c(1,2,4,5,6,7)]

#colnames(Google_mob_prov_short) <- c("Provincie", "Datum","retail_recreatie","supermarkt_apotheek","parken","openbaar_vervoer", "werk", "thuis")

#Google_mob_prov_short$Datum <- as.Date(Google_mob_prov_short$Datum)

#Google_mob_prov_short$Provincie <- str_replace_all(Google_mob_prov_short$Provincie, c("North Brabant" = "Noord-Brabant",
#                                                                                      "North Holland"= "Noord-Holland",
#                                                                                      "South Holland" = "Zuid-Holland"))

#Google_mob_prov_short$Provincie <- factor(Google_mob_prov_short$Provincie,  levels = c("Drenthe",
#                                                                                       "Flevoland",
#                                                                                       "Friesland",
#                                                                                       "Gelderland",
#                                                                                       "Groningen",
#                                                                                       "Limburg",
#                                                                                       "Noord-Brabant",
#                                                                                       "Noord-Holland",
#                                                                                       "Overijssel",
#                                                                                       "Utrecht",
#                                                                                       "Zeeland",
#                                                                                       "Zuid-Holland"
#                                                                                       ))

##### 7day MA #####


#Google_mob_prov_short$MA_retail_recreatie     <- round(rollmeanr(Google_mob_prov_short$retail_recreatie,  7, fill = NA),digits = 1)
#Google_mob_prov_short$MA_supermarkt_apotheek  <- round(rollmeanr(Google_mob_prov_short$supermarkt_apotheek,    7, fill = NA),digits = 1)
#Google_mob_prov_short$MA_parken               <- round(rollmeanr(Google_mob_prov_short$parken, 7, fill = NA),digits = 1)
#Google_mob_prov_short$MA_openbaar_vervoer     <- round(rollmeanr(Google_mob_prov_short$openbaar_vervoer,  7, fill = NA),digits = 1)
#Google_mob_prov_short$MA_werk                 <- round(rollmeanr(Google_mob_prov_short$werk,    7, fill = NA),digits = 1)
#Google_mob_prov_short$MA_thuis                <- round(rollmeanr(Google_mob_prov_short$thuis, 7, fill = NA),digits = 1)



##### Datum substten #####


#Google_mob_prov_short <- (Google_mob_prov_short %>% filter(Datum > "2020-09-29"))



##### plot pvovinces Google mobility ####
#library(wesanderson)




#ggplot(Google_mob_prov_short) + 
 
#  geom_vline(xintercept = as.Date("2020-10-10"), linetype = "dotted", color = "darkgreen",size = 1.5) +
#  geom_vline(xintercept = as.Date("2020-10-18"), linetype = "dotted", color = "darkgreen",size = 1.5) +
#  geom_vline(xintercept = as.Date("2020-10-17"), linetype = "dotted", size = 1.5) +
#  geom_vline(xintercept = as.Date("2020-10-25"), linetype = "dotted", size = 1.5)+
##  
#  geom_vline(xintercept = as.Date("2020-10-14"), linetype = "dashed", color = "violet", size = 1.5)+
#  
#  
#   geom_line(aes(x=Datum, y = MA_openbaar_vervoer,    color = "Openbaar Vervoer"), lwd=2) +
#    geom_line(aes(x=Datum, y = MA_retail_recreatie,    color = "Retail & recreatie"), lwd=2) +
 # geom_line(aes(x=Datum, y = MA_supermarkt_apotheek, color = "Supermarkt & Apotheek"), lwd=2) +
#  geom_line(aes(x=Datum, y = MA_werk,                color = "Werk"), color = "#F5F5F5", lwd=3) +
#  geom_line(aes(x=Datum, y = MA_werk,                color = "Werk"), lwd=2) +
 # geom_line(aes(x=Datum, y = MA_thuis,               color = "Thuis"), lwd=2)+

  

  
 #  geom_vline(xintercept = as.Date("2020-10-14"), linetype = "dotted") +
 #  geom_vline(xintercept = as.Date("2020-10-10"), linetype = "dashed") +
 #  geom_vline(xintercept = as.Date("2020-10-17"), linetype = "dashed") +
 #  geom_vline(xintercept = as.Date("2020-10-25"), linetype = "dashed") +
  
#  facet_wrap(~Provincie)+

  #scale_colour_brewer(palette = "Set1")+
#   scale_color_manual(values=c("#204ad4", "#008f91", "#cc2929"))+  #"#008f91", "#204ad4", "#cc2929"
 # scale_color_manual(values=wes_palette(n=3, name="Rushmore1"))+
  
  
#  theme_bw() + 
#  xlab("")+ 
#  ylab("")+
  
#  labs(title = "Google Mobility - Nederland",
#       subtitle = paste("7-daags zwevend gemiddele | Actueel tot:", 
#                        Last_date_in_Google_file,
#                        "\n\n - Herfstvakantie Noord: 10-18 oktober \n",
#                        "- semi-lockdown op 14 oktober\n",
#                        "- Herfstvakantie midden/zuid: 17-25 oktober"
#                        ),
#       caption = paste("Source: Google LLC 'Google COVID-19 Community Mobility Reports',   https://www.google.com/covid19/mobility/,  Accessed:",
#                       Sys.Date(), "    | Plot: @YorickB | ",Sys.Date()))+
  
  
#  theme(
#        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
#        legend.title = element_blank(),
#        legend.pos = "bottom",
#        legend.direction = "horizontal",
        #legend.margin = margin(3, 3, 3, 3),
#        legend.text = element_text(colour="black", size=12, face="bold"),
#        legend.key = element_rect(fill = "#F5F5F5", color = NA),
        #legend.position = c(0.7,0.15),
#        )+
  
 # theme( plot.background = element_rect(fill = "#F5F5F5"), #background color/size (border color and size)
#         panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
         #legend.position = "none",   # no legend
#         plot.title = element_text(hjust = 0.4,size = 30,face = "bold"),
#         plot.subtitle =  element_text(hjust=0.5 ,size = 15,color = "black", face = "italic"),
         
#         axis.text = element_text(size=14,color = "black",face = "bold"),
#         axis.text.y = element_text(face="bold", color="black", size=12),  #, angle=45),
#         axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
#         axis.ticks.length = unit(0.5, "cm"),
         #axis.line = element_line(colour = "#F5F5F5"),
         
#         panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"),
         ### facet label custom
#         strip.text.x = element_text(size = 13, color = "black"),
#         strip.background = element_rect(color="black", fill="gray", size=1.5, linetype="solid"),
#         panel.grid.major.x = element_blank(),
#         panel.grid.minor.x = element_blank(),
#         panel.grid.minor.y = element_blank())
  
  #geom_hline(yintercept=0) +
  #geom_vline(xintercept = as.Date("2020-09-18"), linetype = "dotted") + 
  # geom_vline(xintercept = as.Date("2020-09-28"), linetype = "dotted") + 
 


#ggsave("data/37_Google_data_prov.png",width=16, height = 12)



##### Google province tweet ####


#tweet.GoogleM.prov.tweet <- "Google mobility data.

#Verandering in mobiliteit t.o.v. 2019 (%s)

#De provincies:"

#tweet.GoogleM.prov.tweet <- sprintf(tweet.GoogleM.prov.tweet,
#                                    deP
#                                    )

#Encoding(tweet.GoogleM.prov.tweet) <- "UTF-8"



#post_tweet(tweet.GoogleM.prov.tweet,  media = c("data/37_Google_data_prov.png"), in_reply_to_status_id = get_reply_id())  #













##### Google raw tweet ####
tweet.GoogleM.raw.tweet <- "Google mobility data.

raw data dots"

tweet.GoogleM.raw.tweet <- sprintf(tweet.GoogleM.raw.tweet)
Encoding(tweet.GoogleM.raw.tweet) <- "UTF-8"
post_tweet(tweet.GoogleM.raw.tweet,  media = c("data/36_Google_data_NL_dots.png"), in_reply_to_status_id = get_reply_id())  #


 