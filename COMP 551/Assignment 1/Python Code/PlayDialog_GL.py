import re
import os
from lxml import etree

def getCorpus():
    Titles = [  'Clavigo (Goethe).txt' , 
                'Der Bürgergeneral (Goethe).txt',
                'Egmont (Goethe).txt',
                'Götz von Berlichingen mit der eisernen Hand (Goethe).txt', 
                'Der Freigeist (Lessing).txt',
                'Der junge Gelehrte (Lessing).txt',
                'Die Juden (Lessing).txt',
                'Emilia Galotti (Lessing).txt',
                'Minna von Barnhelm (Lessing).txt',
                'Miss Sara Sampson (Lessing).txt',
                'Philotas (Lessing).txt']

    os.remove('AllPlays.xml')

    for title in Titles:
        getDialog(title)

def getDialog(filename):
    # Extract the names of the characters
    characters = getCharacters(filename)
    # Chop into scenes, add <s> tags and remove line breaks
    formatFile(filename, characters)

def getCharacters(filename):
    characterList = []
    with open(filename) as play:
        for idx, line in enumerate(play):
            sentence = re.sub("[\(\[].*?[\)\]]","",line).split()
            # Check that the line contains at least 2 words
            character = getCharacterName(sentence)
            if character and (character not in characterList):
                characterList.append(character)
    return characterList

def formatFile(filename, characterList):
    dialog = etree.Element('dialog')
    doc = etree.ElementTree(dialog)
    
    play = open(filename)
    fileDump = play.readlines()

    for idx, line in enumerate(fileDump):
        fileDump[idx] = re.sub("[\(\[].*?[\)\]]","",line)
    
    #remove empty lines
    lines = [x for x in fileDump if x not in "\n"]
    idx = 0
    #search through all lines
    while (idx+1) < len(lines):
        # Check if this line starts with character cue
        character = getCharacterName(lines[idx].split())
        idx += 1
        if character:    
            # We also need the next line to have a character cue to have a dialogue
            character2 = getCharacterName(lines[idx].split())
            
            if character2:
                convo = etree.SubElement(dialog, 's')
                etree.SubElement(convo, 'utt', uid=str(characterList.index(character)+1)).text=lines[idx-1].split('.', 1)[-1]
                etree.SubElement(convo, 'utt', uid=str(characterList.index(character2)+1)).text=lines[idx].split('.', 1)[-1]
                while character and (idx+1) < len(lines):
                    idx += 1
                    character = getCharacterName(lines[idx].split())
                    if character:
                        etree.SubElement(convo, 'utt', uid=str(characterList.index(character)+1)).text=lines[idx].split('.', 1)[-1] #.encode('ascii', 'xmlcharrefreplace')
    
    outFile = open('Processed ' + filename[:-4] + '.xml', 'wb')
    outFile2 = open('AllPlays.xml', 'ab')
    #doc.write(outFile,encoding="UTF-8",xml_declaration=True)
    doc.write(outFile, encoding = 'utf-8')
    doc.write(outFile2, encoding = 'utf-8')

    
def getCharacterName(sentence):
    result = ""
    if len(sentence) > 1:
        # Check if the character name is in the first word
        if "." in sentence[0]:
            result = sentence[0][:-1]
        # else character name is in the second word. Or it's made of two words
        elif "." in sentence[1]:                
            if sentence[1][0].isupper():
                result = sentence[0] + " " + sentence[1][:-1]
            else:
                result = sentence[0]
    return result
