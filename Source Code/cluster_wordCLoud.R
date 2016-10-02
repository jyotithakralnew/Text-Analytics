
library(openxlsx)
library(tm)
library(wordcloud)

data = read.xlsx("cluster_train.xlsx")

cluster_2 = data[which(data$TextCluster2_cluster_ == 2),]
cluster_3 = data[which(data$TextCluster2_cluster_ == 3),]

cluster2 = paste(cluster_2$`_comment_`, collapse = " ")
cluster3 = paste(cluster_3$`_comment_`, collapse = " ")

rei_corpus = Corpus(VectorSource(cluster3))
rei_corpus = tm_map(rei_corpus, tolower)
rei_corpus = tm_map(rei_corpus, removeWords, c(stopwords("english"), "can", "form", "now"))
rei_corpus = tm_map(rei_corpus, stripWhitespace)
rei_corpus = tm_map(rei_corpus, PlainTextDocument)
tdm = TermDocumentMatrix(rei_corpus)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
pal <- brewer.pal(8, "Dark2")
wordcloud(d$word,d$freq, colors=pal)

rei_corpus = Corpus(VectorSource(cluster2))
rei_corpus = tm_map(rei_corpus, tolower)
rei_corpus = tm_map(rei_corpus, removeWords, c(stopwords("english"), "rei", "amp"))
rei_corpus = tm_map(rei_corpus, stripWhitespace)
rei_corpus = tm_map(rei_corpus, PlainTextDocument)
tdm = TermDocumentMatrix(rei_corpus)
m <- as.matrix(tdm)
v <- sort(rowSums(m),decreasing=TRUE)
d <- data.frame(word = names(v),freq=v)
pal <- brewer.pal(8, "Dark2")
wordcloud(d$word,d$freq, colors=pal)
