library(tidyverse)

require(zoo)
require(data.table)

##############  How to plot factors in a specified order in ggplot

############################  https://rstudio-pubs-static.s3.amazonaws.com/7433_4537ea5073dc4162950abb715f513469.html



read.aantal.landelijk.path <- paste("C:\\Rdir\\data\\",Sys.Date()-1,"\\", Sys.Date()-1, "_COVID-19_casus_landelijk.csv",sep="")
cases_per_yesterday <- read.csv(read.aantal.landelijk.path,sep=";")

read.aantal.landelijk.path <- paste("C:\\Rdir\\data\\",Sys.Date(),"\\", Sys.Date(), "_COVID-19_casus_landelijk.csv",sep="")
cases_per_day <- read.csv(read.aantal.landelijk.path,sep=";")

cases_per_yesterday$Date_statistics_type[cases_per_yesterday$Date_statistics_type == "DOO"] <- "DOO_old"
cases_per_yesterday$Date_statistics_type[cases_per_yesterday$Date_statistics_type == "DON"] <- "DON_old"
cases_per_yesterday$Date_statistics_type[cases_per_yesterday$Date_statistics_type == "DPL"] <- "DPL_old"



cases_per_yesterday$value <- 1
cases_per_yesterday_long <- aggregate(cases_per_yesterday$value, by = list(Type_Datum = cases_per_yesterday$Date_statistics_type, Datum = cases_per_yesterday$date, Dag = cases_per_yesterday$Date_file), FUN = sum)
colnames(cases_per_yesterday_long)[4] <- "value"
check <- cases_per_yesterday_long[,c("Datum", "Type_Datum", "value" )]


cases_per_day$value <- 1
cases_per_day_long <- aggregate(cases_per_day$value, by = list(Type_Datum = cases_per_day$Date_statistics_type, Datum = cases_per_day$date, Dag = cases_per_day$Date_file), FUN = sum)
colnames(cases_per_day_long)[4] <- "value"
check2 <- cases_per_day_long[,c("Datum", "Type_Datum", "value" )]


cases_per_day_long_bind <- rbind(check2, check)   # Adding Rows (adding other df, to the bottom)
cases_per_day_long_spread <- spread(cases_per_day_long_bind, Type_Datum, value)
cases_per_day_long_spread_diff <- cases_per_day_long_spread
cases_per_day_long_spread_diff <- as.data.frame(cases_per_day_long_spread_diff)
cases_per_day_long_spread_diff$diff <- 0
cases_per_day_long_spread_diff[is.na(cases_per_day_long_spread_diff)] <- 0

df <- cases_per_day_long_spread_diff
df$DON_diff <- df$DON - df$DON_old
df$DOO_diff <- df$DOO - df$DOO_old
df$DPL_diff <- df$DPL - df$DPL_old

df2 <- df[,c("Datum", "DON_old", "DON_diff","DOO_old","DOO_diff", "DPL_old", "DPL_diff" )]



keycol <- "Datum"
valuecol <- "type"
gathercols <- c("DON_old", "DON_diff","DOO_old","DOO_diff", "DPL_old", "DPL_diff")

#df4 <- gather(df2, keycol, valuecol, gathercols)
#df4$Datum <- as.Date(df4$Datum)

df3 <- gather(df2, keycol, valuecol, gathercols)
df3$Datum <- as.Date(df3$Datum)


df4 <- df3


### press events                         
#dates_vline <- as.Date(c("2020-09-18", "2020-09-28", "2020-10-13", "2020-11-04"))
#dates_vline <- which((df4$Datum %in% dates_vline))

dates_vline <- data.frame(date=as.Date(c("2020-09-18", "2020-09-28", "2020-10-13", "2020-11-05", 
                                         "2020-11-18", "2020-12-15", "2021-01-23", "2021-02-08",  "2021-03-31")),
                          event=c("kroeg uurtje eerder dicht (regio)","R van 0,9 (landelijke maatregelen)","semi-lockdown",
                                  "verzwaring", "einde verzwaring", "lockdown", "                    avondklok",
                                 "basisscholen open", "avondklok 22:00uur"))


df4 <- df4[df4$Datum>"2020-07-01",]



rect5 <- data.frame(xmin = c(as.Date("2020-12-30"), as.Date("2021-01-06")),
                    xmax = c(as.Date("2021-01-02"), as.Date("2021-01-06")),
                    ymin = c(0,0),
                    ymax = c(Inf, Inf),
                    label.bes = c("kerst", "oud/nieuw"))




ggplot(df4, aes(x=Datum, y=valuecol, fill = factor(keycol, levels=c("DOO_diff","DOO_old","DPL_diff","DPL_old","DON_diff","DON_old")), width=.7)) +
 geom_col()+

