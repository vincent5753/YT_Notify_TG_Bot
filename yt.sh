#!/bin/bash

ApiKey=""     # -> go get your own key! 

red=$'\e[1;31m'
grn=$'\e[1;32m'
yel=$'\e[1;33m'
end=$'\e[0m'

get_channel_id (){
  curl -s https://www.youtube.com/c/$1 | awk -FexternalId '{print $2}' | perl -pe 's/\n//' | awk -F "\"" '{print $3}'
}


get_channel_contentdetails (){
  ChannelId=$1
  response=$(curl -s "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&id=$ChannelId&key=$ApiKey")
  echo $response | awk -Fuploads '{print $2}' | awk -F "\"" '{print $3}'
}


get_channel_latest_vid (){
  PlayListId=$1
  
  response=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=$PlayListId&key=$ApiKey&maxResults=1")
  vid=$(echo $response | awk -FvideoId '{print $2}' | awk -F "\"" '{print $3}')
  title=$(echo $response | awk -Ftitle '{print $2}' | awk -F "\"" '{print $3}')

  echo -e "vid: \c"
  echo $vid
  echo -e "title: \c"
  echo $title

  echo $vid > ./vid_record/$PlayListId.latest
}


update_playlist_latest_vid (){
  for i in ./vid_record/*.latest
  do
    PlaylistId=$(echo $i | awk -F "/" '{print $3}' | awk -F "." '{print $1}')
    context=$(cat $i)
    echo "PlaylistIdId: $PlaylistId -> Latest_Vid: $context"
    get_channel_latest_vid $PlaylistId
  done
}


read_channel_latest_vid (){
  for i in ./vid_record/*.latest
  do
    PlaylistId=$(echo $i | awk -F "/" '{print $3}' | awk -F "." '{print $1}')
    context=$(cat $i)
    echo "PlaylistId: $PlaylistId -> Latest_Vid: $context"
  done
}


add_newch_from_name (){
  chid=$(get_channel_id "$1")
  PlaylistId=$(get_channel_contentdetails $chid)
  get_channel_latest_vid $PlaylistId
  
  response=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=$PlayListId&key=$ApiKey&maxResults=1")
  vid=$(echo $response | awk -FvideoId '{print $2}' | awk -F "\"" '{print $3}')
  title=$(echo $response | awk -Ftitle '{print $2}' | awk -F "\"" '{print $3}')
  tg_alert $vid $title
}


add_newch_from_id (){
  PlaylistId=$(get_channel_contentdetails $1)
  get_channel_latest_vid $PlaylistId
  
  response=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=$PlayListId&key=$ApiKey&maxResults=1")
  vid=$(echo $response | awk -FvideoId '{print $2}' | awk -F "\"" '{print $3}')
  title=$(echo $response | awk -Ftitle '{print $2}' | awk -F "\"" '{print $3}')
  tg_alert $vid $title
}


compare_latest (){
  for i in ./vid_record/*.latest
  do
  PlaylistId=$(echo $i | awk -F "/" '{print $3}' | awk -F "." '{print $1}')
  context=$(cat $i)

  response=$(curl -s "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet,contentDetails,status&playlistId=$PlaylistId&key=$ApiKey&maxResults=1")

  latest_vid=$(echo $response | awk -FvideoId '{print $2}' | awk -F "\"" '{print $3}')

    if [ "$latest_vid" = "$context" ]
    then
        printf "%s\n" "<狀態> ${red}已是最新影片${end}    $(date '+%y/%m/%d %X')"
        printf "%s\n" "<資訊> PlaylistId: $PlaylistId / Latest_Vid: ${red}$latest_vid${end}"
        echo ""
    else
        printf "%s\n" "<狀態> ${grn}發現新影片${end}      $(date '+%y/%m/%d %X')"
        printf "%s\n" "<資訊> PlaylistId: $PlaylistId / Previous_Vid: ${red}$context${end} / Latest_Vid: ${grn}$latest_vid${end}"
        echo $latest_vid > $i
        title=$(echo $esponse | awk -Ftitle '{print $2}' | awk -F "\"" '{print $3}')
        tg_alert $latest_vid "$title"
    fi
  done

}


tg_alert (){
  bot_token=''                                          # -> go get your own key! 
  bot_chatID=''                                      # -> choose the chatId you want 
  
  printf "%s\n" "<動作> ${yel}發TG通知啦${end}      $(date '+%y/%m/%d %X')"
  L1="影片ID: $1"
  L2="標題: $2"
  L3="連結: https://youtu.be/$1"
  L4="https://img.youtube.com/vi/$1/maxresdefault.jpg"
  echo $L1
  echo $L2
  echo $L3
  echo $L4
  bot_message=$(printf %s\\n "$L1" "$L2" "$L3" "$L4"| jq -sRr @uri)
  send_url="https://api.telegram.org/bot$bot_token/sendMessage?chat_id=$bot_chatID&parse_mode=HTML&text=$bot_message"
  echo $send_url
  curl -X GET "$send_url"
  echo ""
  echo ""
}

if [ "$1" = "get_channel_contentdetails" ]
then
  get_channel_contentdetails $2
fi

if [ "$1" = "get_channel_latest_vid" ]
then
  get_channel_latest_vid $2
fi

if [ "$1" = "get_channel_id" ]
then
  get_channel_id $2
fi

if [ "$1" = "read_channel_latest_vid" ]
then
  read_channel_latest_vid
fi

if [ "$1" = "update_playlist_latest_vid" ]
then
  update_playlist_latest_vid 
fi

if [ "$1" = "add_newch_from_name" ]
then
  add_newch_from_name $2
fi

if [ "$1" = "add_newch_from_id" ]
then
  add_newch_from_id $2
fi

if [ "$1" = "compare_latest" ]
then
  compare_latest
fi

while true
do
  printf "$(date '+%y/%m/%d %X')\n"
	compare_latest
  sleep 90
done
