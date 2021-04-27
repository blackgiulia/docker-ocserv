# About this docker image

This is a custom Docker image for [ocserv](http://www.infradead.org/ocserv/) which is a SSL VPN server.

```
Summary of build options:
  version:              0.12.6
  Host type:            x86_64-pc-linux-musl
  Install prefix:       /usr/local
  Compiler:             gcc
  CFlags:               -g -O2 -Wall -Wno-strict-aliasing -Wextra -Wno-unused-parameter -Wno-sign-compare -Wno-missing-field-initializers -Wno-implicit-fallthrough -Wno-stringop-truncation
  CWrap testing:        no
  CWrap PAM testing:    no
  CWrap NSS testing:    no

  PAM auth backend:     yes
  Radius auth backend:  no
  GSSAPI auth backend:  yes
  Anyconnect compat:    yes
  TCP wrappers:         no
  systemd:              no
  (socket activation)
  worker isolation:     seccomp
  Compression:          yes
  LZ4 compression:      yes
  readline:             yes
  libnl3:               yes
  liboath:              yes
  libgeoip:             no
  libmaxminddb:         yes
  glibc (sha2crypt):    no
  local talloc:         yes
  local protobuf-c:     no
  local PCL library:    yes
  local http-parser:    yes
```

## Build docker image

```bash
$ docker build -t ocserv https://github.com/blackgiulia/docker-ocserv.git
```

## Run docker container

```bash
$ docker run --name ocserv --privileged -p 443:443 -p 443:443/udp -d ocserv
```

### Add user

```bash
$ docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd <username>
$ Enter password:
$ Re-enter password:
```

### Delete user

```bash
$ docker exec -ti ocserv ocpasswd -c /etc/ocserv/ocpasswd -d <username>
```
