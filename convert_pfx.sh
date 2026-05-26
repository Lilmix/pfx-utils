#!/bin/bash

# Loop through all .pfx files in the current directory
for pfx_file in *.pfx; do
    # Ensure files exist to prevent running on a literal "*.pfx" string
    [ -e "$pfx_file" ] || { echo "No .pfx files found in this directory."; exit 1; }

    # Extract the base name (e.g., "www.pfx" becomes "www")
    base_name="${pfx_file%.pfx}"

    echo "--------------------------------------------------"
    echo "Processing: $pfx_file"
    
    # Prompt for password securely (keystrokes won't echo on screen)
    echo -n "Enter password for [$pfx_file]: "
    read -s password
    echo "" # Prints a newline after hidden input

    # 1. Extract the private key
    echo "-> Extracting private key to $base_name.key..."
    openssl pkcs12 -in "$pfx_file" -out "$base_name.key" -nocerts -nodes -password pass:"$password"

    # 2. Extract the certificate
    echo "-> Extracting certificate to $base_name.crt..."
    openssl pkcs12 -in "$pfx_file" -out "$base_name.crt" -nokeys -clcerts -password pass:"$password"

    echo "Finished processing $base_name"
done

echo "--------------------------------------------------"
echo "All PFX files have been processed!"
