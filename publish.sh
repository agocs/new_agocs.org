#! /bin/bash

rsync -r --del public/ root@agocs.org:/var/www/agocs.org
