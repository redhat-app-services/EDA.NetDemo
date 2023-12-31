# Setting Up

## Clone repo

Start by cloning this repository locally. 

eg.

```git
git clone https://github.com/ajhajj/EDA.NetDemo.git
```

Change directories into the newly created folder

```bash
cd EDA.NetDemo/
```

## Edit Common Config

Edit the common configuration file to reflect your settings.  We start by going into the scripts folder.  There you will see the file `common_cfg`.

```bash
cd scripts
ls
common_cfg  demo  deploy
```

Open this file for editing using your text editor of choice. We will be looking at 3 sections:

- OpenShift API Server Config

- OpenShift Credential Config

- quay.io credentials

```bash
# ==================================================================
#                OpenShift API Server Config
# ==================================================================

# Cloud instance connection details
API_CLOUD=https://api.cluster-trc9t.trc9t.sandbox3159.opentlc.com:6443

# Local CodeReadyContainers connection details
API_CRC=https://api.crc.testing:6443

# ==================================================================
#                OpenShift Credential Config
# ==================================================================

# Cloud Server Auth Tokens
TOKEN_ADMIN=sha256~63slZthCU-CE6r0WFVDVUgvx34Her6EJivJ1qK1kHF8
TOKEN_DEV=sha256~Z0ZKqtwY0598DNlSrKqj7VnfF01K4D-ZBaBPzz7dc1Y

# oc login command for cloud instance of openshift (using tokens)
#OC_LOGIN_KUBEADMIN='--token='"${TOKEN_ADMIN}"' --server='"${API_CLOUD}"''
#OC_LOGIN_DEVELOPER='--token=${TOKEN_DEV} --server='"${API_CLOUD}"''

# oc login command for cloud instance of openshift (using credentials)
#OC_LOGIN_KUBEADMIN='-u kubeadmin -p Si3Wz-AwIKL-jQ3NX-xoojX '"${API_CLOUD}"''
#OC_LOGIN_DEVELOPER='-u developer -p developer '"${API_CLOUD}"''

# oc login command for CRC instance (using credentials)
OC_LOGIN_KUBEADMIN="-u kubeadmin -p redhat! ${API_CRC}"
OC_LOGIN_DEVELOPER="-u developer -p developer ${API_CRC}"

# ==================================================================
#                quay.io credentials
# ==================================================================
QUAY_USER=<QUAY USER ID>
QUAY_TOKEN=<TOKEN GENERATED BY QUAY>
```

### Editing `OpenShift API Server Config`

In this section you want to update the value for either `API_CLOUD` or `API_CRC`.  If your OpenShift instance is OpenShift Local (CodeReadyContainers) then you will want to modify the value for `API_CRC` to reflect the URL for your OpenShift API server.  If you have a full OpenShift installation then do the same for `API_CLOUD`.

### Editing `OpenShift Credential Config`

In this section there are four stanzas.  The first stanza takes the TOKEN values for the admin and developer users.  

If you plan to use TOKENs please update these variables and uncomment the second stanza variables.  Remember to comment out the final (fourth) stanza.

If you plan on using passwords then update stanza 3 or 4 depending on whether you are connecting to a full OpenShift install or OpenShift Local (CRC).

Ensure that unused stanzas are commented out.

### Editing `quay.io credentials`

In this section replace `<QUAY USER ID>` with your Quay ID.  Once that is done also replace `<TOKEN GENERATED BY QUAY>` withe the token you obtained from the prerequisites section.

Save and close the file.

## Configure Red Hat Container Registry Secret

Open the file `yaml/3Scale/threescale-registry-auth.yaml` in a text editor of your choice.  Replace the string `<PULL_TOKEN>` with the token you previously created for the Red Hat container registry in the prerequisites section.  Save and close the file when done.

## Installing ZIP files

Place the ZIP archive files downloaded for AMQ Streams earlier as part of the prerequisite steps into the folder `zip_files`.  On the command line change directories to `zip_files` and execute the shell script `install.sh`.  This script will move the files to where they are expected.

---

[[back](../README.md#getting-started)]
