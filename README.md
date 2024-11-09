
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

  - **HTML**, **JavaScript**, [**Bootstrap**](https://getbootstrap.com/) (**CSS**)


## Prerequisites:


```bash
# install curl
sudo apt install curl

# install perl
sudo curl -L http://xrl.us/installperlnix | bash

# install sql lite
sudo apt install sqlite3

# Web Framework
cpan isntall Dancer2
# requires
cpan install DBI DBD::SQLite Dancer2::Plugin::Database Crypt::Argon2 MIME::Base64 Crypt::URandom Mail::IMAPClient IO::Socket::SSL MIME::Parser DateTime DateTime::Format::Strptime DateTime::Format::ISO8601 HTML::Escape Time::Piece Sys::Statistics::Linux Proc::ProcessTable JSON LWP::UserAgent Plack::App::WebSocket AnyEvent::WebSocket::Client
# recomends
cpan install YAML URL::Encode::XS CGI::Deurl::XS CBOR::XS YAML::XS Class::XSAccessor HTTP::XSCookies HTTP::XSHeaders Math::Random::ISAAC::XS MooX::TypeTiny Type::Tiny::XS Unicode::UTF8cpan install DBI DBD::SQLite Dancer2::Plugin::Database Crypt::Argon2 MIME::Base64 Crypt::URandom Mail::IMAPClient IO::Socket::SSL MIME::Parser DateTime DateTime::Format::Strptime DateTime::Format::ISO8601 HTML::Escape Time::Piece Sys::Statistics::Linux Proc::ProcessTable JSON LWP::UserAgent Plack::App::WebSocket AnyEvent::WebSocket::Client
```


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
   sudo cpanm Crypt::Argon2 Crypt::URandom
   ```
1. Install database `SQL Lite`

   ```bash
   sudo apt install sqlite3
   ```
1. Install database plugins `Dancer2::Plugin::Database`, `DBI`, `DBD::SQLite`

   ```bash
   sudo cpanm Dancer2::Plugin::Database DBI DBD::SQLite
   ```
1. Install IMAP, SSL and Mime type modules

   ```bash
   sudo cpanm install Mail::IMAPClient IO::Socket::SSL MIME::Parser
   ```

1. Install `DateTime` and `DateTime format` modules

   ```bash
   sudo cpan DateTime DateTime::Format::Strptime
   ```

1. Další zácislosti jsou uvedené v `cpanfile`.

## Sources

During the course I followed [Perl docs](https://www.perl.org/docs.html), [MetaCPAN - Dancer2 docs](https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Manual.pod).  To better understand the Dancer2 application infrastructure, I also worked through the [CodeMaven - Dancer2 tutorial](https://slides.code-maven.com/dancer/dancer.html).

## App modules

### 1 Application

1. Create default template using CLI and `Dancer2`:

   ```bash
   dancer2 gen -a <AppName>
   
   # App structure is created:
   .
   ├── bin
   │   └── app.psgi # Application Entrypoint - startup file.
   ├── config.yml # Default configuration file.
   ├── cpanfile # This file is used to manage dependencies via CPAN.
   ├── environments # Environment specific files e.g. development/production.yml.
   ├── lib # Root directory of custom modules.
   │   └── Web.pm # Represents endpoints which are loaded using app.psgi.
   ├── Makefile.PL # This is a Perl module build file used to create a Makefile for your application.
   ├── MANIFEST # This file lists all the files that are part of the distribution.
   ├── MANIFEST.SKIP # This file specifies which files should be skipped when generating the MANIFEST. 
   ├── public # Static files which are accessible through HTTP for client
   │   ├── css
   │   ├── images
   │   └── javascripts
   ├── t #  This directory is for tests, which are essential for ensuring the application's functionality.
   │   ├── 001_base.t
   │   └── 002_index_route.t
   └── views # Frontend templates for data representation
       ├── index.tt
       └── layouts
           └── main.tt # A main layout template that other templates can extend.
   ```

2. Run application.

   ```bash
   plackup bin/app.psgi
   
   HTTP::Server::PSGI: Accepting connections at http://0:5000/
   127.0.0.1 - - [19/Oct/2024:14:26:52 +0200] "GET / HTTP/1.1" 200 23 "-" "Mozilla/5.0 (X11; Linux x86_64; rv:128.0) Gecko/20100101 Firefox/128.0"
   ```

3. Automatic reloads on file save using `-r`.

   ```bash
   plackup -r bin/app.psgi
   ```

4. Throw reasonable-looking errors to the user instead of crashing the application. **- It is moved to configuration file.**

   - Set `show_stacktrace` in `app.psgi`

     ```perl
     # configurations
     set show_stacktrace => $ENV{DANCER_ENVIRONMENT};
     ```

   - Set environment on application start using

     ```bash
     DANCER_ENVIRONMENT=1 plackup bin/app.psgi
     DANCER_ENVIRONMENT=1 plackup -r bin/app.psgi
     ```

5. Set log level in `app.psgi` **- It is moved to configuration file.**

   ```perl
   set log => 'warning'; # set logging level
   ```

6. [Set application configuration](https://metacpan.org/dist/Dancer2/view/lib/Dancer2/Config.pod).

   - Default configuration file is located in **app root** `src/config.yml`. This file contains **default values**.
   - Environment specific files are located in `src/environment/{env}.yml`. These contains **environment specific values**.
   - New run application command:

   ```bash
   DANCER_ENVIRONMENT=development plackup -r bin/app.psgi
   ```

7. 

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
   our @EXPORT_OK = ("hashPassword", "verifyPassword"); # Functions to export
   
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
   use Services::Crypto::PasswordHasher ('hashPassword', 'verifyPassword'); # import methods
   
   my $hash = hashPassword($password);
   ```

#### 2.2 Create SQLite database and `users` table with default `Inbuilt` account.

```sql
-- in cli run script 
sqlite3 AdminDashboard.db
SQLite version 3.40.1 2022-12-28 14:03:47
Enter ".help" for usage hints.

sqlite>  -- run SQL scripts from database.sql file
sqlite> .exit -- exit
```

# Perl Notes

## Perl - OOP

### Classes

#### $class

When creating an instance

```perl
   my $object = ClassName->new(%args);
```

the ClassName is passed as the first argument to the new method, which is captured by `$class`.

#### Bless

- Purpose: The `bless` function is used to turn a `plain Perl hash reference` (or any reference) into an `object` by associating it with a class.
- Explanation: The line `bless $self, $class;` takes the `hash reference $self` and associates it with the class named by `$class`. This allows `$self` to be treated as an `object of that class`, meaning you can call methods on it that are defined in the class.

### Access methods and calls

```perl
x->something: # For calling a method or accessing an attribute of an object.
x->{something}: # For accessing values in a hash reference.
x{'something'}: # For accessing values in a regular hash.
x[something]: # For accessing elements in an array or using an index with an array reference as x->[index].
```

### References

1. **Creating References**

   - Scalar Reference:

     ```perl
     my $scalar = 42;
     my $scalar_ref = \$scalar;  # Reference to a scalar
     ```

   - Array Reference:

     ```perl
     my @array = (1, 2, 3);
     my $array_ref = \@array;  # Reference to an array
     ```

   - Hash Reference:

     ```perl
     my %hash = (a => 1, b => 2);
     my $hash_ref = \%hash;  # Reference to a hash
     ```

   - Anonymous Array/Hash Reference:

     ```perl
     my $anon_array_ref = [4, 5, 6];  # Creates an array reference directly
     my $anon_hash_ref = {x => 10, y => 20};  # Creates a hash reference directly
     ```

2. **Dereferencing**

   - **Scalar Dereferencing:**

     ```perl
     print $$scalar_ref;  # Prints 42
     ```

   - **Array Dereferencing:**

     ```perl
     my @array = @{ $array_ref };  # Dereferences the array reference
     print $array_ref->[0];        # Prints the first element (1)
     ```

   - **Hash Dereferencing:**

     ```perl
     my %hash = %{ $hash_ref };  # Dereferences the hash reference
     print $hash_ref->{a};       # Prints the value for key 'a' (1)
     ```

   - **Accessing Elements:**

     ```perl
     print $anon_array_ref->[1];  # Prints the second element (5)
     print $anon_hash_ref->{y};   # Prints the value of 'y' (20)
     ```

3. References in Data Structures

   - **Array of References:**

     ```perl
     my @array_of_refs = (\@array, $anon_array_ref);
     print $array_of_refs[1]->[2];  # Prints the third element of the anonymous array (6)
     ```

   - **Hash of References:**

     ```perl
     my %hash_of_refs = (numbers => $anon_array_ref, letters => ['a', 'b', 'c']);
     print $hash_of_refs{numbers}->[0];  # Prints 4
     ```

4. Subroutine References

   - **Creating a Subroutine Reference:**

     ```perl
     my $sub_ref = sub {
         my ($x, $y) = @_;
         return $x + $y;
     };
     ```

   - **Calling a Subroutine Reference:**

     ```perl
     print $sub_ref->(3, 4);  # Prints 7
     ```

5. Complex Data Structures

   - **Array of Hashes:**

     ```perl
     my @array_of_hashes = (
         {name => 'Alice', age => 30},
         {name => 'Bob', age => 25}
     );
     print $array_of_hashes[1]->{name};  # Prints 'Bob'
     ```

   - **Hash of Arrays:**

     ```perl
     my %hash_of_arrays = (
         fruits => ['apple', 'banana', 'cherry'],
         vegetables => ['carrot', 'broccoli']
     );
     print $hash_of_arrays{fruits}->[2];  # Prints 'cherry'
     ```

6. Passing References to Subroutines

   - **Subroutine That Accepts References:**

     ```perl
     sub print_array_ref {
         my ($array_ref) = @_;
         foreach my $item (@{ $array_ref }) {
             print "$item\n";
         }
     }

     my @nums = (10, 20, 30);
     print_array_ref(\@nums);
     ```

7. **Common Use Cases**

   - **Creating Anonymous Data Structures:**

     ```perl
     my $complex_structure = [
         {name => 'John', scores => [90, 85, 78]},
         {name => 'Jane', scores => [88, 92, 81]}
     ];
     print $complex_structure->[1]->{scores}->[2];  # Prints 81
     ```

   - **Manipulating References:** You can modify elements directly through references:

     ```perl
     $array_ref->[1] = 99;  # Changes the second element of the array to 99
     $hash_ref->{b} = 42;   # Changes the value for key 'b' to 42
     ```