theme_classic()+
    xlab("")+ 
  ylab("")+

  

  
  scale_x_date(date_breaks = "2 week", 
               date_labels= format("%d-%b"),
               limits = as.Date(c("2020-07-01", Sys.Date() ))
               )+

    scale_fill_manual(values=c("#c55a11", 
                               "#F8CBAD", 
                               "#548235", 
                               "#C5E0B4",  
                               "#203864",   #blauw donker
                               "#B4C7E7"),  #blauw
                      labels=c(   "Melding aan GGD (nieuw/correctie)",
                                  "Melding aan GGD",
                                  "Eerste ziektedag (nieuw/correctie)",
                                  "Eerste ziektedag",
                                  "Positieve labuitslag (nieuw/correctie)",
                                  "Positieve labuitslag"))+
  
  #scale_fill_manual(values=c("#548235", 
  #                           "#C5E0B4", 
  #                           "#203864", 
  #                           "#B4C7E7",
  #                           "#c55a11", 
  #                           "#F8CBAD"), 
  #                  labels=c(   "Eerste ziektedag (nieuw/correctie)",
  #                              "Eerste ziektedag",
  #                              "Positieve labuitslag (nieuw/correctie)",
  #                              "Positieve labuitslag",
  #                              "Melding aan GGD (nieuw/correctie)",
  #                              "Melding aan GGD"))+
  
  # geom_vline(xintercept = as.numeric(df4$Datum[dates_vline]),
   #      col = "darkgray", lwd = 1, linetype= "dashed")+
    # geom_text(mapping=aes(x=date, y=0, label=event), size=4, angle=90, vjust=-0.4, hjust=0) +
  
  geom_vline(data=dates_vline,  mapping=aes(xintercept=date),  col = "darkgray", lwd = 1, linetype= "dashed")+
  geom_text(data=dates_vline  , mapping=aes(x=date, y=2500, label=event), size=8, angle=90, vjust=-0.4, hjust=0)+
  
  scale_y_continuous( labels = label_comma(big.mark = ".", decimal.mark = ","))+
  
