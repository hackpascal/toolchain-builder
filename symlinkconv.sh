#!/bin/sh

ROOT_DIR=$1

find "$ROOT_DIR" | while read FILE; do
	if [ -L "$FILE" ]; then
		LINK_TARGET=$(readlink "$FILE")
		is_root=$(echo $LINK_TARGET | cut -c1-1)
		if [ "$is_root" = "/" ]; then
			REAL_FILE=$LINK_TARGET
		else
			FILENAME=$(basename "$FILE")
			BASE_DIR=${FILE%%$FILENAME*}
			REAL_FILE=$BASE_DIR$LINK_TARGET
		fi

		if [ -f "$REAL_FILE" ]; then
			rm "$FILE" && cp -a "$REAL_FILE" "$FILE"
		fi
	fi
done
