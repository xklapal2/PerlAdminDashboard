
[TOC]

# PerlAdminDashboard

A web application built in Perl using the Dancer2 micro-framework. The goal is to create a simple helpdesk for sysadmins and a dashboard for monitoring system resources.

The web app includes several functionalities:

1. **Authentication** - Users can access the application only after authentication.
2. **HelpDesk**
   - The main application provides an overview of requests that users can manage.
   - Requests are generated by reading emails from an inbox.
   - Request statuses include **New**, **In Progress**, and **Completed**.
3. **SystemMonitor**
   - The main application provides an overview of **monitored devices** and their resource usage, such as RAM usage, CPU, disk, network, power state (on/off), etc.
   - A new script will be created to run on each **monitored device**, sending continuous status updates about the device.
4. **PasswordGenerator**
   - A parameterized tool for generating passwords.
   - Parameters include: password length, inclusion of special characters, numbers, uppercase, and lowercase letters.

## Tech-Stack

- Backend

  - Language: **Perl v5.36.0**

  - Framework: [Dancer2](https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Tutorial.pod): A simple web micro-framework for Perl.

    - Plugins:
      - Database:
        - **[Dancer2::Plugin::Database](https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Tutorial.pod#Configuring-plugins)**: A plugin for easily connecting to databases, implementing the general **[DBI](https://metacpan.org/pod/DBI)**;
        - **DBD::SQLite**: A driver for working with SQLite.
      - Additional plugins will be used as needed for password hashing, email handling, gathering system resource data, HTTP client functions, etc.

- Database

  - [SQLite](https://www.sqlite.org/)

- Frontend

  - **HTML**, **JavaScript**, [**Tailwind**](https://tailwindcss.com/) (**CSS**)


## Prerequisites:

1. Install `Perl`
1. Install `Perl module manager`

   ```bash
   sudo apt install cpanminus
   ```
1. Install `Dancer2` micro-framework

   ```bash
   sudo cpanm Dancer2
   ```
1. Install [hashing module](https://metacpan.org/pod/Crypt::Argon2)

   ```bash
   sudo cpanm Crypt::Argon2
   ```
1. Install database `SQL Lite`

   ```bash
   sudo apt install sqlite3
   sqlite3 dashboard.db
   ```
1. Install database plugins `Dancer2::Plugin::Database`, `DBI`, `DBD::SQLite`

   ```bash
   sudo cpanm Dancer2::Plugin::Database DBI DBD::SQLite
   ```
1. 

## App modules

### 1 Application

1. Setup basic app with home endpoint on route '/'.

2. Create View for default route.

   - Views or `templates` are located in `view` folder.

3. Run application.

   ```bash
   plackup app.psgi
   
   HTTP::Server::PSGI: Accepting connections at http://0:5000/
   127.0.0.1 - - [19/Oct/2024:14:26:52 +0200] "GET / HTTP/1.1" 200 23 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
   ```

4. Automatic reloads on file save using `-r`.

   ```bash
   plackup app.psgi -r
   ```

5. Throw reasonable-looking errors to the user instead of crashing the application.

   - Set `show_stacktrace` in `app.psgi`

     ```perl
     set show_stacktrace => $ENV{DANCER_ENVIRONMENT};
     ```

   - Set environment on application start using

     ```bash
     DANCER_ENVIRONMENT=1 plackup app.psgi -r
     ```

6. 

### 2 Authentication

#### 2.1 [Creating First Standalone Module](https://www.geeksforgeeks.org/perl-modules/)

1. The module file is named `PasswordHasher` with the extension `.pm` (e.g., `PasswordHasher.pm`).

2. The module's first line contains the **package declaration** (`package services::crypto::PasswordHasher;`), and the package name should match the file name (without the `.pm` extension).

   - Package name mus follow folder structure.

   ```bash
   .
   ├── app.psgi
   ├── Services
   │   └── Crypto
   │   │   └── PasswordHasher.pm
   └── views
       └── index.tt
   ```

3. A package must always return a **true** value to indicate it was loaded successfully. Typically, this is done by returning `1` at the end of the file.

##### Exporting, Including and aliases

1. Export module subroutines

   ```perl
   use Exporter 'import'; # Import the Exporter module
   our @EXPORT_OK = qw(hashPassword verifyPassword); # Functions to export
   
   sub hashPassword {
       # feature implementation
   }
   
   sub verifyPassword {
       # feature implementation
   }
   
   1;
   ```

2. Including is done using `use` keyword and **namespace** follows `use Services::Crypto::PassworHasher;`.

   ```perl
   # option1
   use lib '.'; # since module is not located in default @NIC path then it's required to specify path
   use Services::Crypto::PasswordHasher;
   
   my $password = "password";
   my $hash = Services::Crypto::PasswordHasher::hashPassword($password);
   print "Hashed Password: $hash\n";
   
   # OR Option2
   use lib '.';
   use Services::Crypto::PasswordHasher qw/hashPassword verifyPassword/; # import methods
   
   my $hash = hashPassword($password);
   ```

