# Automatic1111 in OCI
Terraform script to start **automatic1111** in OCI using a nvidia GPU.

## Requirements
- Terraform
- ssh-keygen

## Configuration

1. Follow the instructions to add the authentication to your tenant https://medium.com/@carlgira/install-oci-cli-and-configure-a-default-profile-802cc61abd4f.

2. Clone this repository
```
git clone https://github.com/carlgira/oci-automatic1111
```

3. Set three variables in your path. 
- The tenancy OCID, 
- The comparment OCID where the instance will be created.
- The "Region Identifier" of region of your tenancy. https://docs.oracle.com/en-us/iaas/Content/General/Concepts/regions.htm

```
export TF_VAR_tenancy_ocid='<tenancy-ocid>'
export TF_VAR_compartment_ocid='<comparment-ocid>'
export TF_VAR_region='<home-region>'
```

4. Execute the script generate-keys.sh to generate private key to access the instance
```
sh generate-keys.sh
```

## Build
To build simply execute the next commands. 
```
terraform init
terraform plan
terraform apply
```

**After applying, the service will be ready in about 25 minutes** (it will install OS dependencies, nvidia drivers, and install automatic1111 with some extensions.

## Post configuration
To test the app it's necessary to create a ssh tunel to the port 7860  for automatic1111.  (the output of the terraform script will give the ssh full command so you only need to copy and paste)

```
ssh -i server.key -L 7860:localhost:7860 opc@<instance-public-ip>
```

## Test
Make sure to have the ssh tunnel open to  the apps.

Open the URL http://localhost:7860, in the top text area write and idea, and stable diffusion will try to draw it on screen. 

<img src="images/stable-diffusion-webui.jpg" />

Use https://lexica.art/ for examples of promts that you can use.


## Extensions

Installed some extensions so you can play around.

- **OutPaint** https://github.com/zero01101/openOutpaint-webUI-extension
- **Deforum** https://github.com/deforum-art/deforum-for-automatic1111-webui
- **Image Browser** https://github.com/yfszzx/stable-diffusion-webui-images-browser

## Clean
To delete the instance execute.
```
terraform destroy
```

## Troubleshooting
1. If one the service automatic1111.service is down, you can check the logs and the state of each service, with the commands.

```
systemctl status automatic1111.service
```

You can try to start the service by.
```
sudo systemctl start <service-name>
```

2. Error ***Error: 404-NotAuthorizedOrNotFound, shape VM.GPU2.1 not found***.
This could be happening because in your availability domain (AD) there is no a VM.GPU2.1 shape available. The script use by default the first AD, but maybe you have to change this manually.

Get the list of AD of your tenancy
```
oci iam availability-domain list
```

In the main.tf file, change the index number from "0" to other of the ADs of your region. (in the case that your region has more than one AD)
```
availability_domain = data.oci_identity_availability_domains.ADs.availability_domains[0].name
```
This error can also happen if in your region there is no VM.GPU2.1, in that case you have to change the region var before executing the scripts. 
```
export TF_VAR_region='<other-region>'
```

## References
- The automatic1111 project https://github.com/AUTOMATIC1111/