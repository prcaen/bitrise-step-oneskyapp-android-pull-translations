#!/bin/bash
set -ex

hash () {
  if [ "$(uname)" == "Darwin" ]; then
    echo -n "$1" | md5
  else
    echo -n "$1" | md5sum
  fi
}

timestamp=$(date +%s)
dev_hash=$( hash "$timestamp$secret_key" )

locales=`wget --method GET --header 'cache-control: no-cache' --output-document - "https://platform.api.onesky.io/1/projects/$app_id/languages?api_key=$public_key&timestamp=$timestamp&dev_hash=$dev_hash" | jq '.data[].locale'`

for rawLocale in $locales; do
  timestamp=$(date +%s)
  dev_hash=$( hash "$timestamp$secret_key" )
  locale=$(echo $rawLocale | jq -r)

  if [ $locale == $default_locale ]; then
    folder=$(echo "$output_dir/values")
  else
    folder=$(echo "$output_dir/values-$locale")
  fi

  mkdir -p $folder

  wget --method GET --header 'cache-control: no-cache' -O $folder/$source_file_name "https://platform.api.onesky.io/1/projects/$app_id/translations?api_key=$public_key&timestamp=$timestamp&dev_hash=$dev_hash&source_file_name=$source_file_name&locale=$locale"
done
