#install.packages("stringr")

library(wordcloud)
require(RCurl)
library(xlsx)
library(stringr)
setwd("E:/Madhu/Documents/Education/Personal Documentations/Hackathon")
pos_sentiments = readLines("positive-words.txt") #positive and negative words dictionary
neg_sentiments = readLines("negative-words.txt")

WebMD <- read.csv("complete_data2.csv")

reviewComment <- WebMD$comment


reviewWOrd_List = str_split(reviewComment, " ") #split each review word by word


sentiList <- list(length(reviewWOrd_List))

i <- 0
#count number of positive and negative maches for each review
positive_words = c()
negative_words = c()

for (i in 1: length(reviewWOrd_List)) {
  
  positive.matches = match(unlist(reviewWOrd_List[i]), pos_sentiments)
  
  if(length(which(!is.na(positive.matches)))>0){
    positive_words = c(positive_words, pos_sentiments[positive.matches[which(!is.na(positive.matches))]])
  }
  negative.matches = match(unlist(reviewWOrd_List[i]), neg_sentiments)
  if(length(which(!is.na(negative.matches)))>0){
     negative_words = c(negative_words, neg_sentiments[negative.matches[which(!is.na(negative.matches))]])
  }
  #  positive_matches
  # reviewWOrd_List[4]
  
  
  positive_matches = !is.na(positive.matches)
  negative_matches = !is.na(negative.matches)
  
  
  sentimentScore <- (sum(positive_matches) - sum(negative_matches))
  
  sentiList[i] <- c(sentimentScore)
  
}

#make blank list vectors for Neg, Pos and Neutral inputs

getNeg <- list(sum(sentiList < 0))
getPos <- list(sum(sentiList > 0))
getNeu <- list(sum(sentiList = 0))

i <- 1
j <- 1
k <- 1
l <- 1

for (i in 1: length(sentiList)) #if score is positive, move it under getPos array
{
  if (sentiList[i] > 0) 
  {
    getPos[j] <- c(sentiList[i])
    j <- j + 1
  } 
  else if (sentiList[i] < 0) 
  {
    getNeg[k] <- c(sentiList[i])
    k <- k + 1
  } 
  else 
  { 
    getNeu[l] <- c(sentiList[i])
    l <- l + 1
  }
}


#count number of pos and neg counts
i <- 0
highlyPos <- 0
mildlyPos <- 0

for (i in 1: length(getPos))
{
  if (as.integer(getPos[i])/max(unlist(getPos)) > 0.5) {
    highlyPos <- highlyPos + 1
  } else {
    mildlyPos <- mildlyPos + 1
  }
}

i <- 0
highlyNeg <- 0
mildlyNeg <- 0

for (i in 1: length(getNeg))
{
  if (as.integer(getNeg[i])/min(unlist(getNeg)) > 0.5) {
    highlyNeg <- highlyNeg + 1
  } else {
    mildlyNeg <- mildlyNeg + 1
  }
}
#convet count to percentage
highlyPosPct = round(highlyPos/ length(sentiList) * 100, digits = 0)
mildlyPosPct = round(mildlyPos/ length(sentiList) * 100, digits = 0)

highlyNegPct = round(highlyNeg/ length(sentiList) * 100, digits = 0)
mildlyNegPct = round(mildlyNeg/ length(sentiList) * 100, digits = 0)

NeutralPct = round(length(getNeu)/ length(sentiList) * 100, digits = 0)


finalSentiPct <- c("Highly Positive" = highlyPosPct, "Mildly Positive" = mildlyPosPct, "Highly Negative" = highlyNegPct, "Mildly Negative" = mildlyNegPct, "Neutral" = NeutralPct)

#creating label for pi chart
sentiLabel <- c("Highly Positive", "Mildly Positive", "Highly Negative", "Mildly Negative", "Neutral")
sentimentLabel <- paste(sentiLabel, finalSentiPct[])
sentimentLabel <- paste(sentimentLabel, "%", sep = "")

pieColor <- c("blue", "cornflowerblue","firebrick","firebrick1","dimgray")

pie(finalSentiPct,  main = "Sentiment Analysis", label = sentimentLabel, col=pieColor)

highlyPos
mildlyPos
highlyNeg
mildlyNeg
length(getNeu)

wd = table(positive_words)
wordss = c()
freqq = c()
for(i in 1:length(wd)){
  if(names(wd[i])!=""){
    wordss = c(wordss, names(wd[i]))
    freqq = c(freqq, wd[i])
  }
}
wordcloud::wordcloud(wordss, freqq, colors=brewer.pal(8, 'Dark2'))

nwd = table(negative_words)
nwordss = c()
nfreqq = c()
for(i in 1:length(nwd)){
  if(names(nwd[i])!=""){
    nwordss = c(nwordss, names(nwd[i]))
    nfreqq = c(nfreqq, nwd[i])
  }
}
wordcloud::wordcloud(nwordss, nfreqq, colors=brewer.pal(8, 'Dark2'))


