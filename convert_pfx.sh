#!/bin/bash
# curl -sSL https://raw.githubusercontent.com/Lilmix/pfx-utils/main/convert_pfx.sh -o convert_pfx.sh && bash convert_pfx.sh && rm convert_pfx.sh
# Loop through all .pfx files in the current directory
for pfx_file in *.pfx; do
    # Ensure files exist to prevent running on a literal "*.pfx" string
    [ -e "$pfx_file" ] || { echo "No .pfx files found in this directory."; exit 1; }

    base_name="${pfx_file%.pfx}"

    echo "--------------------------------------------------"
    echo "Processing: $pfx_file"
    
    # Loop indefinitely until a correct password is provided or the file is skipped
    while true; do
        # Prompt for password securely
        echo -n "Enter password for [$pfx_file]: "
        read -s password
        echo "" # Prints a newline after hidden input

        echo "-> Verifying password and extracting private key..."
        
        # Attempt to extract the private key. Standard error is hidden to keep the terminal clean.
        if openssl pkcs12 -in "$pfx_file" -out "$base_name.key" -nocerts -nodes -password pass:"$password" 2>/dev/null; then
            
            # If the first step succeeds, the password is correct. Proceed to certificate extraction.
            echo "-> Extracting certificate to $base_name.crt..."
            openssl pkcs12 -in "$pfx_file" -out "$base_name.crt" -nokeys -clcerts -password pass:"$password" 2>/dev/null
            
            echo "✅ Successfully processed $base_name"
            break # Exit the password loop and move to the next file
            
        else
            echo "❌ Error: Incorrect password or invalid PFX file."
            
            # OpenSSL occasionally leaves an empty or corrupt file behind on failure; clean it up
            rm -f "$base_name.key"

            # Prompt the user for their next move
            while true; do
                echo -n "Would you like to [r]etry or [s]kip this file? (r/s): "
                read -n 1 choice
                echo "" # Move to next line after keystroke
                
                case "$choice" in
                    [rR]* )
                        echo "Let's try again..."
                        break # Breaks out of the choice loop, stays inside the password loop
                        ;;
                    [sS]* )
                        echo "Skipping $pfx_file."
                        break 2 # Breaks out of both the choice loop AND the password loop to move to the next file
                        ;;
                    * )
                        echo "Invalid option. Please press 'r' to retry or 's' to skip."
                        ;;
                esac
            done
        fi
    done
done

echo "--------------------------------------------------"
echo "All PFX files have been processed!"
