# nikosch86/samba-timemachine

docker image to run encryptred SAMBA and provide a compatible TimeMachine share for MacOS

## How to use this image?

Example usage with default config:

```
docker run -d --restart=unless-stopped \
  --net=host \
  -v /path/to/folder:/data \
  nikosch86/samba-timemachine
```

This works best with `--net=host` so that discovery can be broadcast.  Otherwise, you will need to publish `137:137/udp`, `138:138/udp` ,`139:139` and `445:445`and manually map the share in Finder for it to show up (open Finder press Cmd-K and connect to `smb://hostname-or-ip/TimeMachine` with your TimeMachine credentials).

Default credentials:

* Username: `timemachine`
* Password: `timemachine`

Environment Variables:

| Variable | Description | Default |
| :------- | :------ | :---------- |
| TM_USERNAME | Username to access the share | timemachine |
| TM_PASSWORD | Password of the User | timemachine |
| TM_UID | UID of the User  | 1000 |
| TM_GID | GID of the User | 1000 |
| TM_GROUPNAME | Unix group of the User | timemachine |
| TM_SHARENAME | Name of the TimeMachine Share | TimeMachine |
| TM_SIZE_LIMIT | size limit for TimeMachine share, See the [Samba docs](https://www.samba.org/samba/docs/current/man-html/vfs_fruit.8.html) under the `fruit:time machine max size` section for more details | 0 |
| WORKGROUP | Workgroup for Samba Server | WORKGROUP |
| SHARENAME | Name of additional share | Share |
| MIMIC_MODEL | Model Name to announce | TimeCapsule8,119 |
| DISABLE_SAMBA_ENCRYPTION | set to yes to disable encryption in transit (improves performance 2x) | no |

## docker-compose

Use the provided compose file
