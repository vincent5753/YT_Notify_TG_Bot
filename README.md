# YT_Notify_TG_Bot
## Intro
A shell script based project is used to notify a user when the YT channel/playlist has uploaded a new video.

## Usage
First, inside the project directory, you will need to create a subdirectory for storing the record of VideoId of each Playlist.
```
mkdir vir_record
```

Second, you will need permission to run the sript.
```
chmod +x yt.sh
```

For adding the channel, you can use both channel id or channel name.

Adding channel using channel id
(the id should looks something like this -> "UCpmx8TiMv9yR1ncyldGyyVA")
```
./yt.sh add_newch_from_name $channelid
```

Adding channel using channel name
(you can find the channel name like this -> "https://www.youtube.com/c/$name")
```
./yt.sh add_newch_from_name $channelname
```

Then just run the script in backgroud, it will send notification whenever a new video is uploaded.
```
./yt.sh
```

## Known Issue
1. Got error when adding ch using "non-English" names
2. Redundant API calls

## TDL
1. Spare API key switcher
2. Registry for channel names
