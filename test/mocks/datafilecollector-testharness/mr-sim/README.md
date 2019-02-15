## Developer workflow

1. ```sudo apt install python3-venv```
2. ```source .env/bin/activate/```
3. ```pip3 install "anypackage"```      #also include in source code
4. ```pip3 freeze | grep -v "pkg-resources" > requirements.txt```   #to create a req file
5. ```FLASK_APP=mr-sim.py flask run```

    or

   ```python3 mr-sim.py ```

6. Check/lint/format the code before commit/amed by ```autopep8 --in-place --aggressive --aggressive mr-sim.py```


## User workflow on *NIX


When cloning/fetching from the repository first time:
1. `git clone`
2. `cd "..." ` 		#navigate to this folder
3. `source setup.sh `	#setting up virtualenv and install requirements

    you'll get a sourced virtualenv shell here, check prompt
4. `(env) $ python3 mr-sim.py --help`

    alternatively

    `(env) $ python3 mr-sim.py --tc1`

Every time you run the script, you'll need to step into the virtualenv by following step 3 first.

## User workflow on Windows

When cloning/fetching from the repository first time:

1. 'git clone'
2. then step into the folder
3. 'pip3 install virtualenv'
4. 'pip3 install virtualenvwrapper-win'
5. 'mkvirtualenv env'
6. 'workon env'
7. 'pip3 install -r requirements.txt'   #this will install in the local environment then
8. 'python3 dfc-sim.py'

Every time you run the script, you'll need to step into the virtualenv by step 2+6.