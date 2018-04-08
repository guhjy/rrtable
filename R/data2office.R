#' convert data to pptx file
#' @param data A document object
#' @param preprocessing A string
#' @param filename File name
#' @param format desired format. choices are "pptx" or "docx"
#' @param width the width of the device.
#' @param height the height of the device.
#' @param units The units in which height and width are given. Can be px (pixels, the default), in (inches), cm or mm.
#' @param res The nominal resolution in ppi which will be recorded in the bitmap file, if a positive integer. Also used for units other than the default, and to convert points to pixels.
#' @param rawDataName raw Data Name
#' @param rawDataFile raw Data File
#' @param vanilla logical. WHether or not make vanilla table
#' @param echo logical Whether or not show R code
#' @importFrom officer read_docx read_pptx
#' @export
data2office=function(data,
                     preprocessing="",
                     filename="Report",format="pptx",width=7,height=5,units="in",
                     res=300,rawDataName=NULL,rawDataFile="rawData.RDS",vanilla=FALSE,echo=FALSE){

    if(!is.null(rawDataName)){
        rawData=readRDS(rawDataFile)
        assign(rawDataName,rawData)
    }
    if(preprocessing!="") eval(parse(text=preprocessing))

    data$type=tolower(data$type)

    if(ncol(data)==3) {
        shortdata=1
    } else {
        shortdata=0
    }

    if("title" %in% data$type) {
        if(shortdata) {
            mytitle=data[data$type=="title",]$code[1]
        } else{
            mytitle=data[data$type=="title",]$text[1]
        }
        data=data[data$type!="title",]
    } else{
        mytitle="Web-based Analysis with R"
    }
    mysubtitle=""
    if("subtitle" %in% data$type) {
        if(shortdata) {
            mysubtitle=data[data$type=="subtitle",]$code[1]
        } else{
            mysubtitle=data[data$type=="subtitle",]$text[1]
        }
        data=data[data$type!="subtitle",]
    }
    if("author" %in% data$type) {
        myauthor=data[data$type=="author",]$code[1]
        data=data[data$type!="author",]
    } else{
        myauthor="prepared by web-r.org"
    }

    if(format=="pptx"){
        mydoc <- read_pptx() %>%
            add_title_slide(title=mytitle,subtitle=ifelse(shortdata,myauthor,mysubtitle))
    } else {
        mydoc <- read_docx()
    }
    #str(data)
    for(i in 1:nrow(data)){
        #cat("data$code[",i,"]=",data$code[i],"\n")

        # if(mypptlist$type[i] == "header2"){
        #     mycat("##",mypptlist$title[i],"\n\n")
        # } else if(mypptlist$type[i] == "header3"){
        #     mycat("###",mypptlist$title[i],"\n\n")
        # } else {
        #     if(mypptlist$title[i]!="") mycat("###",mypptlist$title[i],"\n\n")
        # }

        if(shortdata==0){
            if(data$text[i]!="") mydoc=add_text(mydoc,title=data$title[i],text=data$text[i])
        }

        if(data$type[i]=="Rcode") eval(parse(text=data$code[i]))
        if(data$type[i]=="data"){
            ft=df2flextable(eval(parse(text=data$code[i])),vanilla=vanilla)
            mydoc=add_flextable(mydoc,ft,data$title[i],data$code[i],echo=echo)
        } else if(data$type[i]=="table"){
            tempcode=set_argument(data$code[i],argument="vanilla",value=vanilla)
            ft=eval(parse(text=tempcode))
            mydoc=add_flextable(mydoc,ft,data$title[i],data$code[i],echo=echo)
        } else if(data$type[i]=="mytable"){
            res=eval(parse(text=data$code[i]))
            ft=mytable2flextable(res,vanilla=vanilla)
            mydoc=add_flextable(mydoc,ft,data$title[i],data$code[i],echo=echo)
        } else if(data$type[i]=="ggplot"){
            mydoc=add_ggplot(mydoc,title=data$title[i],code=data$code[i],echo=echo)
        }else if(data$type[i]=="2ggplots"){

            codes=unlist(strsplit(data$code[i],"\n"))
            # codes=unlist(strsplit(sampleData2$code[8],"\n"))
            gg1=codes[1]
            gg2=codes[2]
            mydoc=add_2ggplots(mydoc,title=data$title[i],plot1=gg1,plot2=gg2,
                               echo=echo)
        } else if(data$type[i]=="plot"){
            mydoc<-add_plot(mydoc,data$code[i],title=data$title[i],echo=echo)

        } else if(data$type[i]=="2plots"){

            codes=unlist(strsplit(data$code[i],"\n"))
            mydoc=add_2plots(mydoc,plotstring1=codes[1],plotstring2=codes[2],title=data$title[i],echo=echo)

        } else if(data$type[i]=="rcode"){

            mydoc=add_Rcode(mydoc,code=data$code[i],title=data$title[i],
                            preprocessing=preprocessing,format=format)

        } else if(data$type[i]=="text"){

            mydoc=add_text(mydoc,title=data$title[i],text=data$code[i])

        } else if(data$type[i] %in% c("PNG","png")){

            mydoc<-add_img(mydoc,data$code[i],title=data$title[i],format="png",echo=echo)

        } else if(data$type[i] %in% c("emf","EMF")){

            mydoc<-add_img(mydoc,data$code[i],title=data$title[i],echo=echo)

        } else if(str_detect(data$code[i],"df2flextable")){

            tempcode=data$code[i]
            ft=eval(parse(text=tempcode))
            mydoc=add_flextable(mydoc,ft,data$title[i],data$code[i],echo=echo)

        }


    }
    if(length(grep(".",filename,fixed=TRUE))>0) {
        target=filename
    } else{
        target=paste0(filename,".",format)
    }
    #cat("target=",target,"\n")
    mydoc %>% print(target=target)
}

