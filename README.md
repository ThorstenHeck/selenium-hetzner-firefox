## Create a fresh Hetzner Project export API_TOKEN manage Member

Clone this repo

    git clone git@github.com:ThorstenHeck/selenium-hetzner.git

Build the image

    docker build -t hetzner_login . 

Run the Container with the right environment variables and create a new Project

    docker run --rm --name selenium-hetzner-firefox \
        -e USERNAME=$HETZNER_USERNAME \
        -e PASSWORD=$PASSWORD \
        -e PROJECT=$PROJECT \
        -e PERMISSIONS="Read & Write" \
        thorstenheck0/hetzner-opnsense:selenium-hetzner-firefox-v1.0 -cg
        
## hetzner_login.py

The Container will start the hetzner_login.py and based on its input parameter is capable of creating a Project, Generating an API_Token and prints it and adding Member to an existing Project.  


Ceates a new Hetzner Project

    hetzner_login.py -c

Generates an API_TOKEN for an existing project

    hetzner_login.py -g

Add Member to a Project

    hetzner_login.py -a

### Environment variables

    USERNAME = Hetzner Account with owner Permissions to be able to create Projects
    PASSWORD = Password for Hetzner Account
    PROJECT = Project name
    PERMISSIONS = API Token permissions, default is Read & Write - it can also be "Read"
    MEMBER = Name of user to add to the Project
    MEMBER_ROLE = Permission Level of the added User - admin, member, restricted is possible