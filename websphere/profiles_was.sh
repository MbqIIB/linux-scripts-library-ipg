#!/bin/bash

# Terminology and basic concepts for WAS fundamentals understanding:
# Cell: Virtual unit composed by a Deployment Manager and several nodes.
# Deployment Manager: Process that manages installation and maintenance of apps, connection pools
# and other resources related to a J2EE environment.
# The Deployment Manager communicates with the nodes through another process: Node Agent.
# The node is another virtual unit that is built of a Node Agent and one or more Server instances!!!

# [NODE : Server1, Server2 ... handled by Node Agent ... ] --> Managed by Deployment Manager

# The Node Agent is a process responsible for spawning and killing server processes, sync between 
# the Deployment Manager and the node.

# Servers are regular Java process responsible for serving J2EE requests (JSP, JSF, EJB, JMS ...)

# Cluster: Composed by several nodes. In WebSphere, a node may be managed individually, but we can
# also work by managing Cluster.

# Source: Youtube: SVR Technologies
# the main profiles in WAS: [a node has its own profile as well]
# 1) AppServer Profile
# 2) Cell Profile
# 3) Custom Profile
# 4) Management -- Deployment Manager, Job Manager, and Admin Agent
# 5) Secure proxy

## profiles can be defined via GUI --> /opt/IBM/WebSphere/Appserver/bin/ProfileManagement/pmt.sh
## or using command line tool --> /opt/IBM/WebShpere/AppServer/bin/manageprofiles.sh

WAS_HOME=/opt/IBM/WebSphere/Appserver

# our machine (hostname) can have multiple nodes, therefore, several profiles

# checking the system applications installed by default in our host:
ls -lah /opt/IBM/WebSphere/Appserver/systemApps # default systemApps !!!!!
# several *.ear files are displayed

## CREATING A USER IN GUI: easy ... just complete name for server, node, ports, and so on ...
# checking node configuration:
cd /opt/IBM/WebSphere/Appserver/profiles/<Profile_name>

### EXAMPLE FROM VIDEO: These are the parameters: (node name is used for administration)
# hostname is the domain name (DNS) or IP address
# serverName=server1, profile="AppSrv01", node="AppNode"

# for instance, for profile "AppSrv01": this is the profile name for server1
cd /opt/IBM/WebSphere/Appserver/profiles/AppSrv01
# checking in this profile for node "AppNode" the list of deployed apps:
cd /opt/IBM/WebSphere/Appserver/profiles/AppSrv01/config/cells/localhostNode01Cell/nodes/AppNode
# serverindex.xml file with the details for this node "AppNode" as follows:
<serverEntries ... serverName="server1" serverType="APPLICATION_SERVER">
	<deployedApplications>query.ear/deployments/query</deployedApplications>
	 # several tags like this below, one for each application deployed in the node

## Note: application binding ear files for installed apps by us are stored under folder:
ls -lah /opt/IBM/WebSphere/Appserver/profiles/AppSrv01/config/cells/applications

d .... query.ear

cd /opt/IBM/WebSphere/Appserver/profiles/AppSrv01/config/cells/applications/query.ear/deployments/query.ear/
# open deployment.xml for this app:
# modules are listed, some mappings, and the target server name and node name:
<deploymentTarget xmi:type="appdeployment:ServerTarget" xmi:id="ServerTarget_18726373" name="server1" nodeName="AppNode"/>

## CONSOLE: Access for managing WAS server1 in our example:
# back to serverindex.xml in the node configuration file for node name AppNode:
# /opt/IBM/WebSphere/Appserver/profiles/AppSrv01/config/cells/localhostNode01Cell/nodes/AppNode
# there are some important lines concerning WAS node admin:
<specialEndpoints xmi:id... endPointName="WC_adminhost">
	<endPoint ... host="*" port="10000"/>
</specialEndpoints>
<specialEndpoints xmi:id... endPointName="WC_defaulthost">
        <endPoint ... host="*" port="10002"/>
</specialEndpoints>

# urls then are:
http://HostNameOfserver:WC_adminhost/ibm/console
# or:
http://HostNameOfserver:WC_adminhost/admin
# same using https
# or:
http://localhost:10000/ibm/console
https://localhost:10001/ibm/console

# remember that server1 must be started via bin:
cd /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/bin
./startServer.sh server1

# logs for profile are under folder:
cd /opt/IBM/WebSphere/AppServer/profiles/AppSrv01/logs

## Summary: We start the server1 using bin from related profile folder, and we can access 
# the console to manage it. Server1 node name: AppNode. 
# If we want to chech the ports to access the console via url, for admin, then check one 
# of the node configs: serverindex.xml, in this case for AppNode node, and there are the 
# specialEndpoints indicating console ports.


### SCENARIOS:

# CREATING A PROFILE VIA GUI:
# 1. Profile Management Tool: /opt/IBM/WebSphere/Appserver/bin/ProfileManagement/pmt.sh
#    You can choose "Application Server", or go for Advanced Mode via "Custom Profile"
#    If "Custom Profile" --> "Advanced Profile Creation" .. type "profile" and "node" name 
#    Details for "hostname" and "port", check in: "Deployment Manager" --> "Ports"
#    SOAP_CONNECTOR_ADDRESS: HOSTNAME + PORT
# 2. Checking the new Profile and its node agent: System Administration --> Node agents
# 3. Now we can create a server managed by this Node Agent in the node for this recent profile
#    "Servers" --> "WebSphere application servers" --> Click on New .. 
#    Select the Node to be on top of this server, type a server name, check default ports, finish
#    
#    To sync the server with its Node on top, you follow the "Messages", click on "Review": sync
#
# 4. The server can be started
#
# 5. DEPLOYMENT: "Applications" --> "New Application" --> "New Enterprise Application"
#    Local File System: Choose File to upload and deploy it
#    Q: How do you want to install the app? Fast Path (easy mode), or Detailed
#    A: I go for Fast Path ..
#    Just accept all by default ... the screen for app modules, select the ones you need (say all)
#    Select the server you want the app to be deployed .. or cluster
#    Sync changes with node
#
# 6. Checking Apps: "Applications" --> "All applications" (here you check link between node-server-app)
#
# 7. Virtual Host: A Virtual Host is needed to be defined for the application:
#    "Environment" --> "Virtual Hosts" --> "default_host" --> Click on "Host Aliases": hostname: * port:#
#    Port for accessing App, check "Servers" --> Choose the one --> "Ports": WC_defaulthost
#    Use it for assigning it to the Virtual Host above, and then app is accessible via url:
#    Example: http://localhost:9084/applicationName
#    If we deploy other apps in this server, we use same port, but obviously with different applicationName


