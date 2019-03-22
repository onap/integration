#!/bin/bash
# EXAMPLE: Run test case TC2 using the command "./prepare.sh TC2"
MAIN_DIRECTORY=./files/onap
TEST_FILE=./test_cases.yml
TEST=$1
echo "Generating files for test case:" "$TEST"

sf=$(sed -n '/'$TEST'/,$p' $TEST_FILE | grep -m 1 'size_files')
sf=${sf//*size_files: /}
sf_array=($sf)
echo "size_files=""$sf"

nf=$(sed -n '/'$TEST'/,$p' $TEST_FILE | grep -m 1 'number_files')
nf=${nf//*number_files: /}
nf_array=($nf)
echo "number_files=""$nf"

df=$(sed -n '/'$TEST'/,$p' $TEST_FILE | grep -m 1 'directory_files')
df=${df//*directory_files: /}
df_array=($df)
echo "directory_files=""$df"

rm -rf $MAIN_DIRECTORY/*
if [ "${#sf_array[@]}" = "${#nf_array[@]}" ] && [ "${#nf_array[@]}" = "${#df_array[@]}" ];
then
    N_ELEMENTS=${#df_array[@]}
	for ((n=0;n<$N_ELEMENTS;n++))
	do
		# Create directory
		DIRECTORY=$MAIN_DIRECTORY/${df_array[$n]}
		mkdir -p "$DIRECTORY"

		# Create original file
		FILE_SIZE=${sf_array[$n]}
		FILE_NAME=$FILE_SIZE"MB.tar.gz"
		dd if=/dev/urandom of=$DIRECTORY/$FILE_NAME bs=1k count=$(echo $FILE_SIZE*1000/1 | bc)

		# Create symlinks
		N_SYMLINKS=${nf_array[$n]}-1
		for ((l=0;l<=$N_SYMLINKS;l++))
		do
			SYMLINK_NAME=$FILE_SIZE"MB_"$l".tar.gz"
			ln -s ./$FILE_NAME $DIRECTORY/$SYMLINK_NAME
		done
	done
else
echo "ERROR: The number of parameters in size_files, number_files, and directory_files must be equal!"
fi

sudo chown root:root ./configuration/vsftpd_ssl.conf
