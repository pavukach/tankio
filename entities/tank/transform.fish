#!/usr/bin/env fish

for s in **.png

    magick $s \
        -alpha on -fuzz 10% -trim +repage \
        -resize 256x256 \
        -background none -gravity center -extent 256x256 \
        $s
end
