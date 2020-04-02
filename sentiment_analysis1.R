#Sentiment Analysis
library(tidytext)
data=sentiments
#The bing lexicon model on the other hand, 
#classifies the sentiment into a binary category of negative or positive.
#retrieve these lexicons using the get_sentiments() function
result=get_sentiments("bing")

#########Performing Sentiment Analysis with the Inner Join#############
#The janeaustenr package will provide us with the textual data in the form of books authored by the novelist
#Jane Austen. Tidytext will allow us to perform efficient text analysis on our data. We will convert the text
#of our books into a tidy format using unnest_tokens() function.

library(janeaustenr)
library(stringr)
library(dplyr)
a=austen_books()
##1st we need to split the multiple words into each row of the novel into the data format of one word per row.
##the function unnest_tokens splts the table into one-token-per-row. This function supports non-standard 
# str_detect - Detect the presence or absence of a pattern in a string.
tidy_data=austen_books() %>%
  group_by(book) %>%
  mutate(linenumber= row_number(),
         chapter = cumsum(str_detect(text,regex("^chapter [\\divxlc]",ignore_case = TRUE)))) %>%
  ungroup() %>%
  unnest_tokens(word,text)
##We will now make use of the "bing" lexicon to and implement filter() over the words that correspond
#to joy. We will use the book Emma and derive its words to implement out sentiment 
#analysis model.
positive_senti <- get_sentiments("bing") %>%
  filter(sentiment == "positive")
count=tidy_data %>%
  filter(book == "Emma") %>%
  semi_join(positive_senti) %>%
  count(word, sort = TRUE)
##we will use spread() function to segregate our data into separate columns of positive and negative 
#sentiments. We will then use the mutate() function to calculate the total sentiment, that is, the 
#difference between positive and negative sentiment.
library(tidyr)
data=get_sentiments("bing")
Emma_senti=tidy_data %>%
  inner_join(data) %>%
  count(book="Emma",index=linenumber%/%80,sentiment) %>%
  spread(sentiment,n,fill=0) %>%
  mutate(sentiment=positive-negative)
##proceed towards counting the most common positive and negative words that are present in the novel.
counting_words <- tidy_data %>%
  inner_join(data) %>%
  count(word, sentiment, sort = TRUE)
head(counting_words)

##We will use ggplot() function to visualize our data based on their scores.
library(ggplot2)
counting_words %>%
  filter(n > 150) %>%
  mutate(n = ifelse(sentiment == "negative", -n, n)) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment))+
  geom_col() +
  coord_flip() +
  labs(y = "Sentiment Score")
##we will use the comparision.cloud() function to plot both negative and positive words 
##in a single wordcloud
library(reshape2)
library(wordcloud)
win.graph(10,10,0.2)
tidy_data %>%
  inner_join(data) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("red", "dark green"),
                   max.words = 100)

















