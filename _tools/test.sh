#!/bin/bash

case $1 in

export)
    echo "export"
    ;;

import)
    echo "import"
    ;;

*)
    echo "need to specify export or import argument"
    ;;
esac
