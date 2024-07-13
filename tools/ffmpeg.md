# ffmpeg

## Convert audio to AAC3
```sh
$ ffmpeg -i avengers-infinity-war.mp4 -c:v copy -c:a ac3 -b:a 320k avengers-infinity-war.mp4
```

## Embed subtitles
```sh
$ ffmpeg -i avengers-infinity-war.mkv \
    -f srt \
    -i avengers-infinity-war.srt \
    -c:v copy -c:a copy -c:s srt \
    avengers-infinity-war.mkv
```

## Convert audio and embed subtitles
```sh
$ ffmpeg -i avengers-infinity-war.mp4 \
    -f srt \
    -i avengers-infinity-war.srt \
    -c:v copy -c:a ac3 -b:a 320k -c:s srt \
    avengers-infinity-war.mkv
```

## Gather info
```sh
$ ffprobe avengers-infinity-war.mkv
```