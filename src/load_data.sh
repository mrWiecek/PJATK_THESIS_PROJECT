#!/bin/bash

mkdir -p data/external

curl -O https://ai.stanford.edu/~amaas/data/sentiment/aclImdb_v1.tar.gz
tar -xf aclImdb_v1.tar.gz
mv aclImdb data/external
rm aclImdb_v1.tar.gz

dvc add data
git add data.dvc .gitignore