# docker-test

This project builds a simple node.js app and, if successful, pushes to the local registry.

It uses a catch()) block to continue the build even if the scan fails.  The `policy: 'high'` will cause a scan failure if you don't change it.

```
    stage('Scan image') {
    try {
        // do something that fails
        twistlockScan ca: '', cert: '', gracePeriodDays: 60, compliancePolicy: 'warn', dockerAddress: 'unix:///var/run/docker.sock', ignoreImageBuildTime: true, image: 'tl_demo/hellonode:latest', key: '', logLevel: 'true', policy: 'high', requirePackageUpdate: false, timeout: 10
        currentBuild.result = 'SUCCESS'
    } catch (Exception err) {
        currentBuild.result = 'UNSTABLE'
    }
```