#!/bin/sh

./vendor/bin/generate files/ out/ 'my blog' '' 'https://dvikan/no'
cp -r blogimages out/
rsync -avz -e "ssh" out/ blog@blog:public/_site/

