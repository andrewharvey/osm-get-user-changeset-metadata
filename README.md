# osm-get-user-changeset-metadata

This script will download the changeset metadata from all changesets made by a named OpenStreetMap user.

## Prerequisites

 - bash
 - wget
 - xmllint

## Usage

    ./osm_get_user_changeset_metadata.sh <username>

Script will create a folder in the same directory as the .sh file with the folder name being the numerical user id. Inside the folder will be a user.xml with user data as well as a *.xml file for every 100 changeset entries ordered by date decending (i.e. 1.xml will be newest changesets).
