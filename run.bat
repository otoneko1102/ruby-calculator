@echo off
echo Checking dependencies...

CALL bundle check || CALL bundle install

echo Running script...

CALL bundle exec ruby src/calc.rb %*