# link_dupes
link_dupes is an executable ruby script to hard link files given as a list in the default format produced by [fdupes](https://github.com/adrianlopezroche/fdupes) ("... duplicate files are listed together in groups, each file displayed on a separate line.").

## Usage:
```
	fdupes . | link_dupes.rb	
	fdupes . > dupes; link_dupes.rb dupes
```