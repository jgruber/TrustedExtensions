# TrustedExtensions
**iControlLX extension to publish iControlLX extensions to trusted devices**

The process to install iControlLX extensions has multiple steps and is complex. This extension provides a simplified user experience for querying, installing, and removing iControlLX extensions on trusted devices.

## Building the Extension ##

The repository includes the ability to simply run 

`npm run-script build` 

in the repository root folder. In order for this run-script to work, you will need to be on a linux workstation with the `rpmbuild` utility installed.

Alternatively rpm builds can be downloaded from the releases tab on github.

## Installing the Extension ##

The installation instructions for iControlLX rpm packages are found here:

[Installing iControlLX Extensions](https://clouddocs.f5.com/products/iapp/iapp-lx/docker-1_0_4/icontrollx_pacakges/working_with_icontrollx_packages.html)

This extension has been tested on TMOS version 13.1.1 and the [API Service Gateway](https://hub.docker.com/r/f5devcentral/f5-api-services-gateway/) container.

## General Control Parameters ##

This extension extends the iControl REST URI namespace at:

`/mgmt/shared/TrustedExtensions`

There are two controlling parameters which govern the behavior of this extension:

| Parameter | Value |
| --------- | ------ |
|`targetHost`| The trusted device host or if not supplied the local device
|`url` | The URL to download the rpm file of the iControlLX extension

For `GET` and `DELETE` methods, these parameters can be populated through query parameters. For `POST` and `PUT` requests, these parameters can be issued in the request body as a JSON object, or they can be supplied as query parameters.

## Query Installed Extensions on Trusted Devices ##

To retrieve a list of iControlLX extensions installed on a trusted host, use the `GET` method to query this extension. The `GET` method does not use the `url` parameter, only the `targetHost` parameter.

`GET /mgmt/shared/TrustedExtensions?targetHost=172.13.1.107`

Response

```
[
    {
        "name": "f5-declarative-onboarding",
        "version": "1.1.0",
        "release": "2",
        "arch": "noarch",
        "packageName": "f5-declarative-onboarding-1.1.0-2.noarch",
        "tags": [
            "PLUGIN"
        ],
        "rpmFile": "f5-declarative-onboarding-1.1.0-2.noarch.rpm",
        "downloadUrl": "https://172.13.1.107:443/tmp/f5-declarative-onboarding-1.1.0-2.noarch.rpm",
        "state": "AVAILABLE"
    },
    {
        "name": "f5-appsvcs",
        "version": "3.7.0",
        "release": "7",
        "arch": "noarch",
        "packageName": "f5-appsvcs-3.7.0-7.noarch",
        "tags": [
            "IAPP"
        ],
        "rpmFile": "f5-appsvcs-3.7.0-7.noarch.rpm",
        "downloadUrl": "https://172.13.1.107:443/tmp/f5-appsvcs-3.7.0-7.noarch.rpm",
        "state": "AVAILABLE"
    }
]
```

If no  `targetHost` query parameter is supplied, the request is placed against the device with this extension installed (`localhost`).

`GET /mgmt/shared/TrustedExtensions`

Response

```
[
    {
        "name": "TrustedProxy",
        "version": "1.0.0",
        "release": "0001",
        "arch": "noarch",
        "packageName": "TrustedProxy-1.0.0-0001.noarch",
        "tags": [
            "PLUGIN"
        ],
        "rpmFile": "TrustedProxy-1.0.0-0001.noarch.rpm",
        "downloadUrl": "https://localhost:8100/tmp/TrustedProxy-1.0.0-0001.noarch.rpm",
        "state": "AVAILABLE"
    },
    {
        "name": "TrustedDevices",
        "version": "1.0.0",
        "release": "0001",
        "arch": "noarch",
        "packageName": "TrustedDevices-1.0.0-0001.noarch",
        "tags": [
            "PLUGIN"
        ],
        "rpmFile": "TrustedDevices-1.0.0-0001.noarch.rpm",
        "downloadUrl": "https://localhost:8100/tmp/TrustedDevices-1.0.0-0001.noarch.rpm",
        "state": "AVAILABLE"
    },
    {
        "name": "TrustedExtensions",
        "version": "1.0.0",
        "release": "0001",
        "arch": "noarch",
        "packageName": "TrustedExtensions-1.0.0-0001.noarch",
        "tags": [
            "PLUGIN"
        ],
        "rpmFile": "TrustedExtensions-1.0.0-0001.noarch.rpm",
        "downloadUrl": "https://localhost:8100/tmp/TrustedExtensions-1.0.0-0001.noarch.rpm",
        "state": "AVAILABLE"
    }
]
```

## Install Extensions on Trusted Devices ##

The installation of an iControlLX extension on a trusted device takes several steps:

1. Download the iControlLX rpm file specified by the `url` parameter
2. Do a multi-part upload of the iControlLX rpm file to a temporary `downloadUrl` on the remote trusted device
3. Create the iControl REST `INSTALL` task on the trusted device
4. Query the task until complete

All of these steps are performed by this iControlLX extension asynchronously. The install request returns immediately with a `state` attribute of `REQUESTED`. From there the `state` attribute transitions to `DOWNLOADING`, `UPLOADING`, `INSTALLING`, and if there are no problems, `AVAILABLE`.

If an error happens anywhere in the process the `state` is transitioned to `ERROR`. Details on the cause of the error can be found in `/var/log/restjavad.0.log` and `/var/log/restnoded/restnoded.log` log files. If an error occurs, fix the problem, and then reissue the installation request.

The `POST` method can take the `targetHost` and `url` parameters as either query parameters:

`POST /mgmt/shared/TrustedExtensions?targetHost=172.13.1.107&url=url=https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.7.0/f5-appsvcs-3.7.0-7.noarch.rpm`

Request

```
{}
```

Reponse

```
{
    "rpmFile": "f5-appsvcs-3.7.0-7.noarch.rpm",
    "downloadUrl": "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.7.0/f5-appsvcs-3.7.0-7.noarch.rpm",
    "state": "DOWNLOADING",
    "name": "",
    "version": "",
    "release": "",
    "arch": "",
    "packageName": "",
    "tags": []
}
```

or as part of the request body.

`POST /mgmt/shared/TrustedExtensions`

Request

```
{
    "targetHost": "172.13.1.107"
    "url": "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.7.0/f5-appsvcs-3.7.0-7.noarch.rpm"
}
```


Response

```
{
    "rpmFile": "f5-appsvcs-3.7.0-7.noarch.rpm",
    "downloadUrl": "https://github.com/F5Networks/f5-appsvcs-extension/releases/download/v3.7.0/f5-appsvcs-3.7.0-7.noarch.rpm",
    "state": "DOWNLOADING",
    "name": "",
    "version": "",
    "release": "",
    "arch": "",
    "packageName": "",
    "tags": []
}
```

You can not issue requests against the newly installed iControlLX extension until it has a state of `AVAILABLE`.

The `PUT` method simply uninstalls the extension and attempts to reinstalls it. The `PUT` method has the same syntax as the `POST` method.

If the rpm file for the extension was downloadd onto the device where this extension is installed already, the `url` parameter supports the `file://` protocol. Otherwise the `url` parameter supports `http://` and `https://` protocols.


## Uninstalling Extensions on Trusted Devices ##

To uninstall an iControlLX extension from a remote trusted device, use the `DELETE` method on this extension's URI namespace. The `url` parameter for `DELETE` is parsed and expects the last path element to contain the name of the rpm file installed on the target device. You can simply specific the rpm file name for the `url` and the `DELETE` method will attempt to uninstall the named extension.

`DELETE /mgmt/shared/TrustedExtensions?targetHost=172.13.1.107&url=f5-declarative-onboarding-1.1.0-2.noarch.rpm`

Response

```
{
    "msg": "package in rpmFile f5-declarative-onboarding-1.1.0-2.noarch.rpm uninstalled on target 172.13.1.107:443"
}
```





