#!/bin/bash

# Obtener prefijo de idioma / Get language prefix
lang_prefix="${LANG:0:2}"

# Función para verificar el idioma y mostrar el mensaje correspondiente / Function for verifying the language and displaying the corresponding message
get_language_message() {
    if [[ $lang_prefix -eq "es" ]]; then
        echo -e "$1"
    else
        echo -e "$2"
    fi
}

# Comprueba si el usuario es root / Check if the user is root
if [ "$EUID" -ne 0 ]; then
    error_message=$(get_language_message "\e[91mThis script must be run by the root user.\e[0m" "\e[91mEste script debe ejecutarse como usuario root.\e[0m")
    echo -e "$error_message"
    exit 1
fi
# Función para centrar texto en una línea de longitud específica / Function for centering text on a line of specified length
center_text() {
    local text="$1"
    local line_length="$2"
    local text_length=${#text}
    local padding_before=$(( (line_length - text_length) / 2 ))
    local padding_after=$(( line_length - text_length - padding_before ))
    
    printf "%s%-${padding_before}s%s%-*s%s\n" "║" " " "$text" "$padding_after" " " "║"
}
# Longitud deseada para la línea / Desired line length
line_length=60
# Arte ASCII / ASCII Art
echo -e "\033[96m\033[1m
                  ██████╗ ██╗   ██╗██╗    ██╗ █████╗                    
                  ██╔══██╗██║   ██║██║    ██║██╔══██╗                   
                  ██║  ██║██║   ██║██║ █╗ ██║███████║                   
                  ██║  ██║╚██╗ ██╔╝██║███╗██║██╔══██║                   
                  ██████╔╝ ╚████╔╝ ╚███╔███╔╝██║  ██║                   
                  ╚═════╝   ╚═══╝   ╚══╝╚══╝ ╚═╝  ╚═╝                   
                                                                        
  ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
  ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
  ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
  ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
  ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
  ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝     
\033[0m"
echo
echo -e "\033[92m╓────────────────────────────────────────────────────────────╖"
center_text "$(get_language_message "Welcome to the DVWA setup!" "¡Bienvenido al instalador de DVWA!")" "$line_length"
center_text "$(get_language_message "Script Name: Install-DVWA.sh " "Nombre del Script: Install-DVWA.sh ")" "$line_length"
center_text "$(get_language_message "Author: IamCarron " "Autor: IamCarron ")" "$line_length"
center_text "$(get_language_message "Github Repo: https://github.com/IamCarron/DVWA-Script" "GitHub Repo: https://github.com/IamCarron/DVWA-Script")" "$line_length"
center_text "$(get_language_message "Installer Version: 1.0.4 " "Versión del Instalador: 1.0.4 ")" "$line_length"
echo -e "╙────────────────────────────────────────────────────────────╜\033[0m"
echo
# Función para verificar la existencia de un programa / Function to verify the existence of a program
check_program() {
    if ! dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"; then
        message=$(get_language_message "\033[91m$1 is not installed. Installing it now...\e[0m" "\033[91m$1 no está instalado. Instalándolo ahora...\e[0m")
        echo -e >&2 "$message"
        apt install -y "$1"
    else
        success_message=$(get_language_message "\033[92m$1 is installed!\033[0m" "\033[92m$1 !Está instalado!\033[0m")
        echo -e "$success_message"
    fi
}

run_sql_commands() {
    local sql_user
    local sql_password

    while true; do
        echo -e "\n$(get_language_message "\e[96mDefault credentials:\e[0m" "\e[96mCredenciales por defecto:\e[0m")"
        echo -e "Username: \033[93mroot\033[0m"
        echo -e "\n$(get_language_message "Password: \033[93m[No password just hit Enter]\033[0m" "Password: \033[93m[Sin contraseña solo presiona Enter.]\033[0m")"
        read -p "$(get_language_message "\e[96mEnter SQL user:\e[0m " "\e[96mIngrese el usuario de SQL:\e[0m ")" sql_user
        read -s -p "$(get_language_message "\e[96mEnter SQL password (press Enter for no password):\e[96m " "\e[96mIngrese la contraseña de SQL (presiona Enter si no hay contraseña):\e[0m ")" sql_password
        echo
        # Verificar si las credenciales son válidas antes de ejecutar comandos SQL / Verify if credentials are valid before executing SQL commands
        if ! mysql -u "$sql_user" -p"$sql_password" -e ";" &>/dev/null; then
            echo -e "\n$(get_language_message "\e[91mError: Invalid SQL credentials. Please check your username and password. If you are traying to use root user and blank password make sure that you are running the script as root user.\e[0m" "\e[91mError: Credenciales SQL inválidas. Por favor, compruebe su nombre de usuario y contraseña. Si usted estas intentando de utilizar el usuario root y la contraseña en blanco asegúrate de que estas ejecutando el script como usuario root.")"
        else
            break
        fi
    done

    local success=false
    while [ "$success" != true ]; do
        # Ejecutar comandos SQL / Execute SQL commands
        sql_commands_output=$(sql_commands "$sql_user" "$sql_password")

        if [ $? -eq 0 ]; then
            echo -e "$(get_language_message "\033[92mSQL commands executed successfully.\033[0m" "\033[92mComandos SQL ejecutados con éxito.\033[0m")"
            success=true
        else
            if [ "$recreate_choice" != "no" ]; then
                break
            fi
        fi
    done
}

sql_commands() {
    local sql_user="$1"
    local sql_password="$2"
    local sql_command="mysql -u$sql_user"

    if [ -n "$sql_password" ]; then
        sql_command+=" -p$sql_password"
    fi

    # Verificar si la base de datos ya existe
    if ! $sql_command -e "CREATE DATABASE IF NOT EXISTS dvwa;"; then
        echo -e "$(get_language_message "\033[91mAn error occurred while creating the DVWA database." "\033[91mSe ha producido un error al crear la base de datos DVWA.")"
        return 1
    fi

    # Verificar si el usuario ya existe
    if ! $sql_command -e "CREATE USER IF NOT EXISTS 'dvwa'@'localhost' IDENTIFIED BY 'p@ssw0rd';"; then
        echo -e "$(get_language_message "\033[91mAn error occurred while creating the DVWA user." "\033[91mSe ha producido un error al crear el usuario DVWA.")"
        return 1
    fi

    # Asignar privilegios al usuario
    if ! $sql_command -e "GRANT ALL PRIVILEGES ON dvwa.* TO 'dvwa'@'localhost'; FLUSH PRIVILEGES;"; then
        echo -e "$(get_language_message "\033[91mAn error occurred while granting privileges." "\033[91mSe ha producido un error al otorgar privilegios.")"
        return 1
    fi

    echo 0
}

# Inicio del instalador / Installer startup

# Actualizar los repositorios / Update repositories
update_message=$(get_language_message "\e[96mUpdating repositories...\e[0m" "\e[96mActualizando repositorios...\e[0m")
echo -e "$update_message"
apt update

# Comprueba si las dependencias están instaladas / Check if the dependencies are installed
dependencies_message=$(get_language_message "\e[96mVerifying and installing necessary dependencies...\e[0m" "\e[96mVerificando e instalando dependencias necesarias...\e[0m")
echo -e "$dependencies_message"

check_program apache2
check_program mariadb-server
check_program mariadb-client
check_program php
check_program php-mysql
check_program php-gd
check_program libapache2-mod-php
check_program git

# Descargar el repositorio DVWA desde GitHub / Download DVWA repository from GitHub

# Comprobando si la carpeta ya existe / Checking if the folder already exists
if [ -d "/var/www/html/DVWA" ]; then
    # La carpeta ya existe / The folder already exists
    warning_message=$(get_language_message "\e[91mAttention! The DVWA folder is already created.\e[0m" "es" "\e[91m¡Atención! La carpeta DVWA ya está creada.\e[0m")
    echo -e "$warning_message"

    # Preguntar al usuario qué acción tomar / Ask the user what action to take
    read -p "$(get_language_message "\e[96mDo you want to delete the existing folder and download it again (y/n):\e[0m " "\e[96m¿Desea borrar la carpeta existente y descargarla de nuevo? (s/n):\e[0m ")" user_response

    if [[ "$user_response" == "s" || "$user_response" == "y" ]]; then
        # Borrar la carpeta existente / Delete existing folder
        rm -rf /var/www/html/DVWA

        # Descargar DVWA desde GitHub / Download DVWA from GitHub
        download_message=$(get_language_message "\e[96mDownloading DVWA from GitHub...\e[0m" "\e[96mDescargando DVWA desde GitHub...\e[0m")
        echo -e "$download_message"
        git clone https://github.com/digininja/DVWA.git /var/www/html/DVWA
        sleep 2
    elif [ "$user_response" == "n" ]; then
        # El usuario elige no descargar / User chooses not to download
        no_download_message=$(get_language_message "\e[96mContinuing without downloading DVWA.\e[0m" "\e[96mContinuando sin descargar DVWA.\e[0m")
        echo -e "$no_download_message"
    else
        # Respuesta inválida / Invalid answer
        invalid_message=$(get_language_message "\e[91mError! Invalid response. Exiting the script.\e[0m" "\e[91m¡Error! Respuesta no válida. Saliendo del script.\e[0m")
        echo -e "$invalid_message"
        exit 1
    fi
else
    # La carpeta no existe, descargar DVWA desde GitHub / Folder does not exist, download DVWA from GitHub
    download_message=$(get_language_message "\e[96mDownloading DVWA from GitHub...\e[0m" "\e[96mDescargando DVWA desde GitHub...\e[0m")
    echo -e "$download_message"
    git clone https://github.com/digininja/DVWA.git /var/www/html/DVWA
    sleep 2
fi
# Verificar si MariaDB ya está habilitado / Check if MariaDB is already enabled
if systemctl is-enabled mariadb.service &>/dev/null; then
    mariadb_already_enabled_message=$(get_language_message "\033[92mMariaDB service is already enabled.\033[0m" "\033[92mEl servicio MariaDB ya está en habilitado.\033[0m")
    echo -e "$mariadb_already_enabled_message"
else
    # Habilita Apache / Habilita Apache
    mariadb_enable_message=$(get_language_message "\e[96mEnabling MariaDB...\e[0m" "\e[96mHabilitando MariaDB...\e[0m")
    echo -e "$mariadb_enable_message"
    systemctl enable mariadb.service &>/dev/null
    sleep 2
fi

# Verificar si MariaDB ya está iniciado / Check if MariaDB is already started
if systemctl is-active --quiet mariadb.service; then
    mariadb_already_started_message=$(get_language_message "\033[92mMariaDB service is already running.\033[0m" "\033[92mEl servicio MariaDB ya está en ejecución.\033[0m")
    echo -e "$mariadb_already_started_message"
else
    # Iniciar MariaDB / Start MariaDB
    mariadb_start_message=$(get_language_message "\e[96mStarting MariaDB...\e[0m" "\e[96mIniciando MariaDB...\e[0m")
    echo -e "$mariadb_start_message"
    systemctl start mariadb.service
    sleep 2
fi

# Llama a la función / Call the function
run_sql_commands
sleep 2

# Copia de la carpeta DVWA a /var/www/html / Coping DVWA folder to /var/www/html
dvwa_config_message=$(get_language_message "\e[96mConfiguring DVWA...\e[0m" "\e[96mConfigurando DVWA...\e[0m")
echo -e "$dvwa_config_message"
cp /var/www/html/DVWA/config/config.inc.php.dist /var/www/html/DVWA/config/config.inc.php
sleep 2

# Asignar los permisos adecuados a DVWA / Assign the appropriate permissions to DVWA
permissions_config_message=$(get_language_message "\e[96mConfiguring permissions...\e[0m" "\e[96mConfigurando permisos...\e[0m")
echo -e "$permissions_config_message"
chown -R www-data:www-data /var/www/html/DVWA
chmod -R 755 /var/www/html/DVWA
sleep 2

php_config_message=$(get_language_message "\e[96mConfiguring PHP...\e[0m" "\e[96mConfigurando PHP...\e[0m")
echo -e "$php_config_message"
# Intentando encontrar el archivo php.ini en la carpeta Apache / Trying to find the php.ini file in the Apache folder
php_config_file_apache="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')/apache2/php.ini"

# Intentando encontrar el archivo php.ini en la carpeta FPM / Trying to find the php.ini file in the FPM folder
php_config_file_fpm="/etc/php/$(php -r 'echo PHP_MAJOR_VERSION . "." . PHP_MINOR_VERSION;')/fpm/php.ini"

# Comprueba si el archivo php.ini existe en la carpeta de Apache y úsalo si está presente. / Check if the php.ini file exists in the Apache folder and use it if present.
if [ -f "$php_config_file_apache" ]; then
    php_config_file="$php_config_file_apache"
    sed -i 's/^\(allow_url_include =\).*/\1 on/' $php_config_file
    sed -i 's/^\(allow_url_fopen =\).*/\1 on/' $php_config_file
    sed -i 's/^\(display_errors =\).*/\1 on/' $php_config_file
    sed -i 's/^\(display_startup_errors =\).*/\1 on/' $php_config_file
# Comprueba si el archivo php.ini existe en la carpeta FPM y úsalo si está presente. / Check if the php.ini file exists in the FPM folder and use it if present.
elif [ -f "$php_config_file_fpm" ]; then
    php_config_file="$php_config_file_fpm"
    sed -i 's/^\(allow_url_include =\).*/\1 on/' $php_config_file
    sed -i 's/^\(allow_url_fopen =\).*/\1 on/' $php_config_file
    sed -i 's/^\(display_errors =\).*/\1 on/' $php_config_file
    sed -i 's/^\(display_startup_errors =\).*/\1 on/' $php_config_file
else
    # Mensaje de advertencia si no se encuentra en ninguna de las carpetas / Warning message if not found in any of the folders
    php_file_message=$(get_language_message "\e[91mWarning: PHP configuration file not found in Apache or FPM folders.\e[0m" "\e[91mAdvertencia: No se encuentra el fichero de configuración PHP en las carpetas de Apache o FPM.\e[0m")
    echo -e "$php_file_message"
fi
sleep 2

# Verificar si Apache ya está habilitado / Check if Apache is already enabled
if systemctl is-enabled apache2 &>/dev/null; then
    apache_already_enabled_message=$(get_language_message "\033[92mApache service is already enabled.\033[0m" "\033[92mEl servicio Apache ya está en habilitado.\033[0m")
    echo -e "$apache_already_enabled_message"
else
    # Habilita Apache / Habilita Apache
    apache_enable_message=$(get_language_message "\e[96mEnabling Apache...\e[0m" "\e[96mHabilitando Apache...\e[0m")
    echo -e "$apache_enable_message"
    systemctl enable apache2 &>/dev/null
    sleep 2
fi

# Reinicia el Apache / Apache restart
apache_restart_message=$(get_language_message "\e[96mRestarting Apache...\e[0m" "\e[96mReiniciando Apache...\e[0m")
echo -e "$apache_restart_message"
systemctl enable apache2 &>/dev/null
systemctl restart apache2 &>/dev/null
sleep 2

success_message=$(get_language_message "\e[92mDVWA has been installed successfully. Access \e[93mhttp://localhost/DVWA\e[0m \e[92mto get started." "\e[92mDVWA se ha instalado correctamente. Accede a \e[93mhttp://localhost/DVWA\e[0m \e[92mpara comenzar.")
echo -e "$success_message"

#Mostrar al usuario las credenciales después de la configuración / Show user credentials after configuration
credentials_after_setup_message=$(get_language_message "\e[92mCredentials:\e[0m" "\e[92mCredenciales:\e[0m")
echo -e "$credentials_after_setup_message"
echo -e "Username: \033[93madmin\033[0m"
echo -e "Password: \033[93mpassword\033[0m"

# Fin del instalador / End of installer
echo
final_message=$(get_language_message "\033[95mWith ♡ by IamCarron" "\033[95mCon ♡ by IamCarron")
echo -e "$final_message"
