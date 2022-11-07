# Purpose

This demo is intended to create a container that is vulnerable to [CVE-2017-5638](https://nvd.nist.gov/vuln/detail/CVE-2017-5638).  This vulnerability is notable as it is, reportedly, the initial vulnerability used to compromise Equifax.

This is a real-world scenario that should resonate well with customers.  My experience has been that customers tend to deploy applications based on frameworks like JBoss and Struts and forget about them -- this has led to compromises like Equifax and the Samas/SamSam ransomware family that disproportionately affected hospitals in early 2016 due to a popular Electronic Medial Records (EMR) system that was running an unpatched version of JBoss.  

# Implementation

## Architecture

This demo consists of two containers:

* struts.server

This container runs a vulnerable version of Struts2 and the Struts Showcase app.  Tcp/8080 is exposed only on the network created for the demo to prevent any accidental compromise.

* struts.client

This container includes a sample exploit script to create a remote command shell, ncat (to act as a listener for the remote shell), and a handy script to kick it off.

## Install

1. Copy all the files to your Docker host.  In this example, I'll use /home/neil/projects/struts2
2. Move to your project directory
    ```
    CD /home/neil/projects/struts2
    ```
3. Build and start the project
    ```
    docker-compose build && docker-compose up -d
    ```
4. In the Twistlock console, force manual learning for struts2_struts.server, then stop the manual learning.
5. Execute the script to gain remote shell
    ```
    docker exec -it struts.client /bin/sh /struts2/exploit.sh
    ```
6. You should get a remote shell to struts.server  Use this to run a variety of interesting commands

    ```
    uname -a
    apt-get update
    apt-get install nmap
    nmap -v -sn 172.18.0.0/16
    ```
    
7. Your Incident Explorer should now be lit up like a Christmas tree.
