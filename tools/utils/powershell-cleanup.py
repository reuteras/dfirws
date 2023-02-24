# Created by Max 'Libra' Kersten (@Libranalysis)
# Source: https://maxkersten.nl/binary-analysis-course/analysis-scripts/automatic-string-formatting-deobfuscation/
 
import re
 
# Define information regarding the original script's location
powershellPath = 'powershellSample.txt'
powershellFile = open(powershellPath,'r')
# Read all lines of the original script
powershellContent = powershellFile.readlines()
 
# The variable which contains all deobfuscated lines
output = ''
# The variable which keeps track of the amount of string formats that have been replaced
formatCount = 0
# The variable which keeps track of the amount of variables that have been replaced
variableCount = 0
# The variable which keeps track of the amount of removed back ticks
backtickCount = 0
 
# Loop through the file, line by line
for line in powershellContent:
    backtickCount += line.count("`")
    # Replace the back tick with nothing to remove the needless back ticks
    line = line.replace("`", "")
    # Match the string formatting
    matchedLine = re.findall(""""((?:\{\d+\})+)"\s*-[fF]\s*((?:'.*?',?)+)""", line)
    # If one or more matches have been found, continue. Otherwise skip the replacement part
    if len(matchedLine) > 0:
        # Each match in each line is broken down into two parts: the indices part ("{0}{2}{1}") and the strings ("var", "ble", "ia")
        for match in matchedLine:
            # Convert all indices to integers within a list
            indices = list(map(int, re.findall("{(\d+)}", match[0])))
            # All strings are saved in an array
            strings = re.findall("'([^']+?)'", match[1])
            # The result is the correctly formatted string
            result = "".join([strings[i] for i in indices])
            # The current line is altered based on the found match, with which it is replaced
            line = line.replace(match[0], result, 1)
            line = line.replace(match[1], "", 1)
            # Regex the "-f" and "-F" so that "-f[something]" is not replaced
            formatFlag = re.findall("""(-[fF])(?=[^\w])""", line)          
            if len(formatFlag) > 0:
                for formatFlagMatch in formatFlag:
                    line = line.replace(formatFlagMatch, "")
            # Find all strings between quotation marks.
            varDeclaration = re.findall("""(?<=\()\"(?=[^\)]+\+[^\)]+\))(?:[^\{\}\-\)])+\"(?=\))""", line)
            # The concatenated variable
            variable = ''
            # For each string in the list, the items are concatenated
            if len(varDeclaration) > 0:
                for string in varDeclaration:
                    variable = string.replace("\"", "")
                    variable = variable.replace("+", "")
                    variable = variable.replace(" ", "")
                    variable = "\"" + variable + "\""
                    variableCount += 1
            # Replace the variable with the concatenated one
                line = line.replace(varDeclaration[0], variable)
            formatCount += 1
    # When all matches are done, add the altered line to the output
    output += line
# When all lines are checked, write the output variable to a file
with open('deobfuscatedSample.txt', 'w') as f:
    f.write(output)
print("Amount of removed back ticks:")
print(backtickCount)
print("Amount of formatted strings that have been deobfuscated and concatenated:")
print(formatCount)
print("Amount of variables that have been concatenated:")
print(variableCount)
print("Total amount of modifications:")
print((backtickCount + formatCount + variableCount))