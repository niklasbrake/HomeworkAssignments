import re
import mmap

def getCorpus():
    Titles = ['King Lear.txt','King Richard II.txt',
    'Measure for measure.txt','Merchant of Venice.txt',
    'The Tempest.txt','King Henry IV Part I.txt','King Henry IV Part II.txt',
    'Twelfth Night.txt','A Midsummer Night\'s Dream.txt',
    'The Comedy of Errors.txt','As You Like It.txt']


    open('ShakespeareData.xml', 'w').close()
    play = open('ShakespeareData.xml','a')
    play.write('<dialog>')

    for title in Titles:
        newLines = getDialog(title)
        with open('Processed ' + title[:-4] + '.xml','r') as file:
            for row in file:
               play.write(row)
        play.writelines('\n')

    play.write('</dialog>')

    play.close()

def getDialog(filename):
    # Replace stage directions and other comments
    cleanDialog(filename)
    # Extract the names of the characters
    Characters = getCharacters(filename)
    # Replace character names with IDs
    replaceID(filename,Characters)
    # Chop into scenes, add <s> tags and remove line breaks
    newLines = formatFile('Processed ' + filename[:-4] + '.xml')
    # return newLines

def cleanDialog(filename):
    with open('temp.txt', 'w') as f2:
        with open(filename, 'r+') as f:
            # Map file into memory
            data = mmap.mmap(f.fileno(), 0)
            # Regex anything between ( ) replace with <direction>
            data = re.sub('\([^)]*\)', '', data)
            # Regex anything between { } replace with nothing
            data = re.sub('\{[^)]*\}', '', data)
            # Save data
            f2.write(data)
    # Some reason file is double spaced now? Should probably think
    # more about that...
    with open('temp.txt', 'r') as f2:
        with open(filename, 'w') as f:
            for row in f2:
                f.write(row.strip())
                f.write('\n')

def getCharacters(filename):
    characters2 = []
    # Three rows in memory checks for beginning of paragraphs
    row = [[],[],[]]
    n = 0
    with open(filename) as play:
        for line in play:
            if(n == 0):
                row[0] = line.strip().split()
            elif(n == 1):
                row[1] = line.strip().split()
            else:
                row[n%3] = line.strip().split()
                # If the line is non-empty, the previous line is empty, and the next line is non-empty
                if(len(row[(n-2)%3]) == 0 and len(row[n%3])>0 and len(row[(n-1)%3]) > 0):
                    toAdd = False
                    # If the first word is not in the character list and not a scene of act
                    if(len(row[(n-1)%3]) > 1):
                        if(row[(n-1)%3][1] != 'Scene.' or row[(n-1)%3][1] != 'Aufzug.' or row[(n-1)%3][1] != 'Szene' or row[(n-1)%3][1] != 'Auftritt.'):
                            if(not row[(n-1)%3][0] in characters2 and len(row[(n-1)%3][0]) > 1):
                                # Add first word (i.e. characters name) to character list
                                characters2.append(row[(n-1)%3][0])
                    else:
                        if(not row[(n-1)%3][0] in characters2 and len(row[(n-1)%3][0]) > 1):
                            # Add first word (i.e. characters name) to character list
                            characters2.append(row[(n-1)%3][0])
            n += 1
    return characters2

def replaceID(filename,chars):
    row = [[],[],[]]
    n = 0
    open_tag = False
    with open(filename,'r+') as play:
        lines = play.readlines()
        for line in lines:
            if(n == 0):
                row[0] = line.strip().split()
            elif(n == 1):
                row[1] = line.strip().split()
            else:
                row[n%3] = line.strip().split()
                # Same as in getCharacters. Find character name
                if(len(row[(n-2)%3]) == 0 and len(row[n%3])>0 and len(row[(n-1)%3]) > 0):
                    name = row[(n-1)%3][0]
                    # Replace name with tag and ID number
                    if(name in chars):
                        lines[n-1]='<utt uid="' + str(chars.index(name)) + '">'
                        open_tag = True
                row[n%3] = line.strip().split()
                # If at the end of a paragraph and there is an open utterance tag
                if(len(row[(n-2)%3]) > 0 and len(row[n%3])==0 and len(row[(n-1)%3]) > 0 and open_tag):
                    # Close the utterance tag
                    lines[n-1] = lines[n-1].strip() + '</utt>'
                    open_tag = False
            # If line is not empty, remove carriage return (i.e. utterances now one line)
            if(len(line.strip())>0):
                lines[n] = line.strip() + ' '
            n+=1
    play = open('Processed ' + filename[:-4] + '.xml','w')
    play.writelines(lines)

def formatFile(filename):
    with open(filename,'r+') as play:
        lineCount = 0
        start = 0
        newLines = []
        for line in play:
            head = line.strip().split()
            if(len(head) > 1):
                # Save line if an utterance or a scene beginning
                if(head[0] == '<utt'):
                    newLines.append(line.strip())
                    lineCount += 1
                # Replace scene with <s> tag
                elif(head[1] == 'SZENE' or head[1] == 'Scene.' or head[1] == 'Szene' or head[1] == 'Auftritt.'):
                    # If first scene, don't need to close previous tag
                    if(start == 0):
                        newLines.append('<s>')
                        start = lineCount
                    else:
                        newLines.append('</s>\n<s>')
                    lineCount += 1
        # Ignore everything before first scene (assuming the end has been trimmed manually)
        newLines = newLines[start:]
        if(newLines[-1][-6:] != '</utt>'):
            newLines.append('</utt>')
        newLines.append('</s>')
    play = open(filename,'w')
    play.writelines(newLines)
    play.close()
    return newLines

