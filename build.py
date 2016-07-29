import os
import re
import shutil

version = "1.0"

#if not os.path.exists('builds'): os.mkdir('builds')
folderOut = "builds/"
folderOutLua = folderOut + "lua/"
folderOutLuaSuperUser = folderOut + "lua super user/"
folderOutRequire = folderOut + "require/"
if os.path.exists(folderOut): shutil.rmtree(folderOut)
os.mkdir(folderOut)
os.mkdir(folderOutLua)
os.mkdir(folderOutLuaSuperUser)
os.mkdir(folderOutRequire)
regex = re.compile('require.*"(.*)"')
folderInLua = "lua/"

for element in os.listdir(folderInLua):

     if element.endswith('.lua'):
          f2 = open(folderInLua + element, 'r')
          if "NOEXPORT" not in f2.readline(): # NOEXPORT pour les fichier include nottament
               f = open(folderInLua + element, 'r')
               g = open(folderOutLua + element, 'w')
               gSU = open(folderOutLuaSuperUser + element, 'w')
               g.write("-- From Falcon Punch " + version + "\n")
               g.write("-- Visit my website for updates at : http://louiscouka.com/\n\n")
               onlySuperUser = False
               for line in f:
                  if "NOEXPORT" in line: # NOEXPORT pour les fins de fichiers persos (savers perso)
                      onlySuperUser = True
                  expr = re.search(regex, line)
                  if expr is None:
                      if not onlySuperUser:
                           g.write(line)
                      gSU.write(line)
                  else:
                      includeFileName = expr.group(1) + '.lua'
                      includeFile = open(folderInLua + includeFileName, 'r')
                      includeFile.readline() # remove NOEXPORT line
                      for lineIncludeFile in includeFile:
                          if not onlySuperUser:
                               g.write(lineIncludeFile)
                          gSU.write(lineIncludeFile)
               f.close()
               g.close()

               #create require
               f = open(folderOutRequire + '_require ' + element, 'w')
               f.write('require "' + element[:-4] + '"')
               f.close()
          f2.close()

print ("Successfully packed")
