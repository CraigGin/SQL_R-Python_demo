# SQL_R-Python_demo

This repository contains a demonstration of SQL basics for R or Python users. If you clone the repository and attempt to run the code, it will not work because the example database needs to be set up on your computer. You can however, see the code and what the output was.

If you would like to try to use the code, you can create the example database on your own. The following are the steps I took to create it.

## 1. Download and install MySQL

I downloaded and installed MySQL for macOS by following the instructions [here](https://dev.mysql.com/doc/refman/8.0/en/macos-installation-pkg.html). The default path to the MySQL server on Mac is  `/usr/local/mysql/bin/`. You can run mysql from the Terminal using the command 

`/usr/local/mysql/bin/mysql`

In order to shorten this, you can either add `/usr/local/mysql/bin/` to your PATH or create an alias in your .bash_profile or .zshrc file using

`alias mysql="/usr/local/mysql/bin/mysql"`

This allows you to call mysql using just `mysql`.

## 2. Create a database

In order to create a database, you first need to log in to the local server with the root account. You can do this in the Terminal by typing

`mysql -u root -p`

and entering the password you used during installation. Then you can create the example database, called gutMB, using the command

`CREATE DATABASE gutMB;`

 If you would like, you can create a new user for the server with the command

`CREATE USER 'username'@'localhost' IDENTIFIED BY 'password'`;

In the R and Python examples included in the repository, I used the username `crgin` and the password `insecure`. To grant permission for the user to use the databases on the server, use the command

`GRANT ALL ON *.* TO 'username'@'localhost';`

## 3. Add tables to database

We will add 3 tables to the gutMB database by uploading data frames from R. In order to give permission to upload local files, you can run the command

`SET GLOBAL local_infile = true;`

Then you can run the R script `add_tables.R` that is in this repository. Before running, you will need to set the username and password at the top of the script. They should match what you set up in the previous step. If you would like to confirm that the tables have been added, you can type

`USE gutMB;`

to make the gutMB database active and then type

`SHOW TABLES;`

which should display three tables named abundance_table, meta_data, and tax_table.

You should now be able to run the R and Python code that is provided. You will just need to change the username and password used to connect to the server.

