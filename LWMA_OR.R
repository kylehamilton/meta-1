## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)
library(metafor)
library(DT)
library(knitr)
library(RCurl)
library(dplyr)
library(rmarkdown)
library(kableExtra)

output<-default_output_format(knitr::current_input()) ## This will fail if run manually. Don't worry!

## These lines of code download and run the metafor_tidiers functions that implement broom type tidy data functions for rma objects
source("metafor_tidiers.R")

# Set so that long lines in R will be wrapped:
opts_chunk$set(tidy.opts=list(width.cutoff=80),tidy=TRUE)


## ----read_data-----------------------------------------------------------
## Note this example uses a built in dataset from metafor. Otherwise the syntax would be as for the other templates in this series
## dat<-read.csv("data.csv")

dat<-dat.bcg


## ----calculate_ES--------------------------------------------------------
if(!"vi" %in% colnames(dat))
{
  dat_ES <- dat <- escalc(measure="OR", ai=tpos, bi=tneg, ci=cpos, di=cneg, data=dat)
} else {
  dat_ES<-dat
  attrs<-NULL
  attrs$measure<-"OR"
  attrs$ni<-dat$Intervention.N+dat$Control.N
  attributes(dat_ES$yi) <- attrs
}


## ----dat_es_html, eval=(output$name=="html_document"), echo=FALSE, warning=FALSE----
datatable(dat_ES %>% select(-one_of(c("X", "Timestamp"))), rownames= FALSE)  %>% formatRound('yi', 3) %>% formatRound('vi', 3)

## ----dat_es_pdf,eval=(output$name=="pdf_document"), echo=FALSE, warning=FALSE----
kable(dat_ES %>% select(-one_of(c("X", "Timestamp"))), booktabs = T, format = "latex") %>%
kable_styling(latex_options = c("striped", "scale_down"))


## ----dat_es_word,eval=(output$name=="word_document"), echo=FALSE, warning=FALSE----
kable(dat_ES %>% select(-one_of(c("X", "Timestamp"))))

## ----run_MA--------------------------------------------------------------
dat_MA<- rma(yi, vi, data=dat_ES, slab=paste(author, year))
model<-tidy.rma(dat_MA)
het.small<-glance.rma(dat_MA) %>% select(one_of(c("k", "tau2", "se.tau2", "QE", "QEp", "I2")))
eggers<-regtest(dat_MA)

## ----forest, warning=FALSE, fig.height=(het.small$k*0.5)-----------------
forest(dat_MA)

## ----funnel--------------------------------------------------------------
funnel(dat_MA, back="white")


## ----include=FALSE-------------------------------------------------------
citPkgs <- names(sessionInfo()$otherPkgs)
write_bib(citPkgs, file="R-Pckgs.bib")

