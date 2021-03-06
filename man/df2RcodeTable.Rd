% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_Rcode.R
\name{df2RcodeTable}
\alias{df2RcodeTable}
\title{Make a flextable with a data.frame}
\usage{
df2RcodeTable(df, bordercolor = "gray", format = "pptx", eval = TRUE)
}
\arguments{
\item{df}{A data.frame}

\item{bordercolor}{A border color name}

\item{format}{desired format. choices are "pptx" or "docx"}

\item{eval}{logical. Whether or not evaluate the code}
}
\value{
A flextable object
}
\description{
Make a flextable with a data.frame
}
