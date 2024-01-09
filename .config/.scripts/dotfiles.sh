#!/bin/bash

# Configuration
source_folder="/path/to/source/folder"
backup_folder="/path/to/backup/folder"
#backup_subfolder="backup_$(date +'%Y%m%d_%H%M%S')"

# Create backup folder
mkdir -p "$backup_folder/$backup_subfolder"

# Copy files
cp -r "$source_folder"/* "$backup_folder/$backup_subfolder/"

echo "Backup completed: $backup_subfolder"

