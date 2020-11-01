# -*- coding: utf-8 -*-
"""
Created on Sun Nov  1 08:02:44 2020

@author: trevor
"""
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix

# Import the data frames
wf = pd.read_csv('data/datasets/fake_domain_word_freq.csv')
df = pd.read_csv('data/datasets/fake_real_domains_combined.csv')
rs = pd.read_csv('data/datasets/reg_scores.csv')

# Score domain keywords based on word frequencies in the sample
for e, dom in enumerate(df['dom_split']):
    dom_split = dom.split(' ')
    score = 0
    for word in dom_split:
        try:
            prob = wf.loc[wf['word'] == word, 'samp_freq'].values[0]
        except IndexError: prob = 0
        score += prob
    df.loc[e, 'dom_score'] = score
mult = 1/df['dom_score'].max()
df['dom_score'] = df['dom_score'] * mult

# Score registrars based on word frequencies in the sample
for e, reg in enumerate(df['registrar']):
    score = 0
    other_val = rs.loc[rs['registrar'] == 'Other', 'reg_score'].values[0]
    try:
        prob = rs.loc[rs['registrar'] == reg, 'reg_score'].values[0]
    except IndexError: prob = other_val
    df.loc[e, 'reg_score'] = score

df.tail()

# Fill NAs for rank with the highest known one
df['rank'] = df['rank'].fillna(df['rank'].max())

# Create the feature vector 
features = ['domain_length', 'keyword_length', 'num_nameservers',
            'dom_age_days', 'dom_score', 'reg_score', 'rank']

# Ensure even splits for the train/test/validate sets
len(df[features].dropna()) % 3
print('Starting length: {}'.format(len(df)))
remove_n = len(df) % 3
drop_indices = np.random.choice(df.index, remove_n, replace=False)
df = df.drop(drop_indices)
print('Ending length: {}'.format(len(df)))

# Create the split datasets for train, validate, and test
train, validate, test = np.split(
    df.sample(frac=1, random_state=42), [int(.6*len(df)), int(.8*len(df))])
y = train['trust']

# Check for NaN values in the sets
print(train[features].isnull().sum().sum())
print(validate[features].isnull().sum().sum())
print(test[features].isnull().sum().sum())
df[features].tail()

# Train the classifier
X = pd.get_dummies(train[features])
X_test = pd.get_dummies(test[features])

model = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=1)
model.fit(X, y)
predictions = model.predict(X_test)

# Create confusion matrix
pd.crosstab(test['trust'], predictions, rownames=['Actual trust'], 
            colnames=['Predicted trust'])
# View a list of the features and their importance scores
list(zip(train[features], model.feature_importances_))

# Review the output
output = pd.DataFrame({'domain': test.domain,
                       'assigned_trust': test.trust,
                       'prediction': predictions,
                       'correct': test.trust == predictions})

print(output.loc[output['correct'] == False])
num_false = len(output.loc[output['correct'] == False])
samp_size = len(output)
print('Number of samples: {}'.format(samp_size))
print('Number of errors: {}'.format(num_false))
print('Total correct: {}%'.format(1 - (num_false/samp_size)))

# Validatation
X = pd.get_dummies(train[features])
X_test = pd.get_dummies(validate[features])

model = RandomForestClassifier(n_estimators=100, max_depth=5, random_state=1)
model.fit(X, y)
predictions = model.predict(X_test)

# Calculate the confusion matrix
conf_matrix = confusion_matrix(y_true=validate['trust'], y_pred=predictions)

# Print the confusion matrix using Matplotlib
fig, ax = plt.subplots(figsize=(5, 5))
ax.matshow(conf_matrix, cmap=plt.cm.Oranges, alpha=0.3)
for i in range(conf_matrix.shape[0]):
    for j in range(conf_matrix.shape[1]):
        ax.text(x=j, y=i,s=conf_matrix[i, j], va='center', ha='center', size='xx-large')

plt.xlabel('Predictions', fontsize=18)
plt.ylabel('Actuals', fontsize=18)
plt.title('Confusion Matrix', fontsize=18)
plt.show()

# Review the output
output = pd.DataFrame({'domain': validate.domain,
                       'assigned_trust': validate.trust,
                       'prediction': predictions,
                       'correct': validate.trust == predictions})

print(output.loc[output['correct'] == False])
num_false = len(output.loc[output['correct'] == False])
samp_size = len(output)
print('Number of samples: {}'.format(samp_size))
print('Number of errors: {}'.format(num_false))
print('Total correct: {}%'.format(1 - (num_false/samp_size)))