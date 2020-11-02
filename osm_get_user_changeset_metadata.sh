#!/bin/bash

# Script to download all the metadata from all an OSM users changesets
# https://github.com/andrewharvey/osm-get-user-changeset-metadata
# CC0 Licensed by Andrew Harvey 2017

# see also
# https://help.openstreetmap.org/questions/23089/how-to-query-all-changesets-by-a-user-since-eternity
# http://wiki.openstreetmap.org/wiki/API_v0.6#Query:_GET_.2Fapi.2F0.6.2Fchangesets

user_agent="https://github.com/andrewharvey/osm-get-user-changeset-metadata"

display_name="$1"
if [ -z "$display_name" ] ; then
    echo "Usage: $0 display_name"
    exit
fi

quiet="--quiet"

uid=`wget $quiet --user-agent="$user_agent" -O - "https://api.openstreetmap.org/api/0.6/changesets?display_name=$display_name" | xmllint --xpath 'string(/osm/changeset/@uid)' -`

echo "User '$display_name' ($uid)"
mkdir -p $uid

wget $quiet --user-agent="$user_agent" -O "$uid/user.xml" "https://api.openstreetmap.org/api/0.6/user/$uid"
account_created=`xmllint --xpath 'string(/osm/user/@account_created)' $uid/user.xml`

echo "Account Created: $account_created"

changesets_count=0
changesets_total_count=`xmllint --xpath 'string(/osm/user/changesets/@count)' $uid/user.xml`
echo "Changesets: $changesets_total_count"

page=0
T1="$account_created"
T2="INITIAL_VALUE"

# find changesets closed after account opening (T1) and created before the changesets we've already downloaded (T2)
# starts by returning the 100 most recent changesets, then the next 100, etc all the way down to the first changeset

while [ -n "$T2" ] ; do
    if [ "$T2" == "INITIAL_VALUE" ] ; then
        echo "Downloading Changesets between: $T1 and now."
        T2=""
    else
        echo "Downloading Changesets between: $T1 and $T2."
    fi

    page=$(($page + 1))
    if [ -z "$T2" ] ; then
        wget $quiet --user-agent="$user_agent" -O "$uid/$page.xml" "https://api.openstreetmap.org/api/0.6/changesets?display_name=$display_name&time=$T1"
    else
        wget $quiet --user-agent="$user_agent" -O "$uid/$page.xml" "https://api.openstreetmap.org/api/0.6/changesets?display_name=$display_name&time=$T1,$T2"
    fi

    # created time of oldest changeset in this set
    T2=`grep '<changeset' "$uid/$page.xml" | tail -n1 | grep -o 'created_at="[^"]*' | sed 's/created_at="//'`

    # better to actually parse the xml but I can't get this to return the last occurrence instead of the first
    #T2=`xmllint --xpath 'string(/osm/changeset/@created_at)' "$uid/$page.xml"`

    changesets_count=$(($changesets_count + `grep '<changeset' "$uid/$page.xml" | wc -l`))
    echo "$changesets_count / $changesets_total_count"

done
