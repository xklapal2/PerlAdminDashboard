#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments provided. Please provide a command."
    exit 1
fi

app="bin/app.psgi"
dbname="database/AdminDashboard.db"
dbsql="database/database.sql"

# Handle different commands
case "$1" in
    db)
        sqlscript=$2
        if [ -z "$2" ]; then
            echo "Opening database $dbname... [run: '.exit' to exit sqlite>]"
            sqlite3 "$dbname"
        else
            if [[ "$sqlscript" != *";" ]]; then
                sqlscript="${sqlscript};"  # Append a semicolon if it does not end with one
                echo "Updated database name to: $sqlscript"
            fi
            sqlite3 "$dbname" <<EOF
$sqlscript
EOF
        fi
        ;;
    dropdb)
        # Check if Database file exists
        if [ ! -f $dbname ]; then
            echo "Error: $dbname not found!"
            exit 1
        fi

        rm $dbname

        if [ $? -eq 0 ]; then
            echo "$dbname successfully removed!"
        else
            echo "Error: Failed to remove $dbname."
        fi
        ;;
    setdb)
         # Check if script exists
        if [ ! -f $dbsql ]; then
            echo "Error: $dbsql not found!"
            exit 1
        fi

        sqlite3 "$dbname" < $dbsql # Run the SQL script using sqlite3
        echo "Following tables created: "
        sqlite3 "$dbname" <<EOF
SELECT name FROM sqlite_master WHERE type='table';
EOF

        if [ $? -eq 0 ]; then
            echo "Database $dbname has been set up successfully."
        else
            echo "Failed to set up database $dbname."
        fi
        ;;
    app)
        echo "Running application $app..."
        DANCER_ENVIRONMENT=development plackup -s Twiggy -r $app
        ;;
    mail)
        # Load username and password from the YAML file
        yamlFile="environments/development.yml"
        tmpMailFile="tmpMail.email"

        smtpServer="smtp.fastmail.com"
        username=$(yq -r '.email.username' $yamlFile)
        password=$(yq -r '.email.password' $yamlFile)

        to=$username
        emailAddresses=(
            "alice@example.com"
            "bob@test.com"
            "charlie@random.com"
            "dave@fastmail.com"
            "eve@mail.com"
            "frank@example.com"
            "grace@test.com"
            "hank@random.com"
            "ivy@fastmail.com"
            "jack@mail.com"
        )

        # pick a random email address as the from address
        from="${emailAddresses[RANDOM % ${#emailAddresses[@]}]}"

        subject=$(curl -s https://catfact.ninja/fact?max_length=100)
        subject=$(echo "$subject" | jq -r '.fact')

        body=$(curl -s https://catfact.ninja/fact?max_length=500)
        body=$(echo "$body" | jq -r '.fact')

        {
            echo "From: $from <$from>"
            echo "To: <$to>"
            echo "Subject: $subject"
            echo "Content-Type: text/plain; charset=\"utf-8\""
            echo
            echo "$body"
        } > $tmpMailFile

        cat $tmpMailFile

        # Send email using curl
        curl --url "smtps://$smtpServer:465" \
            -v \
            --ssl-reqd \
            --mail-from $from \
            --mail-rcpt "$to" \
            --user "$username:$password" \
            -T $tmpMailFile

        rm $tmpMailFile
    ;;
    client)
    perl bin/ResourceMonitoringClient.pl
    ;;
    clientWin)
    perl bin/ResourceMonitoringClientWin.pl
    ;;
    *)
        echo "Invalid command. Available commands: db, dropdb, setdb, app, mail"
        exit 1
        ;;
esac