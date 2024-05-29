#!/usr/bin/env sh

SCRIPT_DIR=$(dirname $0)
WORKING_DIR=$(readlink -f "$SCRIPT_DIR/..")
PLUGIN_NAME=$(basename $WORKING_DIR | sed 's/^wp-//')
PLUGIN_VERSION=$(grep "define ('PLUGIN_$(echo $PLUGIN_NAME | tr '[:lower:]' '[:upper:]')_VERSION'" setup.php | sed -E 's/.*([0-9]+\.[0-9]+\.[0-9]+).*/\1/')

echo "----------------------------------------"
echo "PLUGIN_NAME: $PLUGIN_NAME"
echo "PLUGIN_VERSION: $PLUGIN_VERSION"
echo "WORKING_DIR: $WORKING_DIR"
echo "SCRIPT_DIR: $SCRIPT_DIR"
echo "ARCHIVE_FILE: $WORKING_DIR/../$PLUGIN_NAME-v$PLUGIN_VERSION.tgz"
echo "----------------------------------------\n"

# Install composer dependencies if composer.json exists
if [ -f "$WORKING_DIR/composer.json" ]; then
	echo "Install composer dependencies"
	composer install --no-dev --prefer-dist --no-cache --no-plugins
fi

# Install node dependencies if package.json exists
if [ -f "$WORKING_DIR/package.json" ]; then
	echo "Install node dependencies"
	CMD=`which yarn >/dev/null 2>&1 && echo yarn || echo npm`
	$(CMD) install --no-progress
fi

# Remove useless dev files and directories
files="
		composer.json 
		composer.lock
		package.json
		yarn.lock
		AUTHORS.txt
		CHANGELOG.md
		TODO.md
		$PLUGIN_NAME.png
		$PLUGIN_NAME.xml
		glpi_network.png
		screenshots
		.git
		.github
		.gitignore
		.tx
	  "
# Remove useless files and directories
for file in $files; do
		if [ -f "$WORKING_DIR/$file" ]; then
				rm -f "$WORKING_DIR/$file"
		elif [ -d "$WORKING_DIR/$file" ]; then
				rm -rf "$WORKING_DIR/$file"
		fi
done

# Create archive file of the plugin directory in .tgz format
echo "Create archive file"
tar -czf "$WORKING_DIR/../$PLUGIN_NAME-v$PLUGIN_VERSION.tgz" -C "$WORKING_DIR" ../$PLUGIN_NAME

echo "----------------------------------------"
echo "Build completed"
echo "Archive file created: $PLUGIN_NAME-v$PLUGIN_VERSION.tgz"
echo "----------------------------------------\n"
