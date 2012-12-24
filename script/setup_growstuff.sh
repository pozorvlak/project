#!/bin/bash
# vim: sw=2

if [ $# -lt 1 ]; then
  echo "Usage: $0 [GitHub username]"
  exit 2;
fi

cd
if [ "$HOSTNAME" = "trowel.growstuff.org" ]; then
  echo "You're on the hack server! Unpacking pre-existing ~/.rvm"
  tar xzf /usr/local/share/setup_growstuff/rvmdir.tar.gz
  echo "Patching .rvm files"
  cat /usr/local/share/setup_growstuff/files_to_patch | \
    xargs perl -i -pe 's/\bGROWSTUFF_USER\b/$ENV{USER}/eg'
  mv rvmdir .rvm
  . ~/.rvm/scripts/rvm # uses bashisms
else
  curl -L https://get.rvm.io | bash -s stable
  . ~/.rvm/scripts/rvm # uses bashisms
  rvm install 1.9.3-p194
  rvm docs generate # not sure we actually need this -MRG
fi
rvm use 1.9.3-p194
rvm --default 1.9.3-p194
git clone https://github.com/$1/growstuff.git
cd growstuff/
git remote add upstream https://github.com/Growstuff/growstuff.git
rvm gemset create growstuffdev
rvm gemset use growstuffdev
gem install bundler
git checkout dev
bundle install
rake db:create
rake db:migrate
rake db:seed
rake db:test:prepare
rake
