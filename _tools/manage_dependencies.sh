#!/bin/bash

case $1 in

export)
    echo "Exporting dependecies to requirements.txt file."
    poetry export --without-hashes --format=requirements.txt >requirements.txt
    ;;

import)
    echo "Installing dependencies from requirements file."
    poetry add $(cat requirements.txt)
    ;;

*)
    echo "need to specify export or import argument"
    ;;
esac



