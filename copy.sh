#!/bin/bash

tonuino="/Users/michaelsimon/Projects/tonuino/TonUINO"
output="/Volumes/TONUINO"
output="/Volumes/EvenMore/TONUINO"

echo "$# $*"

function mycopy () {
any=0;

echo "mycopy <$1> $PWD"

any=$(expr $any + $(find "$1" -name "*.mp3" | wc -l))
any=$(expr $any + $(find "$1" -name "*.wma" | wc -l))
any=$(expr $any + $(find "$1" -name "*.flac" | wc -l))
if [ $any == 0 ]
then
    echo NOTHING FOUND
    return 0
fi

index=1;
find "$1" -name "*.mp3" | sort | while read file
do
    cp "$file" $(printf "%03i" $index).mp3;
    index=$(expr $index + 1)
done
find "$1" -name "*.wma" | sort | while read file
do
    ffmpeg -i "$file" -acodec mp3 -b:a 128k $(printf "%03i" $index).mp3
    sync; sleep 1
    index=$(expr $index + 1)
done
find "$1" -name "*.flac" | sort | while read file
do
    ffmpeg -i "$file" -acodec mp3 -b:a 128k $(printf "%03i" $index).mp3
    index=$(expr $index + 1)
done
return 1
}

if [ ! -d $output ]
then
    mkdir -p "$output"
else
    rm -fr "$output"
    mkdir -p "$output"
fi

# Standard MP3 Dateien
pushd "$output"
  mkdir mp3
  pushd mp3

    find $tonuino/SD-Karte/mp3 -name "*.mp3" | sort | while read filename; do cp "$filename" .; done

  popd


  folder=1
  for dir
  do
    dst=$(printf "%02i" $folder) 
    mkdir -p $dst
    pushd $dst
      mycopy "$dir"
      retval=$?
    popd
    folder=$(expr $folder + $retval);
done
popd
exit 0
