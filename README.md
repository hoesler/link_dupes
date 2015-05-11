# link_dupes
link_dupes is an executable ruby script to hard link files given as a list in the default format produced by [fdupes](https://github.com/adrianlopezroche/fdupes) ("... duplicate files are listed together in groups, each file displayed on a separate line.").

The original version of fdupes only supports deletion of identified duplicates but not linking. While there is a [fork of fdupes](https://github.com/tobiasschulz/fdupes) with a patch to add support for this, it has not been updated with the main development branch for a while. Neither did the patch made it into the original version for whatever reason. This script allows to use the latest version of fdupes while offering a convenient way to link the files.

## Usage:
```shell
	fdupes -r . | link_dupes
```