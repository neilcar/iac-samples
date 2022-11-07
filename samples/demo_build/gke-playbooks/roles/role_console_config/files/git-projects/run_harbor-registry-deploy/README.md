# Harbor-Registry-Deploy

This project includes `Jenkinsfile`, used to deploy Harbor Registry from a helm chart, and adds the Harbor credential and registry configuration to the Twistlock console.

* Prereqs on Jenkins master
  * Credentials
    * twistlock_creds -- username/password for Twistlock Console with Defender Manager or better role
  * Environment variables
    * TL_CONSOLE -- the FQDN for the Twistlock Console
