#!/bin/bash

#User Management Script

show_menu() {
   clear
   echo "User Manager"
   echo "1.create user"
   echo "2.delete user"
   echo "3.list users"
   echo "4.change password"
   echo"5.user info"
   echo"6.add to group"
   echo "7.Exit"
   echo -n "choice [1-7]:"
}

create_User(){
    read -p "Username: " user
    if id "$user" &>/dev/null; then
        echo "Error: User  exists!"
        return
    fi


    read -p "Full name: " name
    read -sp "Password: " pass
    echo

    useradd -m -c "$name" "$user" 2>/dev/null && echo "$user:$pass" | chpasswd
    }

delete_user(){
     read -p "Username to delete: " user
     if ! id "$user" &>/dev/null; then
         echo "Error: User not found!"
         return
      fi

     read -p "Delete home? (y/n): " delhome
     if [ "$delhome" = "y" ]; then
          userdel -r "$user" && echo "User deleted with home!"
     else
          userdel "$user" && echo "User deleted!"
     fi
}
list_users(){
    echo  "All Users"
    cut -d: -f1,3 /etc/passwd | sort -t: -k2 -n | sed 's/:/ - UID: /'
    echo -e "\nLogged In"
    who
}

change_pass() {
    read -p "Username: " user
    if ! id "$user" &>/dev/null; then
        echo "Error: User not found!"
        return
    fi
     passwd "$user"
}

user_info() {
    read -p "Username: " user
    if ! id "$user" &>/dev/null; then
        echo "Error: User not found!"
        return
    fi

    echo " $user"
    echo "UID: $(id -u $user)"
    echo "GID: $(id -g $user)"
    echo "Groups: $(id -Gn $user)"
    echo "Shell: $(getent passwd $user | cut -d: -f7)"
}

add_group() {
    read -p "Username: " user
    if ! id "$user" &>/dev/null; then
        echo "Error: User not found!"
        return
    fi

    read -p "Group: " group
    if ! getent group "$group" &>/dev/null; then
        read -p "Group doesn't exist. Create? (y/n): " create
        [ "$create" = "y" ] && groupadd "$group" || return
    fi

    usermod -aG "$group" "$user" && echo "Added to group!"
    }

while true; do
    show_menu
    read choice

    case $choice in
        1) create_user ;;
        2) delete_user ;;
        3) list_users ;;
        4) change_pass ;;
        5) user_info ;;
        6) add_group ;;
        7) echo "Bye!"; exit ;;
        *) echo "Invalid!" ;;
    esac
    read -p "Press Enter..."
done
