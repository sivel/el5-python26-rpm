FROM centos:5

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm"

COPY ./yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo
COPY ./yum.repos.d/CentOS-Sources.repo /etc/yum.repos.d/CentOS-Sources.repo
COPY ./yum.repos.d/CentOS-fasttrack.repo /etc/yum.repos.d/CentOS-fasttrack.repo
COPY ./yum.repos.d/libselinux.repo /etc/yum.repos.d/libselinux.repo

COPY ./patches /usr/src/redhat/SOURCES/
COPY ./spec_diffs /usr/src/redhat/SPECS

RUN yum -y update && \
    yum install -y wget  && \
    wget -q http://archives.fedoraproject.org/pub/archive/epel/RPM-GPG-KEY-EPEL-5  && \
    wget -q http://archives.fedoraproject.org/pub/archive/epel/5/x86_64/epel-release-5-4.noarch.rpm  && \
    rpm --import RPM-GPG-KEY-EPEL-5  && \
    rpm -Uvh epel-release-5-4.noarch.rpm

RUN yum install openssl1  && \
    yum update -y --exclude=openssl  && \
    yum install -y python26 python26-devel which

RUN yum install -y redhat-rpm-config rpm-build gcc gcc-c++ make yum-utils mock python26-pycurl rpmdevtools && \
    useradd -s /sbin/nologin mockbuild

RUN mkdir -p /rpm && \
    yumdownloader --urls --source \
        rpm \
        yum \
        python-urlgrabber \
        python-iniparse \
        python-sqlite \
        yum-metadata-parser \
        libselinux && \
    yumdownloader --source --destdir /rpm \
    rpm \
    yum \
    python-urlgrabber \
    python-iniparse \
    python-sqlite \
    yum-metadata-parser \
    libselinux

WORKDIR /rpm

RUN yum-builddep -y /rpm/*.src.rpm

RUN mkdir -p /usr/src/redhat && \
    rpm -ivh /rpm/*.rpm

WORKDIR /usr/src/redhat/SPECS

RUN spectool -g -R /usr/src/redhat/SPECS/python-urlgrabber.spec && \
    rpmbuild -bb rpm.spec && \
    rpmbuild -bb python-urlgrabber.spec && \
    rpmbuild -bb python-iniparse.spec && \
    rpmbuild -bb python-sqlite.spec && \
    rpmbuild -bb yum-metadata-parser.spec && \
    rpmbuild -bb yum.spec && \
    rpmbuild -bb libselinux.spec

RUN mkdir -p /rpms && \
    cp /usr/src/redhat/RPMS/x86_64/*.rpm /rpms && \
    cp /usr/src/redhat/RPMS/noarch/*.rpm /rpms && \
    rm -rf /rpms/*debuginfo*