labs(title = "Besmette personen: verschil met gisteren",
    # subtitle = "  18-sep, Persco: 'kroeg uurtje eerder dicht'\n  28-sep, Persco: 'we gaan voor een R van 0,9'\n13-okt, Persco: semi-lockdown\n5 t/m 18 nov, verzwaring semi-lockdown", #  OMT: 'Een lagere R is beter'",
     caption = paste("Bron: RIVM | Plot: @YorickB ",Sys.Date()))+
  
   theme(legend.position = c(0.2, 0.8),
        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
        legend.title = element_blank(),
        legend.text = element_text(colour="black", size=10, face="bold"))+
  
  theme(
    plot.background = element_rect(fill = "#F5F5F5"), #background color/size (border color and size)
    panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
    plot.title = element_text(hjust = 0.5,size = 30,face = "bold"),
    plot.subtitle =  element_text(hjust=0.5 ,size = 15,color = "black", face = "italic"),
    axis.text.x = element_text(face="bold", color="black", size=12), #, angle=45),
    axis.text.y = element_text(face="bold", color="black", size=14),
    axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
    axis.ticks.length = unit(0.5, "cm"),
    axis.line = element_line(colour = "#F5F5F5"),
    
    #axis.labels.x=date_format("%d-%b"),
    
    panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"))+
#panel.grid.major.x = element_line(colour= "darkgray", linetype = "solid"))

 # geom_rect(data = rect5 , aes(xmin = xmin,xmax = xmax, ymin = ymin,ymax = ymax, fill = label.bes), alpha = 0.5) +


ggsave("data/07_cases_type1.png",width=16, height = 9)  





ggplot(df4, aes(x=Datum, y=valuecol, fill = factor(keycol, levels=c("DOO_diff","DOO_old","DPL_diff","DPL_old","DON_diff","DON_old")), width=.7)) +
  geom_col()+
  
  theme_classic()+
  xlab("")+ 
  ylab("")+
  
  scale_x_date(date_breaks = "14 day", 
               date_labels= format("%d-%b"),
               limits = as.Date(c("2020-07-01", Sys.Date()+5)))+

  scale_fill_manual(values=c("#548235", "#C5E0B4", "#203864", "#B4C7E7","#c55a11", "#F8CBAD"), 
                    labels=c(   "First day with symptoms (new/correction)", 
                                "First day with symptoms",
                                "Positive lab result",
                                "Positive lab result (new/correction)",
                                "Notification to GGD (new/correction)",
                                "Notification to GGD"))+                                                               
  scale_y_continuous( labels = label_comma(big.mark = ".", decimal.mark = ","))+
  
  #geom_vline(xintercept = as.numeric(df4$Datum[dates_vline]),
  #           col = "darkgray", lwd = 1, linetype= "dashed")+
  #geom_text(mapping=aes(x=date, y=0, label=event), size=4, angle=90, vjust=-0.4, hjust=0) +
  geom_vline(data=dates_vline,  mapping=aes(xintercept=date),  col = "darkgray", lwd = 1, linetype= "dashed")+
  
  
  labs(title = "Cases: compared to yesterday",
       subtitle = "18-Sep: Press conference 'bars close an hour early'\n28-Sep: Press conference 'We aim for an R of 0.9'\n13-oct: Press conference semi-lockdown \n 5 - 19 nov heavier semi-lockdown",
       caption = paste("Source: RIVM | Plot: @YorickB | ",Sys.Date()))+
  
  theme(legend.position = c(0.2, 0.8),
        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
        legend.title = element_blank(),
        legend.text = element_text(colour="black", size=10, face="bold"))+
  
  theme(
    plot.background = element_rect(fill = "#F5F5F5"), #background color/size (border color and size)
    panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
    plot.title = element_text(hjust = 0.5,size = 30,face = "bold"),
    plot.subtitle =  element_text(hjust=0.5,size = 18,color = "black", face = "italic"),
    axis.text.x = element_text(face="bold", color="black", size=12), #, angle=45),
    axis.text.y = element_text(face="bold", color="black", size=14),
    axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
    axis.ticks.length = unit(0.5, "cm"),
    axis.line = element_line(colour = "#F5F5F5"),
    
    #axis.labels.x=date_format("%d-%b"),
    
    panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"))+ #,
  #panel.grid.major.x = element_line(colour= "darkgray", linetype = "solid"))
  
  
  
  ggsave("data/07_EN_cases_type1.png",width=16, height = 9)  






##mondays
dates_vline_mondays <- as.Date(c("2020-08-10","2020-08-17","2020-08-24",
                  "2020-08-31",
                  "2020-09-07",
                   "2020-09-14",
                  "2020-09-21",
                  "2020-09-28",
                   "2020-10-05",
                   "2020-10-12",
                  "2020-10-19",
                  "2020-10-26",
                  "2020-11-02",
                  "2020-11-09",
                  "2020-11-16",
                  "2020-11-23",
                  "2020-11-30",
                  "2020-12-07",
                  "2020-12-14",
                  "2020-12-21",
                  "2020-12-28",
                  "2021-01-04",
                  "2021-01-11",
                  "2021-01-18",
                  "2021-01-25",
                  "2021-02-01",
                  "2021-02-08",
                  "2021-02-15",
                  "2021-02-22",
                  "2021-03-01",
                  "2021-03-08",
                  "2021-03-15",
                  "2021-03-22",
                  "2021-03-29",
                  "2021-04-05",
                  "2021-04-12",
                  "2021-04-19"
                  
                 ))   

dates_vline_mondays <- which((df4$Datum %in% dates_vline_mondays))




ggplot(df4, aes(x=Datum, y=valuecol, fill = factor(keycol, levels=c("DOO_diff","DOO_old","DPL_diff","DPL_old","DON_diff","DON_old")), width=.7)) +
  geom_col()+

  theme_classic()+
  xlab("")+ 
  ylab("")+
    scale_x_date(date_breaks = "2 week", 
               date_labels= format("%d-%b"),
               limits = as.Date(c("2020-07-01", Sys.Date() ))
  )+
  
  scale_fill_manual(values=c("#548235", "#C5E0B4", "#203864", "#B4C7E7","#c55a11", "#F8CBAD"), 
                    labels=c(    "Eerste ziektedag (nieuw/correctie)",
                                 "Eerste ziektedag",
                                 "Positieve labuitslag (nieuw/correctie)",
                                "Positieve labuitslag",
                                "Melding aan GGD (nieuw/correctie)",
                                "Melding aan GGD"))+
  
    geom_vline(xintercept = as.numeric(df4$Datum[dates_vline_mondays]),
             col = "darkgray", lwd = 0.5, linetype= "dashed")+
    # geom_text(mapping=aes(x=date, y=0, label=event), size=4, angle=90, vjust=-0.4, hjust=0) +
    labs(title = "Besmette personen: verschil met gisteren",
       subtitle = "Maandagen", #  OMT: 'Een lagere R is beter'",
       caption = paste("Bron: RIVM | Plot: @YorickB ",Sys.Date()))+
  
  theme(legend.position = c(0.2, 0.8),
        legend.background = element_rect(fill="#F5F5F5",size=0.8,linetype="solid",colour ="black"),
        legend.title = element_blank(),
        legend.text = element_text(colour="black", size=10, face="bold"))+
  theme(
    plot.background = element_rect(fill = "#F5F5F5"), #background color/size (border color and size)
    panel.background = element_rect(fill = "#F5F5F5", colour = "#F5F5F5"),
    plot.title = element_text(hjust = 0.5,size = 30,face = "bold"),
    plot.subtitle =  element_text(hjust=0.5 ,size = 15,color = "black", face = "italic"),
    axis.text.x = element_text(face="bold", color="black", size=12), #, angle=45),
    axis.text.y = element_text(face="bold", color="black", size=14),
    axis.ticks = element_line(colour = "#F5F5F5", size = 1, linetype = "solid"),
    axis.ticks.length = unit(0.5, "cm"),
    axis.line = element_line(colour = "#F5F5F5"),
        #axis.labels.x=date_format("%d-%b"),
        panel.grid.major.y = element_line(colour= "lightgray", linetype = "dashed"))+ #,
  #panel.grid.major.x = element_line(colour= "darkgray", linetype = "solid"))
    ggsave("data/plots/07_cases_type1-monday.png",width=16, height = 9)










