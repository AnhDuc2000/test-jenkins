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
These are elastic IP addresses. You best check AWS Console to get the latest IPs

| Pentest Systems           | IP            |
| ------------------------- | ------------- |
| confluence-node02-pentest | DO NOT USE    |
| confluence-node05-pentest | DO NOT USE    |

| Production Systems            | Public IP      |
| ----------------------------- | -------------- |
| confluence-node03-prod-backup | 54.210.129.196 |
| confluence-node02a-prod       | 3.85.24.71     |
| confluence-node01a-prod       | 54.198.74.216  |
| confluence-node01-prod        | DO NOT USE     |
| confluence-node02-prod        | DO NOT USE     |
