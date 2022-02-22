# **auto-ssl**


# TABLE OF CONTENTS
1. [About](https://github.com/ryanc410/auto-ssl/edit/main/README.md#about)
2. [Usage](https://github.com/ryanc410/auto-ssl/edit/main/README.md#usage)
3. [How it Works](https://github.com/ryanc410/auto-ssl/edit/main/README.md#how-it-works)
4. [Issues](https://github.com/ryanc410/auto-ssl/edit/main/README.md#issues)
5. [Contributing](https://github.com/ryanc410/auto-ssl/edit/main/README.md#contributing)
6. [Contact](https://github.com/ryanc410/auto-ssl/edit/main/README.md#contact)
7. [Sources](https://github.com/ryanc410/auto-ssl/edit/main/README.md#sources)


# ABOUT
This script was written in BASH and was tested on Ubuntu Server 20.04. It automatically runs certbot and configures your Domain with a Lets Encrypt SSL Certificate.


# USAGE
1. Before using this script you should already have a Domain setup through the Apache Web Server.
2. Clone the Repository
````bash
git clone https://github.com/ryanc410/auto-ssl.git
````
3. Make the script executable
````bash
cd auto-ssl
chmod +x auto-ssl.sh
````
4. Run Script
````bash
sudo ./auto-ssl.sh
````
5. DONE! Your Domain is now secured with Lets Encrypt and it was easy as one command.


# HOW IT WORKS
1. Checks to make sure the Apache Web Server is installed and Listening on Port 80.
2. The user enters the Domain they wish to secure. (example.com)
3. The entered Domain name is tested using the host command to make sure it is in fact a valid domain.
4. Apache modules ssl, headers and http2 are enabled.
5. Installs certbot.
6. Generates Diffie Helman certificate.
7. A directory is created to hold the validation file needed from Lets Encrypt.
8. An alias is configured that points to the directory previously created.
9. ssl-params.conf file is created to enable SSL Stapling, the Strict Transport Security header and to specify the ciphers that are allowed.
10. Certbot command runs to request the certificate from Lets Encrypt.
11. If the certbot command is successful, a new virtual host file is generated to configure the SSL options for the Domain.
12. Virtual Host is enabled, Apache is reloaded and the script is finished. A full log can be found in the directory the script was executed at apache_auto_ssl.log

# ISSUES
If you find and errors you can create an issue [here](https://github.com/ryanc410/auto-ssl/issues).

# CONTRIBUTING
Everything I have learned has been through trial and error, as well as countless hours of searching throught forums and e-books. I am always open to criticism, especially if it will help me, or someone else reading this to improve on their skills. 

# CONTACT


# SOURCES
This script is based upon the tutorial that I used many many times and I thought was the best one out there. Here is the link to it [Secure Apache with Lets Encrypt on Ubuntu 20.04](https://linuxize.com/post/secure-apache-with-let-s-encrypt-on-ubuntu-20-04/). I couldnt find the author's name but it was posted on July 8, 2020.
