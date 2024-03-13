# packer-aws-ami

```sh
packer fmt .      

```

```sh
packer validate .      

```

```sh
packer build -var-file="variables.pkrvars.hcl" .
packer build -debug aws-centos.pkr.hcl 
ssh -i /path/key-pair-name.pem instance-user-name@instance-public-dns-name   
```

```sh
aws ec2 deregister-image --image-id ami-*************
```

```sh
export AWS_PROFILE=nonprod
```
