#!/usr/bin/env bash

declare file_name
working_dir=tmp/
infile=$1
current_dir=$(pwd)
out_dir="out"

get_out_filename() {
	file_name="${infile::-4}_repacked.deb"
}

clean_up() {
	cd $current_dir
	# rm -rf $out_dir/$get_out_filename
	echo "Cleaning up..."
	rm -rf $working_dir
}

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 deb_package_name.deb"
	exit -2
fi

echo "Checking file extension..."
if [[ $infile != *.deb ]] 
then
	echo "Unsupported file type"
	exit -1
else
	get_out_filename
fi

echo "Creating output directory..."
if ! mkdir -p $out_dir
then
	echo "Cannot create output directory"
	exit -1
fi
out_dir=$current_dir/$out_dir

echo "Creating temp directory..."
if ! mkdir -p $working_dir
then
	echo "Cannot create temp directory"
	exit -1
fi

echo "Extracting deb package..."
if ! ar vx --output=$working_dir $infile; then
		echo "Failed to extract deb package"
		clean_up
		exit -1
fi

echo "Extracting control.tar.zst..."
if ! zstd -d $working_dir\control.tar.zst -o $working_dir\control.tar; then
		echo "Failed to extract control.tar.zst package"
		clean_up
		exit -1
fi

echo "Extracting data.tar.zst..."
if ! zstd -d $working_dir\data.tar.zst -o $working_dir\data.tar; then
		echo "Failed to extract data.tar.zst package"
		clean_up
		exit -1
fi

echo "Compressing control.tar.xz..."
cd $working_dir
if ! xz control.tar; then
		echo "Failed to compress control.tar package"
		clean_up
		exit -1
fi

echo "Compressing data.tar.xz..."
if ! xz data.tar; then
		echo "Failed to compress data.tar package"
		clean_up
		exit -1
fi
cd $current_dir

echo "Creating new deb package..."
if ! ar -rc $out_dir/$file_name $working_dir\debian-binary $working_dir\control.tar.xz $working_dir\data.tar.xz; then
		echo "Failed to create deb package"
		clean_up
		exit -1
fi

clean_up

echo "Done. ${infile} repacked as ${out_dir}/${file_name}"