#' convert data to pptx file
#' @param ... arguments to be passed to data2office()
#' @export
#' @examples
#' #library(rrtable)
#' #data2pptx(sampleData2)
data2pptx=function(...){
    data2office(...)
}

#' convert data to docx file
#' @param ... arguments to be passed to data2office()
#' @export
#' @examples
#' #library(rrtable)
#' #data2docx(sampleData2)
data2docx=function(...){
    data2office(...,format="docx")
}


#' Convert html5 code to latex
#' @param df A data.frame
html2latex=function(df){
    temp=colnames(df)
    temp=stringr::str_replace(temp,"<i>p</i>","\\\\textit{p}")
    temp=stringr::str_replace(temp,"&#946;","$\\\\beta$")
    temp=stringr::str_replace(temp,"Beta","$\\\\beta$")
    temp=stringr::str_replace(temp,"&#967;<sup>2</sup>","$\\\\chi^{2}$")
    colnames(df)=temp
    df
}



#
# data=rrtable::sampleData2
# data[2,3]="df2flextable(iris[1:10,])"
# data<-rbind(data,data[3,])
# data<-rbind(data,data[3,])
# data$type[6]="png"
# data$type[7]="emf"
# data
# library(magrittr)
# library(officer)
# library(flextable)
# library(moonBook)
# library(rvg)
# library(ggplot2)
#
# data2pptx(data[5:7,])
# data[6,]
# data2pptx(data)
# data1=data[3,]
# data1
# data=data1
# filename="Report.pptx"
# data2office(data)
# data2office(data,format="docx")
# data2pptx(data)
# data2docx(data)
# # data=data[3,]
# # data
#
# str(data)
#
# mydoc=read_pptx()
#
# for(i in 1:nrow(data)){
#      eval(parse(text=data$code[i]))
# mydoc=add_plot(mydoc,data$code[i],title=data$title[i])
# }
# mydoc %>% print(target="plot.pptx")
#
#
# require(editData)
# result=editData(sampleData2)
# result
# sampleData2=result
# devtools::use_data(sampleData2,overwrite=TRUE)
# sampleData2


#'grep string in all files in subdirectory
#'@param x string
#'@export
mygrep=function(x,file="*"){

    x=substitute(x)
    temp=paste0("grep -r '",x,"' ",file)
    system(temp)
}

# data2docx(sampleData3,echo=TRUE)