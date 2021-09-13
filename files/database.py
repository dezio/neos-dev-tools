import yaml
import sys
import os.path

dir = sys.argv[1]
configFile = dir + "/Configuration/Settings.yaml"

username=""
password=""
database=""

print ("The dir is %s" % dir)

if __name__ == '__main__':
    with open(os.path.dirname(configFile) + "/../mysql-data.txt", 'r') as fin: 
      lines = fin.readlines()
      for i, line in enumerate(lines):
        if i == 0: username = line.strip()
        if i == 1: password = line.strip()
        if i == 2: database = line.strip()

    stream = open(configFile, 'r')
    dictionary = yaml.safe_load(stream)
    if not dictionary.has_key("Neos") is None:
      dictionary['Neos'] = {}

    if not dictionary['Neos'].has_key("Flow") is None:
      dictionary['Neos']['Flow'] = {}

    if not dictionary['Neos'].has_key("Project") is None:
      dictionary['Neos']['Project'] = {}
    
    if not dictionary['Neos'].has_key("Imagine") is None:
      dictionary['Neos']['Imagine'] = {"driver": "Imagick"}

    if not dictionary['Neos']['Flow'].has_key("persistence") is None:
      dictionary['Neos']['Flow']['persistence'] = {}
    
    if not dictionary['Neos']['Flow']['persistence'].has_key("backendOptions") is None:
      dictionary['Neos']['Flow']['persistence']['backendOptions'] = {
        "driver": "pdo_mysql",
        "dbname": database,
        "user": username,
        "password": password,
        "host": "127.0.0.1"
      }

    newConfig = yaml.dump(dictionary)
    stream.close()
    f = open(configFile, "w")
    f.write(newConfig)
    f.close()
    print newConfig