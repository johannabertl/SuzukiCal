library(calendar)
library(lubridate)
library(dplyr)
library(tidyr)
library(stringr)
library(pdftools)

# Test ics #####################################################################

s <- ymd_hm("2024-02-02 16:30")
e <- s + minutes(50)

test_event <- ic_event(start_time = s, end_time = e, summary = "Faellestime", 
         more_properties = TRUE, event_properties = list(LOCATION = "lok. 306"))
ic_write(test_event, file = "~/test_event.ics")

test_event2 <- ic_event(start_time = s, end_time = e, summary = "Faellestime2", 
                       more_properties = TRUE, event_properties = list(LOCATION = "lok. 306"))

event_df <- rbind(test_event, test_event2)
ic_write(event_df, file = "~/test_2_events.ics")


# Read data from pdf ###########################################################

text <- pdftools::pdf_text("~/Documents/Org/Musikschule/Fællestimer ÅM 2026 forår.pdf")[2]


tab_text <- stringr::str_extract(text, pattern = "(?s)(?<=124\\n).*?(?=B\\= Bodil)")

# Entferne unnøtige infos
tab_text <- str_replace_all(tab_text, pattern = "((\\*)+)|#", replacement = "")
tab_lin <- str_split_1(tab_text, pattern = "\\n")

# ohne komische Linien
tab_lin <- tab_lin[-c(5,6,13,14, 18)]
# ohne start leerzeichen
tab_lin <- str_trim(tab_lin, side = "left")

# split: entweder mehrere lehrzeichen oder eine klammer, auf die ein Leerzeichen folgt
# oder ein datum gefolgt von einem leerzeichen
tab_mat <- str_split_fixed(tab_lin, pattern = "\\s{2,}|(?<=\\))\\s|(?<=[[:digit:]])\\s", n = 7)

# dataframe
dat = as.data.frame(tab_mat[-1,])

# richtige namen (lokal fehlt)
lok = rep(c(306, 304, 124), each = 2)
lok_tid = mapply(paste, lok, tab_mat[1,-1], sep="-")
names(dat) = c("date", lok_tid)

# long format
dat_long = pivot_longer(dat, cols = matches("^[0-9]{3}", perl = TRUE))

### tilføjer mærkelige linje ###
dat_long = rbind(dat_long, data.frame(date = c("6/1", "24/4"), name = c("306-18.40", "306-18.30"), value = c("n, o (6/1-J)", "n, o (6/3-J)")))
################################

# fix data
dat_long = dat_long %>% 
  mutate(dato = paste0(date, "/2026")) %>%
  mutate(tid = substr(name, 5, 9)) %>% 
  mutate(lok = substr(name, 1, 3))


dat_long <- dat_long %>%
  mutate(start = dmy_hm(paste(dato, tid))) %>% 
  mutate(slut = start + minutes(50))

dat_long <- dat_long %>% 
  mutate(laerer = str_extract(string = value, pattern = "[:upper:]")) %>% 
  mutate(laerer = case_when(laerer == "B" ~ "Bodil", 
                            laerer == "S" ~ "Søren", 
                            laerer == "J" ~ "Jan", 
                            laerer == "I" ~ "Ina", 
                            laerer == "P" ~ "Peter", 
                            laerer == "T" ~ "Tine"))

dat_long <- dat_long %>% 
  mutate(stykke = str_extract(string = value, pattern = "(?<=\\()[:digit:]+/[:digit:]+")) %>% 
  mutate(stykke = ifelse(is.na(stykke), "", stykke))

# dat_long <- dat_long %>% 
#   mutate(Emil = grepl("[f]", value)) %>% 
#   mutate(Linus = grepl("[b]", value)) %>% 
#   mutate(barn = paste0(ifelse(Emil, "Emil", ""), ifelse(Emil & Linus, " & ", ""), ifelse(Linus, "Linus", "")))
# 
# dat_filter <- dat_long %>%
#   filter(Emil | Linus)

dat_long <- dat_long %>%
  mutate(Aron = grepl("[n]", value)) %>%
  mutate(Elias = grepl("[h]", value)) %>%
  mutate(Abigel = grepl("[b]", value)) %>%
  mutate(barn = paste0(ifelse(Aron, "Áron", ""), ifelse(Elias, "Éliás", ""), ifelse(Abigel, "Abigél", "")))

dat_filter <- dat_long %>%
  filter(Aron | Elias | Abigel)

# ICS

event_list <- vector("list", length = nrow(dat_filter))
for(i in 1:nrow(dat_filter)){
  event_list[[i]] <- ic_event(start_time = dat_filter$start[i], end_time = dat_filter$slut[i], 
                              summary = paste("Faellestime", dat_filter$barn[i], dat_filter$laerer[i], dat_filter$stykke[i]), 
                              more_properties = TRUE, 
                              event_properties = list(LOCATION = paste("lok.", dat_filter$lok[i])))
}


event_df <- bind_rows(event_list)
ic_write(event_df, file = "~/Documents/R/Faellestime/ss2026_lili.ics")
