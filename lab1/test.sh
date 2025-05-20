#!/usr/bin/env bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac
echo "The script is run on "${machine}" machine"

if [[ "${machine}" == 'Mac' ]]; then
    MD5_SHELL="md5 -r "
else
    MD5_SHELL="md5sum "
fi

# $1 - test suit
# $2 - TASKID
# $3 - field ID
readData()
{
    if [[ $1 -eq 1 ]]
    then
        grep "^$2\s" shunit2-2.1.7/full.txt | cut -f $3
    elif [[ $1 -eq 2 ]]
    then
        grep "^$2\s" shunit2-2.1.7/notsofull.txt | cut -f $3
    else
        "Error!"
    fi
}

oneTimeSetUp()
{
    cp dns-tunneling.log dns-tunneling.log.bak
}

oneTimeTearDown()
{
    mv dns-tunneling.log.bak dns-tunneling.log
}

setUp()
{
    rm results.*
    TASKID=-1
    VAR_1=-1
    VAR_2=-1
    export LC_ALL=C
}

test_TASKID()
{
    source lab1.sh
    echo "TASKID is "$TASKID
    assertNotEquals "Did you forget to set the TASKID variable?" -1 $TASKID
    assertTrue "TASKID is too small" "[ $TASKID -gt 0 ]"
    assertTrue "TASKID is too large" "[ $TASKID -lt 26 ]"
}

test_VAR_1_case1()
{
    setUp_case1
    source lab1.sh
    expected=$(readData 1 $TASKID 2)
    echo "VAR_1 is "$VAR_1
    assertNotEquals "Did you forget to set the VAR_1 variable?" -1 $VAR_1
    assertEquals "Wrong value of VAR_1!" $expected $VAR_1
}

test_VAR_2_case1()
{
    setUp_case1
    source lab1.sh
    expected=$(readData 1 $TASKID 3)
    echo "VAR_2 is "$VAR_2
    assertNotEquals "Did you forget to set the VAR_2 variable?" -1 $VAR_2
    assertEquals "Wrong value of VAR_2!" $expected $VAR_2
}

test_results_file_case1()
{
    setUp_case1
    source lab1.sh
    touch results.txt
    # assertTrue "script was called" "[ -f results.txt ]"
    expected=$(readData 1 $TASKID 4)
    # calculate md5 hash of results file
    md5_results=($($MD5_SHELL results.txt))
    # remove trailing filename and leave MD5 hashsum only:
    actual=$(echo $md5_results)
    echo "MD5 is "$actual
    # assertNotNull "Did you forget to set the VAR_2 variable?" $actual
    assertEquals "File 'results.txt' has wrong contents!" $expected $actual
}


setUp_case1()
{
    cp dns-tunneling.log.bak dns-tunneling.log
}

setUp_case2()
{
    awk '(NR>15 &&NR <30)||(NR>1290 && NR<1305)||(NR>2210 && NR<2215)||(NR>15200 && NR<15380)||(NR>57230 && NR<57310)||(NR>146800 && NR<147000)||(NR>220142&&NR<220313)||(NR>172360 && NR<172560)' dns-tunneling.log.bak > dns-tunneling.log
}

test_VAR_1_case2()
{
    setUp_case2
    source lab1.sh
    expected=$(readData 2 $TASKID 2)
    echo "VAR_1 is "$VAR_1
    assertNotEquals "Did you forget to set the VAR_1 variable?" -1 $VAR_1
    assertEquals "Wrong value of VAR_1!" $expected $VAR_1
}

test_VAR_2_case2()
{
    setUp_case2
    source lab1.sh
    expected=$(readData 2 $TASKID 3)
    echo "VAR_2 is "$VAR_2
    assertNotEquals "Did you forget to set the VAR_2 variable?" -1 $VAR_2
    assertEquals "Wrong value of VAR_2!" $expected $VAR_2
}

test_results_file_case2()
{
    setUp_case2
    source lab1.sh
    touch results.txt
    # assertTrue "script was called" "[ -f results.txt ]"
    expected=$(readData 2 $TASKID 4)
    # calculate md5 hash of results file
    md5_results=($($MD5_SHELL results.txt))
    # remove trailing filename and leave MD5 hashsum only:
    actual=$(echo $md5_results)
    echo "MD5 is "$actual
    # assertNotNull "Did you forget to set the VAR_2 variable?" $actual
    assertEquals "File 'results.txt' has wrong contents!" $expected $actual
}


# load shunit2
. shunit2-2.1.7/shunit2

