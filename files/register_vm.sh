#!/bin/bash

curl --insecure --output katello-ca-consumer-latest.noarch.rpm https://sys-caps6-01.srv.mont.lab/pub/katello-ca-consumer-latest.noarch.rpm
yum localinstall katello-ca-consumer-latest.noarch.rpm -y
subscription-manager register --org="MONT" --activationkey="Key8_A,Key8_B"