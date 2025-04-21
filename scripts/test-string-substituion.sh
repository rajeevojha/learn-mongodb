#!bin/bash
str1="ec2-xxxx.us-west-1.compute.amazonaws.com"
str2="54.215.130.186"
str3=${str2//\./-}

result=${str1/xxxx/$str3}

echo "$result"
