while read -r tenent;
do
   LINE=$(echo $tenent | sed 's/[ \t]*#.*//')
   if [[ $LINE == "" ]]; then
      continue;
   fi
   echo $LINE
   tname=$(echo $LINE | sed 's/:.*//')
   echo $tname
   args=$(echo $LINE | sed s/$tname://)
   #echo $args
   echo $args | while IFS=, read enabled repo path arg; do
      echo $enabled
      echo $repo
      echo $path
      echo $arg
      ## Call pipeline here with arguments
   done
done < sample-tenents
