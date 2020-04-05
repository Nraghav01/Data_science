##To build a model to accurately classify a piece of news as REAL or FAKE.
import itertools
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split #to split arrays or matricies in random test or train sets
from sklearn.feature_extraction.text import TfidfVectorizer #Convert a collection of raw documents to a matrix of TF-IDF features.
from sklearn.linear_model import PassiveAggressiveClassifier
from sklearn.metrics import accuracy_score, confusion_matrix

# Read the data
df=pd.read_csv('news.csv')

df.shape
df.head()
l=df.label
l.head()
##Split the dataset into training and testing sets.
x_train,x_test,y_train,y_test = train_test_split(df['text'],l,test_size=0.2,random_state=100)
#Let’s initialize a TfidfVectorizer with stop words from the English language and
# a maximum document frequency of 0.7 (terms with a higher document frequency 
#will be discarded). Stop words are the most common words in a language that are
# to be filtered out before processing the natural language data. And a TfidfVectorizer 
#turns a collection of raw documents into a matrix of TF-IDF features.
vec = TfidfVectorizer(stop_words='english',max_df=0.7)

#fit and transform the vectorizer on the train set, and transform the vectorizer on the test set.
tfidf_train=vec.fit_transform(x_train)
tfidf_test=vec.transform(x_test)

# initialize a PassiveAggressiveClassifier. This is. We’ll fit this on tfidf_train and y_train.
pac = PassiveAggressiveClassifier(max_iter=50)
pac.fit(tfidf_train,y_train)

#Predict on the test set and calculate accuracy
y_pred = pac.predict(tfidf_test)
score = accuracy_score(y_test,y_pred)
score
print(f'Accuracy: {round(score*100,2)}%')

confusion_matrix(y_test,y_pred,labels=['FAKE','REAL'])
























