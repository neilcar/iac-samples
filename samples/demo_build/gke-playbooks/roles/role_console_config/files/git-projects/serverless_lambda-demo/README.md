# lambda_sample

* Jenkins pre-reqs
  * Plugins
    * AWS Lambda Plugin (for uploading to Lambda)
    * CloudBees AWS Credentials Plugin (for AWS access/secret)
    * Pipeline Utility Steps (for zip pipeline step)
  * Credentials
    * twistlock_creds -- username/password for Twistlock Console with Defender Manager or better role
    * AWS_acct -- AWS credentials with sufficient permission to upload Lambda functions
  * Environment variables
    * TL_CONSOLE -- the FQDN for the Twistlock Console