#!/bin/bash
#Set origdir where complete files are linked (i.e. 99-outputs)
#set end dir where you want files to be copied to
#set storage dir where files actually are (e.g. 03-mdups in STAR pipeline)

#SAMPLE ORIGDIR=/projects/rmorin/projects/gambl-repos/gambl-kcoyle/results/gambl/star-1.4/99-outputs/bam/mrna--grch37

ORIGDIR=${1:?Must provide ORIGDIR}
ENDDIR=${2:?Must provide ENDDIR}
STORAGEDIR=${3:?Must provide STORAGEDIR}

# redirect stdout to a file
exec > $ENDDIR/logfile.txt

set -euo pipefail

for FILE in $(ls $ORIGDIR/*.bam | xargs -n 1 basename |  sed 's/....$//')
do
	#make sure this is NOT already a symlink
	if [ ! -f "$ENDDIR/$FILE.bam" ]
		then
		
			#copy file to ENDDIR
			cp -L $ORIGDIR/$FILE.bam $ENDDIR/$FILE.bam
			
			#md5 checksum to ensure file copied correctly
			md5sum $ORIGDIR/$FILE.bam > $ORIGDIR/$FILE.bam.md5
			md5sum $ENDDIR/$FILE.bam > $ENDDIR/$FILE.bam.md5

			if md5sum -c --quiet "$ENDDIR/$FILE.bam.md5" "$ORIGDIR/$FILE.bam.md5"
				then
					#delete original file 
					rm $ORIGDIR/$FILE.bam
					rm $STORAGEDIR/$FILE.sort.mdups.bam
					rm $ORIGDIR/$FILE.bam.md5
					rm $ENDDIR/$FILE.bam.md5
				
					#create absolute symlink in ORIGDIR
					ln -s $ENDDIR/$FILE.bam $ORIGDIR/$FILE.bam
				else echo "${ORIGDIR}/${FILE}.bam did not copy correctly. Please try again."
			fi
		#if the file exists and there is no symlink to ENDDIR then delete original symlink
		elif !  [[ "$(readlink -f "$ORIGDIR/$FILE.bam")" == "$ENDDIR/$FILE.bam" ]]
			then
				#md5 checksum to ensure file copied correctly
	                        md5sum $ORIGDIR/$FILE.bam > $ORIGDIR/$FILE.bam.md5
        	                md5sum $ENDDIR/$FILE.bam > $ENDDIR/$FILE.bam.md5

                	        if md5sum -c --quiet "$ENDDIR/$FILE.bam.md5" "$ORIGDIR/$FILE.bam.md5"
                        	        then
                                	        #delete original file
                                        	rm $ORIGDIR/$FILE.bam
	                                        rm $STORAGEDIR/$FILE.sort.mdups.bam
						rm $ORIGDIR/$FILE.bam.md5
        	                                rm $ENDDIR/$FILE.bam.md5
                
		                        	#create absolute symlink in ORIGDIR
	                                        ln -s $ENDDIR/$FILE.bam $ORIGDIR/$FILE.bam
        	                        else echo "${ORIGDIR}/${FILE}.bam was already copied and symlinked."
                	        fi
		
		else echo "${ENDDIR}/${FILE}.bam already exists."	
	fi
done
