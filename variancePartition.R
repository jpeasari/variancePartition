## ----knitr, echo=FALSE, results='hide'----------------------------------------
library("knitr")
opts_chunk$set(tidy=FALSE,dev="pdf",fig.show="hide",
               fig.width=4,fig.height=4.5,
               message=FALSE, warning=FALSE)


## ----options, results="hide", echo=FALSE--------------------------------------
options(digits=3, width=80, prompt=" ", continue=" ")

## ----simResult, cache=TRUE, results='hide', fig.height=4, fig.width=4---------
# load library
library('variancePartition')
library("lme4")

# load simulated data:
# geneExpr: matrix of gene expression values
# info: information/metadata about each sample
geneExpr1 <- read.csv("IMMVAR_Refine2.csv",row.names = 1)
ncol(geneExpr1)


info1 <- read.csv("info_immVar1.csv")
nrow(info1)

info1$Sex <- as.factor(info1$Sex)
info1$Batch <- as.factor(info1$Batch)
info1$cellType <- as.factor(info1$cellType)
info1$Individual <- as.factor(info1$Individual)



nrow(info1) == ncol(geneExpr1)

## Analyzing the simulated format and variable in the package (variancePartition)
info_sim <- read.csv("info_simulated.csv")
nrow(info_sim)

imm_sim <- read.csv("geneExpr_simulated.csv")
ncol(imm_sim)

#data(varPartData)

# Specify variables to consider
# Age is continuous so model it as a fixed effect
# Individual and Tissue are both categorical, 
# so model them as random effects
# Note the syntax used to specify random effects
form1 <- ~ Age + (1|Individual) + (1|Sex) + (1|cellType) + (1|Batch)


# Fit model and extract results
# 1) fit linear mixed model on gene expression
# If categorical variables are specified, 
#     a linear mixed model is used
# If all variables are modeled as fixed effects, 
#		a linear model is used
# each entry in results is a regression model fit on a single gene
# 2) extract variance fractions from each model fit
# for each gene, returns fraction of variation attributable 
#		to each variable 
# Interpretation: the variance explained by each variables 
# after correcting for all other variables
# Note that geneExpr can either be a matrix, 
# and EList output by voom() in the limma package, 
# or an ExpressionSet
varPart1 <- fitExtractVarPartModel( geneExpr1, form1, info1 )

# sort variables (i.e. columns) by median fraction 
#		of variance explained
vp1 <- sortCols( varPart1 )

# Figure 1a
# Bar plot of variance fractions for the first 10 genes
plotPercentBars( vp1[1:10,] )

#
# Figure 1b
# violin plot of contribution of each variable to total variance
plotVarPart( vp1 )

## ----accessResults, cache=TRUE, warning=FALSE---------------------------------
# Access first entries
head(varPart1)

# Access first entries for Individual
head(varPart1$Individual)

# sort genes based on variance explained by Individual
head(varPart1[order(varPart1$Individual, decreasing=TRUE),])



## ----plotStratify, cache=TRUE, warning=FALSE, fig.height=4, fig.width=4-------
# get gene with the highest variation across Tissues
# create data.frame with expression of gene i and Sex 
#		type for each sample
i <- which.max( varPart1$Sex )
i
GE1 <- data.frame(t(geneExpr1[i,]), Sex = info1$Sex)
summary(GE1)
colnames(GE1)[1] <- "Expression"
ppp = rownames(geneExpr1)[i]
ppp
# plot expression stratified by Sex 
plotStratify(Expression ~ Sex,GE1,ppp)


### For cellType
i <- which.max( varPart1$cellType )
i
GE3 <- data.frame(t(geneExpr1[i,]), cellType = info1$cellType)
colnames(GE3)[1] <- "Expression"
summary(GE3)
ppp1 = rownames(geneExpr1)[i]
ppp1
# plot expression stratified by cellType 
plotStratify(Expression ~ cellType,GE3,ppp1)


#
# get gene with the highest variation across Individuals
# create data.frame with expression of gene i and Tissue 
#		type for each sample
i <- which.max( varPart1$Individual )
GE2 <- data.frame(t(geneExpr1[i,]), 
	Individual = info1$Individual)
colnames(GE2)[1] <- "Expression"
# Figure 2b
# plot expression stratified by Tissue 
label <- paste("Individual:", format(varPart1$Individual[i]*100, 
	digits=3), "%")
main <- rownames(geneExpr1)[i]
main
plotStratify(  Expression ~ Individual, GE2, colorBy=NULL, 
	text=label, main=main)

## ----cache=TRUE---------------------------------------------------------------
library('lme4')
geneExpr1[1,]
# fit regression model for the first gene 
form_test <- geneExpr1[1,] ~ Age + (1|Individual) + (1|Sex)
fit <- lmer(form_test, info1, REML=FALSE )

# extract variance statistics
calcVarPart(fit)

## ----canCorPairs, cache=TRUE, results='hide', fig.width=5, fig.height=5-------
form <- ~ Individual + Sex + cellType + Age 

# Compute Canonical Correlation Analysis (CCA)
# between all pairs of variables
# returns absolute correlation value  
C = canCorPairs( form, info1)

# Plot correlation matrix
plotCorrMatrix( C )



## ----vpInteraction, echo=TRUE, cache=TRUE, results='hide', fig.width=4, fig.height=4----
form <- ~ (1|Individual) + Age + (1|Sex) + (1|Batch) + (1|cellType)  +
  (1|Batch:Sex)

# fit model
vpInteraction <- fitExtractVarPartModel( geneExpr1, form, info1 )

plotVarPart( sortCols( vpInteraction ) )
########################################################################






















