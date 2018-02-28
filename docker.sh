#!/bin/bash

#docker pull dujinfang/texlive_pandoc

if [ -z "$2" ]; then

	if [ $# -lt 1 ]; then

		echo "must input you file path "

	else

		docker run --rm -ti -v $1:/fsbooks dujinfang/texlive_pandoc bash -c "cd ../ && cd fsbooks && make"

	fi

else

	if [ $# -eq 2 ]; then

		if [ $2 = "redtitle" ]; then 

			docker run --rm -ti -v $1:/team dujinfang/texlive_pandoc bash -c "cd redtitle && make"

		fi

	fi

fi
