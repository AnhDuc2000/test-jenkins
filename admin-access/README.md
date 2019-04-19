# How to Obtain Admin Access to Confluence

## Uploading your public ssh key

- Create a PR and load your public ssh key into this directory *admin-access*

- Name the key by your name, such as, *jay-shain.pub*

- Inside the key file at the end append a space and your email address so we know actually who are, such as

  ```
  ssh-rsa abcdfasdfgasdfasdfasdfasdfasdfrasd...fasdfasdfasdfasd jay.shain@dxc.com
  ```

## Process for loading the keys

The public key is appended to the authorized_keys file in this repo. For each system, below, the public keys and authorized key file are copied into the directory.

```
/home/ec2-user/.ssh
```

## List of systems where keys are applied
Check AWS Console to get the latest IPs as some are elastic IPs.

Pentest Systems
* confluence-node-01a-pentest 
* confluence-node-02a-pentest

Production Systems
* confluence-node01a-prod
* confluence-node02a-prod
* confluence-node03-prod-backup

Obsolete Pentest Systems (DO NOT USE or Restart in AWS)          
* confluence-node02-pentest
* confluence-node05-pentest 

Obsolete Production Systems (DO NOT USE or Restart in AWS)
* confluence-node01-prod 
* confluence-node02-prod 
