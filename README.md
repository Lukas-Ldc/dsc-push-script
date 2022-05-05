# Desired State Configuration Push Script

This script allows you to deploy easily your desired state configurations via the push mode (manually or automatically). It must be in a separate folder and inside, in addition to it, there must be "configuration folders". They contain one or multiple DSC configuration files (.ps1). After the execution of the script, in each configuration folder, a log file with a folder containing the MOF files will be present. Each configuration folder must start with Config_, and you can create as many as you want. They are used to store the DSC configuration files. Inside, you can put as many as you want. Nevertheless, an important rule to follow is to have the same name between the file and the configuration name at the beginning of it (case sensitive). Afterwards, the configurations will be applied to the nodes, and you will find information about the status of the configurations on the nodes in the log files. This makes it easy to know if the configuration has been applied and when. The main log file in the root folder contains the date the script was last run and the success rate on the nodes based on the configuration folder and file. The log files in the configuration folders contains the date the configuration was last applied to the nodes and the date it was last verified. These two dates are followed by a list of the nodes and their status regarding the configuration.

This is the inside of the root folder :

<img src="/readme.img/root_folder.png?raw=true" alt="The root folder" width="200">

This is the inside of a configuration folder :

<img src="/readme.img/config_folder.png?raw=true" alt="The config folder" width="200">

This is the root log file and a configuration log file :

<img src="/readme.img/log_files.png?raw=true" alt="The config folder" width="400">
