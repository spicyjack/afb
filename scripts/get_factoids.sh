#!/bin/sh

SOURCE_URI=${SOURCE_URI:-http://sbih.org/Prospero}
OUTPUT_DIR=${OUTPUT_DIR:-/var/www/purl/html/Prospero}
TEMP_DIR=${TEMP_DIR:-$OUTPUT_DIR/tmp}

if [ ! -d $TEMP_DIR ]; then
    mkdir -p $TEMP_DIR
fi
#WGET_OPTS="-N"
for FILE in Prospero-are.dir Prospero-are.pag Prospero-is.dir Prospero-is.pag;
do
    # -q quiet
    wget -q -O "$TEMP_DIR/$FILE" "$SOURCE_URI/$FILE"
    OLD_FILE_SIZE=$(stat --format="%s" $OUTPUT_DIR/$FILE)
    NEW_FILE_SIZE=$(stat --format="%s" $TEMP_DIR/$FILE)
    # don't worry about copying unless the new file is larger
    # this is assuming that file sizes change no matter what; 
    # if the db file is not compacted when a factoid is deleted, then 
    # the test below will not catch differences
    # TODO parse the old and new factoid files, and compare by key/value?
    if [ $NEW_FILE_SIZE -ge $OLD_FILE_SIZE ]; then
        mv -f ${TEMP_DIR}/${FILE} ${OUTPUT_DIR}/${FILE}
    else
        rm -f ${TEMP_DIR}/${FILE}
    fi
done

# make a tarball in order to make downloads easier
cd $OUTPUT_DIR
/bin/tar -cjvf factoids.tar.bz2 Prospero*
