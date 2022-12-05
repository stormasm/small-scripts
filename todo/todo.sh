#!/bin/bash

### Setup ###
# Check if $TODO_CONF is exported globally; if not use default
CONF=${TODO_CONF:-"$HOME/.config/todo/todo.conf"}
# echo "Config file located at $CONF"
source $CONF


# Database setup
DBPATH=${DBPATH:-"$HOME/.local/share/todo/todo.db"}
TABLENAME=${TABLENAME:-"items"}
ERROR_LOG=${ERROR_LOG:-"$HOME/.local/share/todo/todo.log"}
if [ ! -f "$DBPATH" ]; then
    echo "Database does not exist in $DBPATH, creating new..."
    DBDIR=$(dirname $DBPATH)
    mkdir -p $DBDIR
    touch $DBPATH
fi

# Create table
create_table () {
    sqlite3 $DBPATH "CREATE TABLE items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entry TEXT,
        priority INTEGER,
        duedate DATETIME,
        status TEXT);" 2>> $ERROR_LOG
    # TODO: fix for bash later
    # if [ $((?)) != 0 ]; then
    #     echo "Error creating database. For more info check $ERROR_LOG"
    # else
        echo "'$TABLENAME' table created"
    # fi
}
[[ $(sqlite3 $DBPATH ".tables $TABLENAME") = "" ]] && create_table

# Default status to show
show_status="IN-PROGRESS"

# Priority: 0 - 2 (highest -> lowest)
declare -A priorities 
priorities["LOW"]=2
priorities["MEDIUM"]=1
priorities["HIGH"]=0
priorities_args=$(echo ${!priorities[@]} | awk '{ for (i = 1; i < NF + 1; i++) print $i }')

# Status: 'IN-PROGRESS', 'COMPLETED', 'CANCELED'
declare -A statuses 
statuses["IN-PROGRESS"]=2
statuses["COMPLETED"]=1
statuses["CANCELED"]=0
statuses_args=$(echo ${!statuses[@]} | awk '{ for (i = 1; i < NF + 1; i++) print $i }')

# Given no arguments, all todo items are printed
query () {
    print_num=$1
    status=$2
    if [ "$status" = "" ]; then
        sqlite3 "$DBPATH" "
            SELECT id, entry, priority, duedate, status FROM $TABLENAME 
                ORDER BY duedate, priority 
                LIMIT $print_num" | 
            column -t -s "|" -o " | " -N "Index,TODO Message,Priority,Due Date,Status"
    else
        sqlite3 "$DBPATH" "
            SELECT id, entry, priority, duedate, status FROM $TABLENAME 
                WHERE status = '$status'
                ORDER BY duedate, priority 
                LIMIT $print_num" | 
            column -t -s "|" -o " | " -N "Index,TODO Message,Priority,Due Date,Status"
    fi
}

insert () {
    entry=$(rofi -show -dmenu -i -p "Enter TODO item")

    priority=$(echo -e "$priorities_args" | 
        rofi -show -dmenu -i -p "Enter priority")

    # Options for dates
    dates="$(date +%Y-%m-%d)"
    for i in {1..30}; do
        newdate=$(date +%Y-%m-%d --date="$i days")
        dates="$dates\n$newdate"
    done
    duedate=$(echo -e $dates | 
        rofi -show -dmenu -i -p "Choose due dat (or enter other '%Y-%m-%d')")

    sqlite3 "$DBPATH" "
        INSERT INTO $TABLENAME VALUES (
        NULL, '$entry', ${priorities[$priority]}, '$duedate', 'IN-PROGRESS'
    )
        "
    main_menu
}

show () {
    declare -A show_statuses
    show_statuses["IN-PROGRESS"]="IN-PROGRESS"
    show_statuses["COMPLETED"]="COMPLETED"
    show_statuses["CANCELED"]="CANCELED"
    show_statuses["ANY"]=""
    show_statuses_args=$(echo ${!show_statuses[@]} | awk '{ for (i = 1; i < NF + 1; i++) print $i }')

    chosen_show_status=$(echo -e "$show_statuses_args" | 
        rofi -show -dmenu -i -p "Enter show_statuses")
    show_status="${show_statuses[$chosen_show_status]}"
    main_menu
}

change_status () {
    rows=$(query 100 "$status")
    chosen_id=$(echo -e "$rows" | rofi -show -dmenu -i -p "Pick item" | awk '{print $1}')
    echo $chosen_id
    row=$(sqlite3 "$DBPATH" "
        SELECT entry, priority, duedate FROM $TABLENAME 
            WHERE id = $chosen_id
            ") 
    values="'${row//|/\',\'}'"
    
    new_status=$(echo -e "$statuses_args" | rofi -show -dmenu -i)
    sqlite3 "$DBPATH" "
        INSERT OR REPLACE INTO $TABLENAME 
            (id, entry, priority, duedate, status)
            VALUES ($chosen_id, $values, '$new_status')
    "

    main_menu
}

# not implemented yet
delete () {
    echo "delete"
    exit 0
}

exit_rofi () {
    exit 0
}

main_menu() {
    declare -A rofi_options 
    rofi_options["Insert"]="insert"
    rofi_options["Change-status"]="change_status"
    rofi_options["Delete"]="delete"
    rofi_options["Shown-status"]="show"
    rofi_options["Exit"]="exit_rofi"

    args=$(echo ${!rofi_options[@]} | awk '{ for (i = 1; i < NF + 1; i++) print $i }')
    output=$(query 10 $show_status)
    input="$args\n------------------------------------\n$output"
    chosen=$(echo -e "$input" | rofi -dmenu -i -show -p "Choose option")
    ${rofi_options[$chosen]}
}

main_menu
