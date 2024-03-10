# packer-aws-ami

```sh
packer fmt .      

```

```sh
packer validate .      

```

```sh
packer build -debug aws-centos.pkr.hcl 
ssh -i /path/key-pair-name.pem instance-user-name@instance-public-dns-name   
```


```sh
aws ec2 deregister-image --image-id ami-*******
```