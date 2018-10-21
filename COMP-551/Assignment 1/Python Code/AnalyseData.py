import re
import mmap
import operator
import string

filename = 'ShakespeareData.xml'
filename = 'NewPlays.txt'
filename = 'CombinedDataSet.xml'

# Find unique elements in seq
def f3(seq):
    keys = {}
    for e in seq:
        keys[e] = 1
    return keys.keys()

# Remove all tags
with open(filename,'r+') as f:
    data = mmap.mmap(f.fileno(),0)
    data = re.sub('\<.*?\>', '', data)
    len(data)
    data = data.split()
    len(data)

# Create dictionary of words with frequency
data2 = {}
for word in data:
    clean_word = word.translate(None, string.punctuation).lower()
    if clean_word in data2:
        data2[clean_word] += 1
    else:
        data2[clean_word] = 1

# Sort in descending order
sorted_data = sorted(data2.items(), key=operator.itemgetter(1),reverse=True)

# Save as csv
with open('DataProperties.csv','w') as f:
    for x in sorted_data:
        f.write(str(x[0]) + ',' + str(x[1]) + '\n')

# Remove everything that's not a tag
with open(filename,'r+') as f:
    data = mmap.mmap(f.fileno(),0)
    data = re.sub('\>.*?\<', '><', data).split('\n')
    UIDs = []
    # Find all numbers in each conversation
    for row in data:
        if(len(row.strip().split()) > 1):
            UIDs.append(re.findall('\d+',row))

# Total number of conversations
num_convs = len(UIDs)
# Unique IDs in each conversation
uniqueIDs = map(f3,UIDs)
# Number of unique IDs in each conversation
numberIDs = map(len,uniqueIDs)
# Average number of unique IDs in each conversation
avg_num_people = sum(numberIDs)/num_convs
# Total number of utterances
utt_total = sum(map(len,UIDs))
# Total number of words
word_count = sum([x[1] for x in sorted_data])
