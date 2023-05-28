# osm-get-user-changeset-metadata

This script will download the changeset metadata from all changesets made by a named OpenStreetMap user.

## Prerequisites

 - bash
 - wget
 - xmllint

## Usage

    ./osm_get_user_changeset_metadata.sh <username>

This will create a new directory structure:

  - <userid>/user.xml (user data)
  - <userid>/<page>.xml (one file for each page of 100 changesets ordered by date, so for example with 1.xml containing the most recent changes)
