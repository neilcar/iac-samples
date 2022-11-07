# Twistlock-Config

This project includes `Jenkinsfile`, used to fetch the Twistlock config from the console and store it in git, and `Jenkinsfile_push_config`, used to push the configuration from git back to the console.

* Prereqs on Jenkins master
  * Credentials
    * twistlock_creds -- username/password for Twistlock Console with Defender Manager or better role
  * Environment variables
    * TL_CONSOLE -- the FQDN for the Twistlock Console