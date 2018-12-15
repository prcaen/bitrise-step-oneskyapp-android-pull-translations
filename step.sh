#!/bin/bash
set -ex

hash () {
  if [ "$(uname)" == "Darwin" ]; then
    echo -n "$1" | md5
  else
    echo -n "$1" | md5sum | awk '{print $1}'
  fi
}

timestamp=$(date +%s)
dev_hash=$( hash "$timestamp$secret_key" )

locales=`wget --method GET --header 'cache-control: no-cache' --output-document - "https://platform.api.onesky.io/1/projects/$app_id/languages?api_key=$public_key&timestamp=$timestamp&dev_hash=$dev_hash" | jq -rc '.data[] | {l: .locale, r: .region, dl: .is_base_language, c: .code}'`

for row in $locales; do
  _jq() {
   echo ${row} | jq -r ${1}
  }

  code=$(_jq '.c')
  country=$(_jq '.l')
  region=$(_jq '.r')
  default_locale=$(_jq '.dl')

  if [ $default_locale = true ]; then
    folder=$(echo "$output_dir/values")
  elif [[ -n $region ]]; then
    folder=$(echo "$output_dir/values-$country-r$region")
  else
    folder=$(echo "$output_dir/values-$country")
  fi

  mkdir -p $folder

  wget --method GET --header 'cache-control: no-cache' -O $folder/$source_file_name "https://platform.api.onesky.io/1/projects/$app_id/translations?api_key=$public_key&timestamp=$timestamp&dev_hash=$dev_hash&source_file_name=$source_file_name&locale=$code"
done
