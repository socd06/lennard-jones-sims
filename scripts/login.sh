#!/bin/bash

# sshpass -p pa$$word ssh user@host

export my_password="FIrO/fZ3]"

export user="test@148.247.198.140"

ssh -p 26 $user

expect "$user's password:"

send "$my_password"
