#!/usr/bin/python3

import sys

if len(sys.argv) != 2:
    print("usage: create_csv_file.py <file.csv>")
    exit(1)

file = open(sys.argv[1],"w")

print("The format of the csv entries is:\nHost,username,IP,user pass,root pass")
print("when you enter an empty hostname the creation will stop")
final_form = ""
i = 1

while True:
    while True:
        print(f"Host nb {i}: ",end="")
        host = input()
        if host == "":
            break
        print("username: ",end="")
        username = input()
        print("IP: ",end="")
        IP = input()
        print("user pass: ",end="")
        user_pass = input()
        print("root pass: ",end="")
        root_pass = input()
        ent = f"{host},{username},{IP},{user_pass},{root_pass}"
        final_form = final_form + ent + "\n"
        i += 1
    print("are you satisfied with the following form:")
    print(final_form)
    print("(y/N): ",end="")
    choice = input()
    if choice == "y" or choice == "Y":
        break
    else:
        i = 1
        final_form = ""

file.write(final_form)
file.close()
